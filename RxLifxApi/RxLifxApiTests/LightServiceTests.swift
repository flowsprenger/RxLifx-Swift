/*

Copyright 2017 Florian Sprenger

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
documentation files (the "Software"), to deal in the Software without restriction, including without limitation the
rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit
persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the
Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

*/

import XCTest
import RxSwift
import RxTest
import RxLifx
import LifxDomain
@testable import RxLifxApi

class LightServiceTests: XCTestCase {

    private var changeDispatcher: TestLightChangeDispatcher!

    private var service: LightService<TestTransport<LightMessageGenerator>>!

    private var scheduler: TestScheduler!

    override func setUp() {
        super.setUp()

        changeDispatcher = TestLightChangeDispatcher()
        scheduler = TestScheduler(initialClock:0)
        service = LightService(lightsChangeDispatcher: changeDispatcher, transportGenerator: TestTransport.self, mainScheduler: scheduler, ioScheduler: scheduler)

        service.start()
    }

    override func tearDown() {
        service.stop()
        super.tearDown()
    }

    func testCreatesLightsOnReceivingMessages() {
        let lightId: UInt64 = 34566
        let expectation = XCTestExpectation(description: "creates light instance")

        changeDispatcher.lightAddedDelegate = { light in
            expectation.fulfill()
        }

        service.udpTransport.sendMessageDelegate = createTestLightResponder(service: service, lightId: lightId)

        scheduler.advanceTo(5)
        scheduler.advanceTo(11)

        wait(for: [expectation], timeout: 1)
    }

    func testBroadcastsGetServiceRegularly() {
        let lightId: UInt64 = 34566
        let expectation = XCTestExpectation(description: "discovers lights")

        let expectedGetServiceMessageCount = 3
        var count = 0

        service.udpTransport.sendMessageDelegate = { (_ target: sockaddr, _ data: Data) -> (Bool) in
            if let m = self.service.udpTransport.generator.generate(from: target, data: data) {
                switch (m.message.payload) {
                case is GetService:
                    count += 1
                    if(count == expectedGetServiceMessageCount){
                        expectation.fulfill()
                    }
                default: ()
                }
            }

            return true
        }

        scheduler.advanceTo(5)
        scheduler.advanceTo(11)
        wait(for: [expectation], timeout: 1)
    }
}

class TestTransport<TMG:MessageGenerator>: Transport {

    let publisher = PublishSubject<TMG.TM>()
    let messages: Observable<TMG.TM>
    let generator: TMG

    var sendMessageDelegate: ((_ target: sockaddr, _ data: Data) -> (Bool))?

    required init(port: String, generator: TMG) {
        self.generator = generator
        self.messages = publisher.asObservable()
    }

    func sendMessage(target: sockaddr, data: Data) -> Bool {
        return sendMessageDelegate?(target, data) ?? false
    }
}

func createTestLightResponder(service: LightService<TestTransport<LightMessageGenerator>>, lightId: UInt64) -> ((_ target: sockaddr, _ data: Data) -> (Bool)) {
    return { (_ target: sockaddr, _ data: Data) -> (Bool) in
        if let m = service.udpTransport.generator.generate(from: target, data: data) {
            switch (m.message.payload) {
            case is GetService:
                service.udpTransport.publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(StateService(service: Service.UDP, port: 56700), target: lightId)))
            default: ()
            }
        }

        return true
    }
}
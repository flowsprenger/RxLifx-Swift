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

        service.udpTransport.sendMessageDelegate = createTestLightResponder(service: service, lightId: lightId, addr: sockaddr.broadcastTo(port: 56700))

        scheduler.advanceTo(16)

        wait(for: [expectation], timeout: 1)
    }

    func testBroadcastsGetServiceRegularly() {
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

        scheduler.advanceTo(16)
        wait(for: [expectation], timeout: 1)
    }

    func testPassesSendWithoutToTransportWithBroadcastAddress(){
        let expectation = XCTestExpectation(description: "passes send to main transport")

        service.udpTransport.sendMessageDelegate = { (_ target: sockaddr, _ data: Data) -> (Bool) in
            if(target.host() == sockaddr.broadcastTo(port: 56700).host()){
                expectation.fulfill()
            }
            return true
        }

        _ = service.sendMessage(light: nil, data: Data())

        wait(for: [expectation], timeout: 1)
    }

    func testPassesSendWithoutToTransportWithLightAddress(){
        let lightId: UInt64 = 34566
        let expectation = XCTestExpectation(description: "sends message to light addr")

        var light: Light? = nil

        changeDispatcher.lightAddedDelegate = { newLight in
            light = newLight
        }

        let addr = sockaddr(sa_len: 0, sa_family: UInt8(AF_INET),
                sa_data: (0, 0, 3, 0, 0, 5, 0, 0, 6, 0, 0, 0, 0, 0))

        service.udpTransport.sendMessageDelegate = createTestLightResponder(service: service, lightId: lightId, addr: addr)


        scheduler.advanceTo(5)
        scheduler.advanceTo(11)


        XCTAssertNotNil(light)

        service.udpTransport.sendMessageDelegate = { (_ target: sockaddr, _ data: Data) -> (Bool) in
            if(target.host() == light?.addr?.host()){
                expectation.fulfill()
            }
            return true
        }
        _ = service.sendMessage(light: light, data: Data())

        wait(for: [expectation], timeout: 1)
    }


    func testStopsAndRestarts(){
        let lightId: UInt64 = 34566
        let expectation = XCTestExpectation(description: "creates light instance")

        var light: Light? = nil
        changeDispatcher.lightAddedDelegate = { newLight in
            light = newLight
            expectation.fulfill()
        }

        service.udpTransport.sendMessageDelegate = createTestLightResponder(service: service, lightId: lightId, addr: sockaddr.broadcastTo(port: 56700))
        scheduler.advanceTo(5)
        service.udpTransport.publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(LightState(color: HSBK(hue: 0, saturation: 0, brightness: 0, kelvin: 0), reserved: 0, power: PowerState.ON.rawValue, label: "test light", reserved1:0), target: lightId, source: service.source)))
        scheduler.advanceTo(11)
        XCTAssertEqual(true, light?.powerState)
        wait(for: [expectation], timeout: 1)

        service.stop()

        service.udpTransport.publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(LightState(color: HSBK(hue: 0, saturation: 0, brightness: 0, kelvin: 0), reserved: 0, power: PowerState.OFF.rawValue, label: "test light", reserved1:0), target: lightId, source: service.source)))
        XCTAssertEqual(true, light?.powerState)
        scheduler.advanceTo(15)

        service.start()
        scheduler.advanceTo(25)
        service.udpTransport.publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(LightState(color: HSBK(hue: 0, saturation: 0, brightness: 0, kelvin: 0), reserved: 0, power: PowerState.OFF.rawValue, label: "test light", reserved1:0), target: lightId, source: service.source)))
        scheduler.advanceTo(35)
        XCTAssertEqual(false, light?.powerState)
    }
}

class TestTransport<TMG:MessageGenerator>: Transport {

    let publisher = PublishSubject<TMG.TM>()
    let messages: Observable<TMG.TM>
    let generator: TMG

    var sendMessageDelegate: ((_ target: sockaddr, _ data: Data) -> (Bool))?

    required init(port: String, generator: TMG) {
        self.generator = generator
        self.messages = publisher.asObservable().publish().refCount()
    }

    func sendMessage(target: sockaddr, data: Data) -> Bool {
        return sendMessageDelegate?(target, data) ?? false
    }
}

func createTestLightResponder(service: LightService<TestTransport<LightMessageGenerator>>, lightId: UInt64, addr: sockaddr) -> ((_ target: sockaddr, _ data: Data) -> (Bool)) {
    return { (_ target: sockaddr, _ data: Data) -> (Bool) in
        if let m = service.udpTransport.generator.generate(from: target, data: data) {
            switch (m.message.payload) {
            case is GetService:
                service.udpTransport.publisher.onNext(SourcedMessage(sourceAddress: addr, message: Message.createMessageWithPayload(StateService(service: Service.UDP, port: 56700), target: lightId)))
            default: ()
            }
        }

        return true
    }
}
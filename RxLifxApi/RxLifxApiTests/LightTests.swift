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

class LightTests: XCTestCase {

    var light:Light!
    var lightId:UInt64!
    var publisher: PublishSubject<SourcedMessage>!
    var scheduler: TestScheduler!
    var changeDispatcher: TestLightChangeDispatcher!
    var lightSource:TestLightSource!
    let messageGenerator = LightMessageGenerator()

    override func setUp() {
        super.setUp()

        scheduler = TestScheduler(initialClock: 0)
        publisher = PublishSubject()
        changeDispatcher = TestLightChangeDispatcher()

        let id = UInt64(237324876)
        lightId = id

        let observable = GroupedObservable(key: id, source: publisher)
        lightSource = TestLightSource(messages: publisher, scheduler: scheduler)

        light = Light(id: id, lightSource: lightSource, lightChangeDispatcher: changeDispatcher)
        _ = light.attach(observable: observable)
    }
    
    override func tearDown() {
        light.dispose()
        super.tearDown()
    }

    func testLightInitializesId(){
        XCTAssertEqual(light.target, lightId)
        XCTAssertEqual(light.id, lightId.toLightId())
    }

    func testLightUpdatesReachableOnMessage(){
        let label = "abcde"
        let expectation = XCTestExpectation(description: "receives label change notification")
        changeDispatcher.notifyChangeDelegate = { (_ light: Light, _ property: LightPropertyName, _ oldValue: Any?, _ newValue: Any?) in
            if(property == .reachable){
                XCTAssertEqual(light.id, self.light.id)
                XCTAssertEqual(oldValue as? Bool, false)
                XCTAssertEqual(newValue as? Bool, true)
                expectation.fulfill()
            }
        }
        publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(StateLabel(label: label), target: light.target, source: light.lightSource.source)))
        XCTAssertEqual(light.reachable.value, true)

        wait(for: [expectation], timeout: 1)
    }

    func testLightUpdatesLabelAndNotifies(){
        let label = "abcde"
        let expectation = XCTestExpectation(description: "receives label change notification")
        changeDispatcher.notifyChangeDelegate = { (_ light: Light, _ property: LightPropertyName, _ oldValue: Any?, _ newValue: Any?) in
            if(property == .label){
                XCTAssertEqual(light.id, self.light.id)
                XCTAssertEqual(oldValue as? String, nil)
                XCTAssertEqual(newValue as? String, label)
                expectation.fulfill()
            }
        }
        publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(StateLabel(label: label), target: light.target, source: light.lightSource.source)))
        XCTAssertEqual(light.label.value, label)

        wait(for: [expectation], timeout: 1)
    }

    func testLightUpdatesGroupAndNotifies(){
        let label = "abcde"
        let id:[UInt8] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        let updated_at = UInt64(arc4random_uniform(UInt32.max))
        let expectation = XCTestExpectation(description: "receives group change notification")
        changeDispatcher.notifyChangeDelegate = { (_ light: Light, _ property: LightPropertyName, _ oldValue: Any?, _ newValue: Any?) in
            if(property == .group){
                XCTAssertEqual(light.id, self.light.id)
                XCTAssertEqual(oldValue as? LightGroup, LightGroup.defaultGroup)
                XCTAssertEqual((newValue as! LightGroup).label, label)
                XCTAssertEqual((newValue as! LightGroup).id, id)
                XCTAssertEqual((newValue as! LightGroup).updatedAt, updated_at.dateFromNanoSeconds())
                expectation.fulfill()
            }
        }
        publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(StateGroup(group: id, label: "abcde", updated_at: updated_at), target: light.target, source: light.lightSource.source)))
        XCTAssertEqual(light.group.value?.label, label)
        XCTAssertEqual(light.group.value!.id, id)
        XCTAssertEqual(light.group.value?.updatedAt, updated_at.dateFromNanoSeconds())

        wait(for: [expectation], timeout: 1)
    }

    func testLightUpdatesLocationAndNotifies(){
        let label = "abcde"
        let id:[UInt8] = [0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15]
        let updated_at = UInt64(arc4random_uniform(UInt32.max))
        let expectation = XCTestExpectation(description: "receives group change notification")
        changeDispatcher.notifyChangeDelegate = { (_ light: Light, _ property: LightPropertyName, _ oldValue: Any?, _ newValue: Any?) in
            if(property == .location){
                XCTAssertEqual(light.id, self.light.id)
                XCTAssertEqual(oldValue as? LightLocation, LightLocation.defaultLocation)
                XCTAssertEqual((newValue as! LightLocation).label, label)
                XCTAssertEqual((newValue as! LightLocation).id, id)
                XCTAssertEqual((newValue as! LightLocation).updatedAt, updated_at.dateFromNanoSeconds())
                expectation.fulfill()
            }
        }
        publisher.onNext(SourcedMessage(sourceAddress: sockaddr.broadcastTo(port: 56700), message: Message.createMessageWithPayload(StateLocation(location: id, label: "abcde", updated_at: updated_at), target: light.target, source: light.lightSource.source)))
        XCTAssertEqual(light.location.value?.label, label)
        XCTAssertEqual(light.location.value!.id, id)
        XCTAssertEqual(light.location.value?.updatedAt, updated_at.dateFromNanoSeconds())

        wait(for: [expectation], timeout: 1)
    }

    func testPollInitialPropertiesOnAttach(){
        let observable = GroupedObservable(key: lightId!, source: publisher)
        let expectationGetHostFirmware = XCTestExpectation(description: "polls host firmware")
        let expectationGetWifiFirmware = XCTestExpectation(description: "polls wifi firmware")
        let expectationGetGroup = XCTestExpectation(description: "polls group")
        let expectationGetLocation = XCTestExpectation(description: "polls location")
        let expectationGetVersion = XCTestExpectation(description: "polls version")
        let expectationGetState = XCTestExpectation(description: "polls light state")
        let expectationGetMultiZoneState = XCTestExpectation(description: "polls light multi zone state")
        let expectationGetInfraredState = XCTestExpectation(description: "polls light infrared state")

        lightSource.delegate = { (_ light: Light?, _ data: Data) in
            if let message = self.messageGenerator.generate(from: sockaddr.broadcastTo(port: 56700), data: data){
                switch (message.message.payload ){
                    case is GetHostFirmware: expectationGetHostFirmware.fulfill()
                    case is GetWifiFirmware: expectationGetWifiFirmware.fulfill()
                    case is GetGroup: expectationGetGroup.fulfill()
                    case is GetLocation: expectationGetLocation.fulfill()
                    case is GetVersion: expectationGetVersion.fulfill()
                    case is LightGet: expectationGetState.fulfill()
                    case is GetColorZones: expectationGetMultiZoneState.fulfill()
                    case is GetInfrared: expectationGetInfraredState.fulfill()
                    default: ()
                }
                return true
            }
            return false
        }
        _ = light.attach(observable: observable)

        wait(for: [expectationGetHostFirmware, expectationGetWifiFirmware, expectationGetGroup, expectationGetLocation, expectationGetVersion, expectationGetState, expectationGetMultiZoneState, expectationGetInfraredState], timeout: 1)
    }

    func testPollPropertiesOnTick(){
        let expectationGetState = XCTestExpectation(description: "polls light state")
        let expectationGetMultiZoneState = XCTestExpectation(description: "polls light multi zone state")
        let expectationGetInfraredState = XCTestExpectation(description: "polls light infrared state")

        lightSource.delegate = { (_ light: Light?, _ data: Data) in
            if let message = self.messageGenerator.generate(from: sockaddr.broadcastTo(port: 56700), data: data){
                switch (message.message.payload ){
                case is LightGet: expectationGetState.fulfill()
                case is GetColorZones: expectationGetMultiZoneState.fulfill()
                case is GetInfrared: expectationGetInfraredState.fulfill()
                default: ()
                }
                return true
            }
            return false
        }
        lightSource.doTick()

        wait(for: [expectationGetState, expectationGetMultiZoneState, expectationGetInfraredState], timeout: 1)
    }

    func testPollPropertiesAtLeastEveryNthTick(){
        let expectationGetGroup = XCTestExpectation(description: "polls group")
        let expectationGetLocation = XCTestExpectation(description: "polls location")

        lightSource.delegate = { (_ light: Light?, _ data: Data) in
            if let message = self.messageGenerator.generate(from: sockaddr.broadcastTo(port: 56700), data: data){
                switch (message.message.payload ){
                case is GetGroup: expectationGetGroup.fulfill()
                case is GetLocation: expectationGetLocation.fulfill()
                default: ()
                }
                return true
            }
            return false
        }
        for _ in 0...Light.refreshMutablePropertiesTickModulo {
            lightSource.doTick()
        }

        wait(for: [expectationGetGroup, expectationGetLocation], timeout: 1)
    }
}

class TestLightSource: LightSource{

    let tick: Observable<Int>
    let source: UInt32 = arc4random_uniform(UInt32.max)
    let messages: Observable<SourcedMessage>
    let ioScheduler: SchedulerType
    let mainScheduler: SchedulerType
    let tickPublisher = PublishSubject<Int>()
    var sequence = 0

    var delegate: ((_ light: Light?, _ data: Data) -> (Bool))?

    init(messages: Observable<SourcedMessage>, scheduler: SchedulerType){
        self.messages = messages
        self.tick = tickPublisher
        self.ioScheduler = scheduler
        self.mainScheduler = scheduler
    }

    func sendMessage(light: Light?, data: Data) -> Bool{
        return delegate?(light, data) ?? false
    }

    func doTick(){
        sequence += 1
        tickPublisher.onNext(sequence)
    }

    func extensionOf<E>() -> E? where E: LightServiceExtension {
        fatalError("extensionOf() has not been implemented")
    }
}

class TestLightChangeDispatcher: LightsChangeDispatcher{
    var notifyChangeDelegate: ((_ light: Light, _ property: LightPropertyName, _ oldValue: Any?, _ newValue: Any?) -> ())?
    var lightAddedDelegate: ((_ light: Light) -> ())?

    func notifyChange(light: Light, property: LightPropertyName, oldValue: Any?, newValue: Any?){
        notifyChangeDelegate?(light, property, oldValue, newValue)
    }

    func lightAdded(light: Light){
        lightAddedDelegate?(light)
    }
}
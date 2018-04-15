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

class LightsGroupLocationServiceTests: XCTestCase {

    var lightChangeDispatcher: TestLightChangeDispatcher!
    var groupLocationChangeDispatcher: TestGroupLocationChangeDispatcher!
    var lightGroupLocationService: LightsGroupLocationService!
    var lightSource: SimpleTestLightSource!
    var lightOne: Light!
    var lightTwo: Light!

    override func setUp() {
        super.setUp()

        lightChangeDispatcher = TestLightChangeDispatcher()
        groupLocationChangeDispatcher = TestGroupLocationChangeDispatcher()
        lightGroupLocationService = LightsGroupLocationService(lightsChangeDispatcher: lightChangeDispatcher, groupLocationChangeDispatcher: groupLocationChangeDispatcher)
        lightSource = SimpleTestLightSource()
        lightOne = Light(id: 1, lightSource: lightSource, lightChangeDispatcher: lightGroupLocationService)
        lightTwo = Light(id: 1, lightSource: lightSource, lightChangeDispatcher: lightGroupLocationService)
    }

    func testAddsLightWithDefaultLocationGroup() {

        let expectationDefaultLocationAdded = XCTestExpectation(description: "creates default location")
        groupLocationChangeDispatcher.locationAddedDelegate = { location in
            expectationDefaultLocationAdded.fulfill()
        }

        let expectationDefaultGroupAdded = XCTestExpectation(description: "creates default group")
        groupLocationChangeDispatcher.groupAddedDelegate = { group in
            expectationDefaultGroupAdded.fulfill()
        }

        let expectationDefaultGroupLightAdded = XCTestExpectation(description: "adds light to default group")
        groupLocationChangeDispatcher.groupChangedDelegate = { group in
            if(group.lights.contains(self.lightOne)) {
                expectationDefaultGroupLightAdded.fulfill()
            }
        }

        lightGroupLocationService.lightAdded(light: lightOne)

        wait(for: [expectationDefaultLocationAdded, expectationDefaultGroupAdded, expectationDefaultGroupLightAdded], timeout: 1)
    }

    func testSecondLightAddedToDefaultGroupOnlyTriggersChange() {

        lightGroupLocationService.lightAdded(light: lightOne)

        let expectationDefaultLocationAdded = XCTestExpectation(description: "creates default location")
        expectationDefaultLocationAdded.isInverted = true
        groupLocationChangeDispatcher.locationAddedDelegate = { location in
            expectationDefaultLocationAdded.fulfill()
        }

        let expectationDefaultGroupAdded = XCTestExpectation(description: "creates default group")
        expectationDefaultGroupAdded.isInverted = true
        groupLocationChangeDispatcher.groupAddedDelegate = { group in
            expectationDefaultGroupAdded.fulfill()
        }

        let expectationDefaultGroupLightAdded = XCTestExpectation(description: "adds light to default group")
        groupLocationChangeDispatcher.groupChangedDelegate = { group in
            if(group.lights.contains(self.lightTwo)) {
                expectationDefaultGroupLightAdded.fulfill()
            }
        }

        lightGroupLocationService.lightAdded(light: lightTwo)

        wait(for: [expectationDefaultLocationAdded, expectationDefaultGroupAdded, expectationDefaultGroupLightAdded], timeout: 1)
    }

    func testRemovesDefaultGroupWhenGroupChanges() {

        lightGroupLocationService.lightAdded(light: lightOne)

        let expectationNewGroupAdded = XCTestExpectation(description: "creates new group")
        groupLocationChangeDispatcher.groupAddedDelegate = { group in
            expectationNewGroupAdded.fulfill()
        }

        let expectationDefaultGroupRemoved = XCTestExpectation(description: "removes default group")
        groupLocationChangeDispatcher.groupRemovedDelegate = { group in
            if(group.lights.count == 0) {
                expectationDefaultGroupRemoved.fulfill()
            }
        }

        lightOne.group.updateFromClient(value: LightGroup(id:[1,2,3,4,5,6,7,8], label: "group", updatedAt: Date()))

        wait(for: [expectationDefaultGroupRemoved, expectationNewGroupAdded], timeout: 1)

        let expectationNewLocationAdded = XCTestExpectation(description: "creates new location")
        groupLocationChangeDispatcher.locationAddedDelegate = { location in
            expectationNewLocationAdded.fulfill()
        }

        let expectationDefaultLocationRemoved = XCTestExpectation(description: "removes default location")
        groupLocationChangeDispatcher.locationRemovedDelegate = { location in
            if(location.groups.count == 0) {
                expectationDefaultLocationRemoved.fulfill()
            }
        }

        lightOne.location.updateFromClient(value: LightLocation(id:[1,2,3,4,5,6,7,8], label: "location", updatedAt: Date()))

        wait(for: [expectationNewLocationAdded, expectationDefaultLocationRemoved], timeout: 1)
    }
}

class SimpleTestLightSource: LightSource {
    let tick: Observable<Int> = PublishSubject<Int>()
    let source: UInt32 = 0
    let ioScheduler: SchedulerType = TestScheduler(initialClock:0)
    let messages: Observable<SourcedMessage> = PublishSubject<SourcedMessage>()

    func sendMessage(light: Light?, data: Data) -> Bool {
        return true
    }
}

class TestGroupLocationChangeDispatcher: GroupLocationChangeDispatcher{
    var groupAddedDelegate: ((_ group: LightsGroup) -> ())?
    var groupRemovedDelegate: ((_ group: LightsGroup) -> ())?
    var groupChangedDelegate: ((_ group: LightsGroup) -> ())?

    var locationAddedDelegate: ((_ location: LightsLocation) -> ())?
    var locationRemovedDelegate: ((_ location: LightsLocation) -> ())?
    var locationChangedDelegate: ((_ location: LightsLocation) -> ())?

    func groupAdded(group: LightsGroup) {
        groupAddedDelegate?(group)
    }

    func groupRemoved(group: LightsGroup) {
        groupRemovedDelegate?(group)
    }

    func groupChanged(group: LightsGroup) {
        groupChangedDelegate?(group)
    }

    func locationAdded(location: LightsLocation) {
        locationAddedDelegate?(location)
    }

    func locationRemoved(location: LightsLocation) {
        locationRemovedDelegate?(location)
    }

    func locationChanged(location: LightsLocation) {
        locationChangedDelegate?(location)
    }
}
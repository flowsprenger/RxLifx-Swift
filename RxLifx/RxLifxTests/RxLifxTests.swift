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
@testable import RxLifx

class RxLifxTests: XCTestCase {

    var disposables:CompositeDisposable!
    var broadcastAddr = sockaddr.broadcastTo(port: 56701)

    override func setUp() {
        super.setUp()
        disposables = CompositeDisposable()
    }
    
    override func tearDown() {
        disposables.dispose()
        super.tearDown()
    }

    func testReceiveMessage(){

        let expectation = XCTestExpectation(description: "received broadcasted message")
        let testData = Data(bytes: [1, 3, 2, 5])

        let socket = UdpSocket()
        let result = socket.connect(port: "56700")

        switch(result){
            case .Success(let handle):
                let transport = UdpTransport(port: "56701", generator: TestMessageGenerator())
                _ = disposables.insert(transport.messages.subscribe{ event in
                    switch(event){
                        case .next(let data):
                            XCTAssertEqual(data, testData)
                            expectation.fulfill()
                            break
                        default: ()
                    }
                })
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    let result = socket.writeMessage(socketDescriptor: handle, addr: &self.broadcastAddr, data: testData)
                    XCTAssertEqual(result, testData.count)
                }
                break
            case .Failure:
                XCTAssertTrue(false)
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSendMessage(){

        let expectation = XCTestExpectation(description: "received broadcasted message")
        let testData = Data(bytes: [1, 3, 2, 5])

        let transport = UdpTransport(port: "56701", generator: TestMessageGenerator())
        _ = disposables.insert(transport.messages.subscribe{ event in
            switch(event){
            case .next(let data):
                XCTAssertEqual(data, testData)
                expectation.fulfill()
                break
            default: ()
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            let result = transport.sendMessage(target: self.broadcastAddr, data: testData)
            XCTAssertEqual(result, true)
        }

        wait(for: [expectation], timeout: 5)
    }
}

class TestMessageGenerator : MessageGenerator{
    public func generate(from: sockaddr, data:Data) -> Data?{
        return data
    }
}
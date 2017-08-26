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
@testable import LifxDomain

class DataInputStreamTests: XCTestCase {

    var data: Data!

    override func setUp() {
        super.setUp()
        data = Data()
    }

    func testReadByte() throws {
        let byte = UInt8(arc4random_uniform(UInt32(UInt8.max)))
        data.append(contentsOf: [UInt8(byte)])

        let stream = DataInputStream(data: data)

        let byteRead = try stream.readByte()
        XCTAssertEqual(byte, byteRead)
    }

    func testReadShort() throws {
        var short = UInt16(arc4random_uniform(UInt32(UInt16.max)))
        data.append(UnsafeBufferPointer(start: &short, count: 1))

        let stream = DataInputStream(data: data)

        let shortRead = try stream.readShort()
        XCTAssertEqual(short, shortRead)
    }

    func testReadWord() throws {
        var word = UInt32(arc4random_uniform(UInt32.max))
        data.append(UnsafeBufferPointer(start: &word, count: 1))

        let stream = DataInputStream(data: data)

        let wordRead = try stream.readWord()
        XCTAssertEqual(word, wordRead)
    }

    func testReadLong() throws {
        var long = UInt64(arc4random()) + (UInt64(arc4random()) << 32)
        data.append(UnsafeBufferPointer(start: &long, count: 1))

        let stream = DataInputStream(data: data)

        let longRead = try stream.readLong()
        XCTAssertEqual(long, longRead)
    }

    func testReadFloat() throws {
        var float = Float32(Float32(arc4random()) / Float32(UINT32_MAX))
        data.append(UnsafeBufferPointer(start: &float, count: 1))

        let stream = DataInputStream(data: data)

        let floatRead = try stream.readFloat()
        XCTAssertEqual(float, floatRead)
    }

    func testReadString() throws {
        var string = "LifxDomainTestString"
        data.append(string.data(using: String.Encoding.utf8)!)

        let stream = DataInputStream(data: data)

        let stringRead = try stream.readString(size: string.characters.count)
        XCTAssertEqual(string, stringRead)
    }

    func testReadArray() throws {
        let bytes = [UInt8(arc4random_uniform(UInt32(UInt8.max))),
                     UInt8(arc4random_uniform(UInt32(UInt8.max))),
                     UInt8(arc4random_uniform(UInt32(UInt8.max)))]
        data.append(contentsOf: bytes)

        let stream = DataInputStream(data: data)

        let bytesRead = try stream.readArray(size: 3, generator: { try $0.readByte() })
        XCTAssertEqual(bytes, bytesRead)
    }

    func testReadOverEnd() throws {
        let stream = DataInputStream(data: data)

        XCTAssertThrowsError(try stream.readByte()){ error in
            XCTAssertEqual(error as? DataStreamError, DataStreamError.outOfBounds)
        }
    }

    override func tearDown() {
        super.tearDown()
    }
}

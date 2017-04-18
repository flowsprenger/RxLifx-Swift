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

import Foundation

public class Message {
    public let header:Header
    public let payload:MessagePayload

    public init(header:Header, payload:MessagePayload){
        self.header = header
        self.payload = payload
    }

    public class func createMessageWithPayload(_ payload: MessagePayload, target:UInt64, source:UInt32 = 1, sequence:UInt8 = 0) -> Message{
        let header = Header(size: UInt16(Header._size + payload._size), protocolOriginTagged: Header.LIFX_PROTOCOL | UInt16(1 << 12), source: source, target: target, reserved:[UInt8](repeatElement(UInt8(0), count: 6)), flags:0, sequence:sequence, reserved1:0, type:payload._type, reserved2:0)
        return Message(header: header, payload: payload)
    }

    public class func createBroadcastMessageWithPayload(_ payload: MessagePayload, source:UInt32 = 1) -> Message{
        let header = Header(size: UInt16(Header._size + payload._size), protocolOriginTagged: Header.LIFX_PROTOCOL | UInt16(1 << 13) | UInt16(1 << 12), source: source, target: 0, reserved:[UInt8](repeatElement(UInt8(0), count: 6)), flags:0, sequence:0, reserved1:0, type:payload._type, reserved2:0)
        return Message(header: header, payload: payload)
    }

    public func toData() -> Data{
        let stream = DataOutputStream(size: header._size + payload._size)
        header.emit(stream: stream)
        payload.emit(stream: stream)
        return stream.finalize()
    }
}

public class SourcedMessage{
    public let sourceAddress: sockaddr
    public let message:Message

    public init(sourceAddress:sockaddr, message:Message){
        self.sourceAddress = sourceAddress
        self.message = message
    }
}
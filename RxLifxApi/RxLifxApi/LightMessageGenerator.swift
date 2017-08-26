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
import RxLifx
import LifxDomain

public class LightMessageGenerator : MessageGenerator{
    public func generate(from: sockaddr, data:Data) -> SourcedMessage?{
        let stream = DataInputStream(data: data)

        if let header = Header(stream: stream){
            if let payloadGenerator = MessagePayloadFromType[header.type], let payload = payloadGenerator(stream) {
                return SourcedMessage(sourceAddress: from, message: Message(header: header, payload: payload))
            } else {
                return SourcedMessage(sourceAddress: from, message: Message(header: header, payload: UnknownPayload()))
            }
        }
        return nil
    }
}

public class UnknownPayload : MessagePayload{
    public func emit(stream:DataOutputStream){
    }

    public let _size = 0
    public let _type:UInt16 = 0
}
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
import CoreGraphics

public extension Header {
    public static let LIFX_DEFAULT_PORT: UInt16 = 56700
    public static let LIFX_PROTOCOL: UInt16 = 1024
    public static let RESPONSE_REQUIRED: UInt8 = 0x1;
    public static let ACK_REQUIRED: UInt8 = 0x2;

    public var id: String {
        get {
            return self.target.toLightId()
        }
    }

    public func setBroadcast() {
        self.target = 0
        self.protocolOriginTagged = Header.LIFX_PROTOCOL | UInt16(1 << 13) | UInt16(1 << 12)
    }

    public func setTarget(target: UInt64) {
        self.target = target
        self.protocolOriginTagged = Header.LIFX_PROTOCOL | UInt16(1 << 12)
    }

    public var responseRequired: Bool {
        get {
            return (flags & Header.RESPONSE_REQUIRED) != 0
        }
        set {
            if (newValue) {
                flags = flags | Header.RESPONSE_REQUIRED
            } else {
                flags = flags & ~Header.RESPONSE_REQUIRED
            }
        }
    }

    public var ackRequired: Bool {
        get {
            return (flags & Header.ACK_REQUIRED) != 0
        }
        set {
            if (newValue) {
                flags = flags | Header.ACK_REQUIRED
            } else {
                flags = flags & ~Header.ACK_REQUIRED
            }
        }
    }
}

extension UInt64 {
    public func toLightId() -> String {
        let id = String(self.byteSwapped, radix: 16, uppercase: false)
        return String(id.prefix(12))
    }
}

extension HSBK {
    public func toCGColor() -> CGColor {
        let components = [CGFloat(hue)/CGFloat(UInt16.max), CGFloat(saturation)/CGFloat(UInt16.max), 1.0, CGFloat(brightness)/CGFloat(UInt16.max)]
        return CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: components)!
    }
}


extension HSBK: Equatable {
    public static func ==(lhs: HSBK, rhs: HSBK) -> Bool {
        return lhs.hue == rhs.hue &&
                lhs.saturation == rhs.saturation &&
                lhs.brightness == rhs.brightness &&
                lhs.kelvin == rhs.kelvin
    }
}

extension Array {
    public func pad(length: Int, e: Element) -> Array {
       if(self.count == length){
           return self
       }else if(self.count > length){
           return Array(self.dropLast(self.count - length))
       }else{
           return self + Array(repeating: e, count: length - self.count)
       }
    }
}

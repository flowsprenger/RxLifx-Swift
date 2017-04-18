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

public class Header {

    public static let _size = 36
    public let _size = 36
    public let _type:UInt16 = 0

    public var size:UInt16
    public var protocolOriginTagged:UInt16
    public var source:UInt32
    public var target:UInt64
    public var reserved:[UInt8]
    public var flags:UInt8
    public var sequence:UInt8
    public var reserved1:UInt64
    public var type:UInt16
    public var reserved2:UInt16

    public init(size:UInt16, protocolOriginTagged:UInt16, source:UInt32, target:UInt64, reserved:[UInt8], flags:UInt8, sequence:UInt8, reserved1:UInt64, type:UInt16, reserved2:UInt16){
        self.size = size
        self.protocolOriginTagged = protocolOriginTagged
        self.source = source
        self.target = target
        self.reserved = reserved
        self.flags = flags
        self.sequence = sequence
        self.reserved1 = reserved1
        self.type = type
        self.reserved2 = reserved2
    }

    public init(stream:DataInputStream){
        size = stream.readShort()
        protocolOriginTagged = stream.readShort()
        source = stream.readWord()
        target = stream.readLong()
        reserved = stream.readArray(size: 6, generator:{stream in return stream.readByte()})
        flags = stream.readByte()
        sequence = stream.readByte()
        reserved1 = stream.readLong()
        type = stream.readShort()
        reserved2 = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:size)
        stream.writeShort(value:protocolOriginTagged)
        stream.writeWord(value:source)
        stream.writeLong(value:target)
        stream.writeArray(value: reserved, writer:{reserved, stream in return stream.writeByte(value:reserved)})
        stream.writeByte(value:flags)
        stream.writeByte(value:sequence)
        stream.writeLong(value:reserved1)
        stream.writeShort(value:type)
        stream.writeShort(value:reserved2)
    }

}
public class GetService : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 2


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateService : MessagePayload {

    public static let _size = 5
    public let _size = 5
    public let _type:UInt16 = 3

    public var service:Service?
    public var port:UInt32

    public init(service:Service?, port:UInt32){
        self.service = service
        self.port = port
    }

    public init(stream:DataInputStream){
        service = Service(rawValue: stream.readByte())
        port = stream.readWord()
    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:(service?.rawValue ?? 0))
        stream.writeWord(value:port)
    }

}
public class GetHostInfo : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 12


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateHostInfo : MessagePayload {

    public static let _size = 14
    public let _size = 14
    public let _type:UInt16 = 13

    public var signal:Float32
    public var tx:UInt32
    public var rx:UInt32
    public var reserved:UInt16

    public init(signal:Float32, tx:UInt32, rx:UInt32, reserved:UInt16){
        self.signal = signal
        self.tx = tx
        self.rx = rx
        self.reserved = reserved
    }

    public init(stream:DataInputStream){
        signal = stream.readFloat()
        tx = stream.readWord()
        rx = stream.readWord()
        reserved = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeFloat(value:signal)
        stream.writeWord(value:tx)
        stream.writeWord(value:rx)
        stream.writeShort(value:reserved)
    }

}
public class GetHostFirmware : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 14


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateHostFirmware : MessagePayload {

    public static let _size = 20
    public let _size = 20
    public let _type:UInt16 = 15

    public var build:UInt64
    public var reserved:UInt64
    public var version:UInt32

    public init(build:UInt64, reserved:UInt64, version:UInt32){
        self.build = build
        self.reserved = reserved
        self.version = version
    }

    public init(stream:DataInputStream){
        build = stream.readLong()
        reserved = stream.readLong()
        version = stream.readWord()
    }

    public func emit(stream:DataOutputStream){
        stream.writeLong(value:build)
        stream.writeLong(value:reserved)
        stream.writeWord(value:version)
    }

}
public class GetWifiInfo : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 16


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateWifiInfo : MessagePayload {

    public static let _size = 14
    public let _size = 14
    public let _type:UInt16 = 17

    public var signal:Float32
    public var tx:UInt32
    public var rx:UInt32
    public var reserved:UInt16

    public init(signal:Float32, tx:UInt32, rx:UInt32, reserved:UInt16){
        self.signal = signal
        self.tx = tx
        self.rx = rx
        self.reserved = reserved
    }

    public init(stream:DataInputStream){
        signal = stream.readFloat()
        tx = stream.readWord()
        rx = stream.readWord()
        reserved = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeFloat(value:signal)
        stream.writeWord(value:tx)
        stream.writeWord(value:rx)
        stream.writeShort(value:reserved)
    }

}
public class GetWifiFirmware : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 18


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateWifiFirmware : MessagePayload {

    public static let _size = 20
    public let _size = 20
    public let _type:UInt16 = 19

    public var build:UInt64
    public var reserved:UInt64
    public var version:UInt32

    public init(build:UInt64, reserved:UInt64, version:UInt32){
        self.build = build
        self.reserved = reserved
        self.version = version
    }

    public init(stream:DataInputStream){
        build = stream.readLong()
        reserved = stream.readLong()
        version = stream.readWord()
    }

    public func emit(stream:DataOutputStream){
        stream.writeLong(value:build)
        stream.writeLong(value:reserved)
        stream.writeWord(value:version)
    }

}
public class GetPower : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 20


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class SetPower : MessagePayload {

    public static let _size = 2
    public let _size = 2
    public let _type:UInt16 = 21

    public var level:UInt16

    public init(level:UInt16){
        self.level = level
    }

    public init(stream:DataInputStream){
        level = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:level)
    }

}
public class StatePower : MessagePayload {

    public static let _size = 2
    public let _size = 2
    public let _type:UInt16 = 22

    public var level:UInt16

    public init(level:UInt16){
        self.level = level
    }

    public init(stream:DataInputStream){
        level = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:level)
    }

}
public class GetLabel : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 23


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class SetLabel : MessagePayload {

    public static let _size = 32
    public let _size = 32
    public let _type:UInt16 = 24

    public var label:String

    public init(label:String){
        self.label = label
    }

    public init(stream:DataInputStream){
        label = stream.readString(size: 32)
    }

    public func emit(stream:DataOutputStream){
        stream.writeString(value: label, size:32)
    }

}
public class StateLabel : MessagePayload {

    public static let _size = 32
    public let _size = 32
    public let _type:UInt16 = 25

    public var label:String

    public init(label:String){
        self.label = label
    }

    public init(stream:DataInputStream){
        label = stream.readString(size: 32)
    }

    public func emit(stream:DataOutputStream){
        stream.writeString(value: label, size:32)
    }

}
public class GetVersion : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 32


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateVersion : MessagePayload {

    public static let _size = 12
    public let _size = 12
    public let _type:UInt16 = 33

    public var vendor:UInt32
    public var product:UInt32
    public var version:UInt32

    public init(vendor:UInt32, product:UInt32, version:UInt32){
        self.vendor = vendor
        self.product = product
        self.version = version
    }

    public init(stream:DataInputStream){
        vendor = stream.readWord()
        product = stream.readWord()
        version = stream.readWord()
    }

    public func emit(stream:DataOutputStream){
        stream.writeWord(value:vendor)
        stream.writeWord(value:product)
        stream.writeWord(value:version)
    }

}
public class GetInfo : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 34


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateInfo : MessagePayload {

    public static let _size = 24
    public let _size = 24
    public let _type:UInt16 = 35

    public var time:UInt64
    public var uptime:UInt64
    public var downtime:UInt64

    public init(time:UInt64, uptime:UInt64, downtime:UInt64){
        self.time = time
        self.uptime = uptime
        self.downtime = downtime
    }

    public init(stream:DataInputStream){
        time = stream.readLong()
        uptime = stream.readLong()
        downtime = stream.readLong()
    }

    public func emit(stream:DataOutputStream){
        stream.writeLong(value:time)
        stream.writeLong(value:uptime)
        stream.writeLong(value:downtime)
    }

}
public class Acknowledgement : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 45


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class GetLocation : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 48


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateLocation : MessagePayload {

    public static let _size = 56
    public let _size = 56
    public let _type:UInt16 = 50

    public var location:[UInt8]
    public var label:String
    public var updated_at:UInt64

    public init(location:[UInt8], label:String, updated_at:UInt64){
        self.location = location
        self.label = label
        self.updated_at = updated_at
    }

    public init(stream:DataInputStream){
        location = stream.readArray(size: 16, generator:{stream in return stream.readByte()})
        label = stream.readString(size: 32)
        updated_at = stream.readLong()
    }

    public func emit(stream:DataOutputStream){
        stream.writeArray(value: location, writer:{location, stream in return stream.writeByte(value:location)})
        stream.writeString(value: label, size:32)
        stream.writeLong(value:updated_at)
    }

}
public class GetGroup : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 51


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateGroup : MessagePayload {

    public static let _size = 56
    public let _size = 56
    public let _type:UInt16 = 53

    public var group:[UInt8]
    public var label:String
    public var updated_at:UInt64

    public init(group:[UInt8], label:String, updated_at:UInt64){
        self.group = group
        self.label = label
        self.updated_at = updated_at
    }

    public init(stream:DataInputStream){
        group = stream.readArray(size: 16, generator:{stream in return stream.readByte()})
        label = stream.readString(size: 32)
        updated_at = stream.readLong()
    }

    public func emit(stream:DataOutputStream){
        stream.writeArray(value: group, writer:{group, stream in return stream.writeByte(value:group)})
        stream.writeString(value: label, size:32)
        stream.writeLong(value:updated_at)
    }

}
public class EchoRequest : MessagePayload {

    public static let _size = 64
    public let _size = 64
    public let _type:UInt16 = 58

    public var payload:[UInt8]

    public init(payload:[UInt8]){
        self.payload = payload
    }

    public init(stream:DataInputStream){
        payload = stream.readArray(size: 64, generator:{stream in return stream.readByte()})
    }

    public func emit(stream:DataOutputStream){
        stream.writeArray(value: payload, writer:{payload, stream in return stream.writeByte(value:payload)})
    }

}
public class EchoResponse : MessagePayload {

    public static let _size = 64
    public let _size = 64
    public let _type:UInt16 = 59

    public var payload:[UInt8]

    public init(payload:[UInt8]){
        self.payload = payload
    }

    public init(stream:DataInputStream){
        payload = stream.readArray(size: 64, generator:{stream in return stream.readByte()})
    }

    public func emit(stream:DataOutputStream){
        stream.writeArray(value: payload, writer:{payload, stream in return stream.writeByte(value:payload)})
    }

}
public class HSBK {

    public static let _size = 8
    public let _size = 8
    public let _type:UInt16 = 0

    public var hue:UInt16
    public var saturation:UInt16
    public var brightness:UInt16
    public var kelvin:UInt16

    public init(hue:UInt16, saturation:UInt16, brightness:UInt16, kelvin:UInt16){
        self.hue = hue
        self.saturation = saturation
        self.brightness = brightness
        self.kelvin = kelvin
    }

    public init(stream:DataInputStream){
        hue = stream.readShort()
        saturation = stream.readShort()
        brightness = stream.readShort()
        kelvin = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:hue)
        stream.writeShort(value:saturation)
        stream.writeShort(value:brightness)
        stream.writeShort(value:kelvin)
    }

}
public class LightGet : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 101


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class LightSetColor : MessagePayload {

    public static let _size = 13
    public let _size = 13
    public let _type:UInt16 = 102

    public var reserved:UInt8
    public var color:HSBK
    public var duration:UInt32

    public init(reserved:UInt8, color:HSBK, duration:UInt32){
        self.reserved = reserved
        self.color = color
        self.duration = duration
    }

    public init(stream:DataInputStream){
        reserved = stream.readByte()
        color = HSBK(stream: stream)
        duration = stream.readWord()
    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:reserved)
        color.emit(stream: stream)
        stream.writeWord(value:duration)
    }

}
public class LightState : MessagePayload {

    public static let _size = 52
    public let _size = 52
    public let _type:UInt16 = 107

    public var color:HSBK
    public var reserved:UInt16
    public var power:UInt16
    public var label:String
    public var reserved1:UInt64

    public init(color:HSBK, reserved:UInt16, power:UInt16, label:String, reserved1:UInt64){
        self.color = color
        self.reserved = reserved
        self.power = power
        self.label = label
        self.reserved1 = reserved1
    }

    public init(stream:DataInputStream){
        color = HSBK(stream: stream)
        reserved = stream.readShort()
        power = stream.readShort()
        label = stream.readString(size: 32)
        reserved1 = stream.readLong()
    }

    public func emit(stream:DataOutputStream){
        color.emit(stream: stream)
        stream.writeShort(value:reserved)
        stream.writeShort(value:power)
        stream.writeString(value: label, size:32)
        stream.writeLong(value:reserved1)
    }

}
public class LightGetPower : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 116


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class LightSetPower : MessagePayload {

    public static let _size = 6
    public let _size = 6
    public let _type:UInt16 = 117

    public var level:UInt16
    public var duration:UInt32

    public init(level:UInt16, duration:UInt32){
        self.level = level
        self.duration = duration
    }

    public init(stream:DataInputStream){
        level = stream.readShort()
        duration = stream.readWord()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:level)
        stream.writeWord(value:duration)
    }

}
public class LightStatePower : MessagePayload {

    public static let _size = 2
    public let _size = 2
    public let _type:UInt16 = 118

    public var level:UInt16

    public init(level:UInt16){
        self.level = level
    }

    public init(stream:DataInputStream){
        level = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:level)
    }

}
public class GetInfrared : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 120


    public init(){
    }

    public init(stream:DataInputStream){
    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateInfrared : MessagePayload {

    public static let _size = 2
    public let _size = 2
    public let _type:UInt16 = 121

    public var brightness:UInt16

    public init(brightness:UInt16){
        self.brightness = brightness
    }

    public init(stream:DataInputStream){
        brightness = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:brightness)
    }

}
public class SetInfrared : MessagePayload {

    public static let _size = 2
    public let _size = 2
    public let _type:UInt16 = 122

    public var brightness:UInt16

    public init(brightness:UInt16){
        self.brightness = brightness
    }

    public init(stream:DataInputStream){
        brightness = stream.readShort()
    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:brightness)
    }

}
public class SetColorZones : MessagePayload {

    public static let _size = 15
    public let _size = 15
    public let _type:UInt16 = 501

    public var start_index:UInt8
    public var end_index:UInt8
    public var color:HSBK
    public var duration:UInt32
    public var apply:ApplicationRequest?

    public init(start_index:UInt8, end_index:UInt8, color:HSBK, duration:UInt32, apply:ApplicationRequest?){
        self.start_index = start_index
        self.end_index = end_index
        self.color = color
        self.duration = duration
        self.apply = apply
    }

    public init(stream:DataInputStream){
        start_index = stream.readByte()
        end_index = stream.readByte()
        color = HSBK(stream: stream)
        duration = stream.readWord()
        apply = ApplicationRequest(rawValue: stream.readByte())
    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:start_index)
        stream.writeByte(value:end_index)
        color.emit(stream: stream)
        stream.writeWord(value:duration)
        stream.writeByte(value:(apply?.rawValue ?? 0))
    }

}
public class GetColorZones : MessagePayload {

    public static let _size = 2
    public let _size = 2
    public let _type:UInt16 = 502

    public var start_index:UInt8
    public var end_index:UInt8

    public init(start_index:UInt8, end_index:UInt8){
        self.start_index = start_index
        self.end_index = end_index
    }

    public init(stream:DataInputStream){
        start_index = stream.readByte()
        end_index = stream.readByte()
    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:start_index)
        stream.writeByte(value:end_index)
    }

}
public class StateZone : MessagePayload {

    public static let _size = 10
    public let _size = 10
    public let _type:UInt16 = 503

    public var count:UInt8
    public var index:UInt8
    public var color:HSBK

    public init(count:UInt8, index:UInt8, color:HSBK){
        self.count = count
        self.index = index
        self.color = color
    }

    public init(stream:DataInputStream){
        count = stream.readByte()
        index = stream.readByte()
        color = HSBK(stream: stream)
    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:count)
        stream.writeByte(value:index)
        color.emit(stream: stream)
    }

}
public class StateMultiZone : MessagePayload {

    public static let _size = 66
    public let _size = 66
    public let _type:UInt16 = 504

    public var count:UInt8
    public var index:UInt8
    public var color:[HSBK]

    public init(count:UInt8, index:UInt8, color:[HSBK]){
        self.count = count
        self.index = index
        self.color = color
    }

    public init(stream:DataInputStream){
        count = stream.readByte()
        index = stream.readByte()
        color = stream.readArray(size: 8, generator:{stream in return HSBK(stream: stream)})
    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:count)
        stream.writeByte(value:index)
        stream.writeArray(value: color, writer:{color, stream in return color.emit(stream: stream)})
    }

}
public enum Service : UInt8 {
    case UDP = 1
}
public enum PowerState : UInt16 {
    case OFF = 0
    case ON = 65535
}
public enum ApplicationRequest : UInt8 {
    case NO_APPLY = 0
    case APPLY = 1
    case APPLY_ONLY = 2
}
public protocol MessagePayload{
    func emit(stream:DataOutputStream)
    var _size:Int {get}
    var _type:UInt16 {get}
}

public enum MessageType : UInt16 {
    case GetService = 2
    case StateService = 3
    case GetHostInfo = 12
    case StateHostInfo = 13
    case GetHostFirmware = 14
    case StateHostFirmware = 15
    case GetWifiInfo = 16
    case StateWifiInfo = 17
    case GetWifiFirmware = 18
    case StateWifiFirmware = 19
    case GetPower = 20
    case SetPower = 21
    case StatePower = 22
    case GetLabel = 23
    case SetLabel = 24
    case StateLabel = 25
    case GetVersion = 32
    case StateVersion = 33
    case GetInfo = 34
    case StateInfo = 35
    case Acknowledgement = 45
    case GetLocation = 48
    case StateLocation = 50
    case GetGroup = 51
    case StateGroup = 53
    case EchoRequest = 58
    case EchoResponse = 59
    case LightGet = 101
    case LightSetColor = 102
    case LightState = 107
    case LightGetPower = 116
    case LightSetPower = 117
    case LightStatePower = 118
    case GetInfrared = 120
    case StateInfrared = 121
    case SetInfrared = 122
    case SetColorZones = 501
    case GetColorZones = 502
    case StateZone = 503
    case StateMultiZone = 506
}

public let MessagePayloadFromType : [UInt16:(DataInputStream) -> MessagePayload] = [
        2 : { stream in GetService(stream:stream) },
        3 : { stream in StateService(stream:stream) },
        12 : { stream in GetHostInfo(stream:stream) },
        13 : { stream in StateHostInfo(stream:stream) },
        14 : { stream in GetHostFirmware(stream:stream) },
        15 : { stream in StateHostFirmware(stream:stream) },
        16 : { stream in GetWifiInfo(stream:stream) },
        17 : { stream in StateWifiInfo(stream:stream) },
        18 : { stream in GetWifiFirmware(stream:stream) },
        19 : { stream in StateWifiFirmware(stream:stream) },
        20 : { stream in GetPower(stream:stream) },
        21 : { stream in SetPower(stream:stream) },
        22 : { stream in StatePower(stream:stream) },
        23 : { stream in GetLabel(stream:stream) },
        24 : { stream in SetLabel(stream:stream) },
        25 : { stream in StateLabel(stream:stream) },
        32 : { stream in GetVersion(stream:stream) },
        33 : { stream in StateVersion(stream:stream) },
        34 : { stream in GetInfo(stream:stream) },
        35 : { stream in StateInfo(stream:stream) },
        45 : { stream in Acknowledgement(stream:stream) },
        48 : { stream in GetLocation(stream:stream) },
        50 : { stream in StateLocation(stream:stream) },
        51 : { stream in GetGroup(stream:stream) },
        53 : { stream in StateGroup(stream:stream) },
        58 : { stream in EchoRequest(stream:stream) },
        59 : { stream in EchoResponse(stream:stream) },
        101 : { stream in LightGet(stream:stream) },
        102 : { stream in LightSetColor(stream:stream) },
        107 : { stream in LightState(stream:stream) },
        116 : { stream in LightGetPower(stream:stream) },
        117 : { stream in LightSetPower(stream:stream) },
        118 : { stream in LightStatePower(stream:stream) },
        120 : { stream in GetInfrared(stream:stream) },
        121 : { stream in StateInfrared(stream:stream) },
        122 : { stream in SetInfrared(stream:stream) },
        501 : { stream in SetColorZones(stream:stream) },
        502 : { stream in GetColorZones(stream:stream) },
        503 : { stream in StateZone(stream:stream) },
        506 : { stream in StateMultiZone(stream:stream) },
]


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

    public init?(stream:DataInputStream){

        do{
            size = try stream.readShort()
            protocolOriginTagged = try stream.readShort()
            source = try stream.readWord()
            target = try stream.readLong()
            reserved = try stream.readArray(size: 6, generator:{stream in return try stream.readByte()})
            flags = try stream.readByte()
            sequence = try stream.readByte()
            reserved1 = try stream.readLong()
            type = try stream.readShort()
            reserved2 = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            service = Service(rawValue: try stream.readByte())
            port = try stream.readWord()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            signal = try stream.readFloat()
            tx = try stream.readWord()
            rx = try stream.readWord()
            reserved = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            build = try stream.readLong()
            reserved = try stream.readLong()
            version = try stream.readWord()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            signal = try stream.readFloat()
            tx = try stream.readWord()
            rx = try stream.readWord()
            reserved = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            build = try stream.readLong()
            reserved = try stream.readLong()
            version = try stream.readWord()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            level = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            level = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            label = try stream.readString(size: 32)
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            label = try stream.readString(size: 32)
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            vendor = try stream.readWord()
            product = try stream.readWord()
            version = try stream.readWord()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            time = try stream.readLong()
            uptime = try stream.readLong()
            downtime = try stream.readLong()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

    }

    public func emit(stream:DataOutputStream){
    }

}
public class SetLocation : MessagePayload {

    public static let _size = 56
    public let _size = 56
    public let _type:UInt16 = 49

    public var location:[UInt8]
    public var label:String
    public var updated_at:UInt64

    public init(location:[UInt8], label:String, updated_at:UInt64){
        self.location = location
        self.label = label
        self.updated_at = updated_at
    }

    public init?(stream:DataInputStream){

        do{
            location = try stream.readArray(size: 16, generator:{stream in return try stream.readByte()})
            label = try stream.readString(size: 32)
            updated_at = try stream.readLong()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeArray(value: location, writer:{location, stream in return stream.writeByte(value:location)})
        stream.writeString(value: label, size:32)
        stream.writeLong(value:updated_at)
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

    public init?(stream:DataInputStream){

        do{
            location = try stream.readArray(size: 16, generator:{stream in return try stream.readByte()})
            label = try stream.readString(size: 32)
            updated_at = try stream.readLong()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

    }

    public func emit(stream:DataOutputStream){
    }

}
public class SetGroup : MessagePayload {

    public static let _size = 56
    public let _size = 56
    public let _type:UInt16 = 52

    public var group:[UInt8]
    public var label:String
    public var updated_at:UInt64

    public init(group:[UInt8], label:String, updated_at:UInt64){
        self.group = group
        self.label = label
        self.updated_at = updated_at
    }

    public init?(stream:DataInputStream){

        do{
            group = try stream.readArray(size: 16, generator:{stream in return try stream.readByte()})
            label = try stream.readString(size: 32)
            updated_at = try stream.readLong()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeArray(value: group, writer:{group, stream in return stream.writeByte(value:group)})
        stream.writeString(value: label, size:32)
        stream.writeLong(value:updated_at)
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

    public init?(stream:DataInputStream){

        do{
            group = try stream.readArray(size: 16, generator:{stream in return try stream.readByte()})
            label = try stream.readString(size: 32)
            updated_at = try stream.readLong()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            payload = try stream.readArray(size: 64, generator:{stream in return try stream.readByte()})
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            payload = try stream.readArray(size: 64, generator:{stream in return try stream.readByte()})
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            hue = try stream.readShort()
            saturation = try stream.readShort()
            brightness = try stream.readShort()
            kelvin = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            reserved = try stream.readByte()
            color = try throwIfNil(guarded: HSBK(stream: stream))
            duration = try stream.readWord()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:reserved)
        color.emit(stream: stream)
        stream.writeWord(value:duration)
    }

}
public class LightSetWaveform : MessagePayload {

    public static let _size = 21
    public let _size = 21
    public let _type:UInt16 = 103

    public var reserved:UInt8
    public var transient:UInt8
    public var color:HSBK
    public var period:UInt32
    public var cycles:Float32
    public var skew_ratio:Int16
    public var waveform:WaveformType?

    public init(reserved:UInt8, transient:UInt8, color:HSBK, period:UInt32, cycles:Float32, skew_ratio:Int16, waveform:WaveformType?){
        self.reserved = reserved
        self.transient = transient
        self.color = color
        self.period = period
        self.cycles = cycles
        self.skew_ratio = skew_ratio
        self.waveform = waveform
    }

    public init?(stream:DataInputStream){

        do{
            reserved = try stream.readByte()
            transient = try stream.readByte()
            color = try throwIfNil(guarded: HSBK(stream: stream))
            period = try stream.readWord()
            cycles = try stream.readFloat()
            skew_ratio = try stream.readSignedShort()
            waveform = WaveformType(rawValue: try stream.readByte())
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:reserved)
        stream.writeByte(value:transient)
        color.emit(stream: stream)
        stream.writeWord(value:period)
        stream.writeFloat(value:cycles)
        stream.writeSignedShort(value:skew_ratio)
        stream.writeByte(value:(waveform?.rawValue ?? 0))
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

    public init?(stream:DataInputStream){

        do{
            color = try throwIfNil(guarded: HSBK(stream: stream))
            reserved = try stream.readShort()
            power = try stream.readShort()
            label = try stream.readString(size: 32)
            reserved1 = try stream.readLong()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        color.emit(stream: stream)
        stream.writeShort(value:reserved)
        stream.writeShort(value:power)
        stream.writeString(value: label, size:32)
        stream.writeLong(value:reserved1)
    }

}
public class LightSetWaveformOptional : MessagePayload {

    public static let _size = 25
    public let _size = 25
    public let _type:UInt16 = 119

    public var reserved:UInt8
    public var transient:UInt8
    public var color:HSBK
    public var period:UInt32
    public var cycles:Float32
    public var skew_ratio:Int16
    public var waveform:WaveformType?
    public var set_hue:UInt8
    public var set_saturation:UInt8
    public var set_brightness:UInt8
    public var set_kelvin:UInt8

    public init(reserved:UInt8, transient:UInt8, color:HSBK, period:UInt32, cycles:Float32, skew_ratio:Int16, waveform:WaveformType?, set_hue:UInt8, set_saturation:UInt8, set_brightness:UInt8, set_kelvin:UInt8){
        self.reserved = reserved
        self.transient = transient
        self.color = color
        self.period = period
        self.cycles = cycles
        self.skew_ratio = skew_ratio
        self.waveform = waveform
        self.set_hue = set_hue
        self.set_saturation = set_saturation
        self.set_brightness = set_brightness
        self.set_kelvin = set_kelvin
    }

    public init?(stream:DataInputStream){

        do{
            reserved = try stream.readByte()
            transient = try stream.readByte()
            color = try throwIfNil(guarded: HSBK(stream: stream))
            period = try stream.readWord()
            cycles = try stream.readFloat()
            skew_ratio = try stream.readSignedShort()
            waveform = WaveformType(rawValue: try stream.readByte())
            set_hue = try stream.readByte()
            set_saturation = try stream.readByte()
            set_brightness = try stream.readByte()
            set_kelvin = try stream.readByte()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:reserved)
        stream.writeByte(value:transient)
        color.emit(stream: stream)
        stream.writeWord(value:period)
        stream.writeFloat(value:cycles)
        stream.writeSignedShort(value:skew_ratio)
        stream.writeByte(value:(waveform?.rawValue ?? 0))
        stream.writeByte(value:set_hue)
        stream.writeByte(value:set_saturation)
        stream.writeByte(value:set_brightness)
        stream.writeByte(value:set_kelvin)
    }

}
public class LightGetPower : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 116


    public init(){
    }

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            level = try stream.readShort()
            duration = try stream.readWord()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            level = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

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

    public init?(stream:DataInputStream){

        do{
            brightness = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            brightness = try stream.readShort()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            start_index = try stream.readByte()
            end_index = try stream.readByte()
            color = try throwIfNil(guarded: HSBK(stream: stream))
            duration = try stream.readWord()
            apply = ApplicationRequest(rawValue: try stream.readByte())
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            start_index = try stream.readByte()
            end_index = try stream.readByte()
        }catch{
            return nil
        }

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

    public init?(stream:DataInputStream){

        do{
            count = try stream.readByte()
            index = try stream.readByte()
            color = try throwIfNil(guarded: HSBK(stream: stream))
        }catch{
            return nil
        }

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
    public let _type:UInt16 = 506

    public var count:UInt8
    public var index:UInt8
    public var color:[HSBK]

    public init(count:UInt8, index:UInt8, color:[HSBK]){
        self.count = count
        self.index = index
        self.color = color
    }

    public init?(stream:DataInputStream){

        do{
            count = try stream.readByte()
            index = try stream.readByte()
            color = try stream.readArray(size: 8, generator:{stream in return try throwIfNil(guarded: HSBK(stream: stream))})
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:count)
        stream.writeByte(value:index)
        stream.writeArray(value: color, writer:{color, stream in return color.emit(stream: stream)})
    }

}
public class Tile {

    public static let _size = 55
    public let _size = 55
    public let _type:UInt16 = 0

    public var reserved0:UInt16
    public var reserved1:UInt16
    public var reserved2:UInt16
    public var reserved3:UInt16
    public var user_x:Float32
    public var user_y:Float32
    public var width:UInt8
    public var height:UInt8
    public var reserved4:UInt8
    public var device_version_vendor:UInt32
    public var device_version_product:UInt32
    public var device_version_version:UInt32
    public var firmware_build:UInt64
    public var reserved5:UInt64
    public var firmware_version:UInt32
    public var reserved6:UInt32

    public init(reserved0:UInt16, reserved1:UInt16, reserved2:UInt16, reserved3:UInt16, user_x:Float32, user_y:Float32, width:UInt8, height:UInt8, reserved4:UInt8, device_version_vendor:UInt32, device_version_product:UInt32, device_version_version:UInt32, firmware_build:UInt64, reserved5:UInt64, firmware_version:UInt32, reserved6:UInt32){
        self.reserved0 = reserved0
        self.reserved1 = reserved1
        self.reserved2 = reserved2
        self.reserved3 = reserved3
        self.user_x = user_x
        self.user_y = user_y
        self.width = width
        self.height = height
        self.reserved4 = reserved4
        self.device_version_vendor = device_version_vendor
        self.device_version_product = device_version_product
        self.device_version_version = device_version_version
        self.firmware_build = firmware_build
        self.reserved5 = reserved5
        self.firmware_version = firmware_version
        self.reserved6 = reserved6
    }

    public init?(stream:DataInputStream){

        do{
            reserved0 = try stream.readShort()
            reserved1 = try stream.readShort()
            reserved2 = try stream.readShort()
            reserved3 = try stream.readShort()
            user_x = try stream.readFloat()
            user_y = try stream.readFloat()
            width = try stream.readByte()
            height = try stream.readByte()
            reserved4 = try stream.readByte()
            device_version_vendor = try stream.readWord()
            device_version_product = try stream.readWord()
            device_version_version = try stream.readWord()
            firmware_build = try stream.readLong()
            reserved5 = try stream.readLong()
            firmware_version = try stream.readWord()
            reserved6 = try stream.readWord()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeShort(value:reserved0)
        stream.writeShort(value:reserved1)
        stream.writeShort(value:reserved2)
        stream.writeShort(value:reserved3)
        stream.writeFloat(value:user_x)
        stream.writeFloat(value:user_y)
        stream.writeByte(value:width)
        stream.writeByte(value:height)
        stream.writeByte(value:reserved4)
        stream.writeWord(value:device_version_vendor)
        stream.writeWord(value:device_version_product)
        stream.writeWord(value:device_version_version)
        stream.writeLong(value:firmware_build)
        stream.writeLong(value:reserved5)
        stream.writeWord(value:firmware_version)
        stream.writeWord(value:reserved6)
    }

}
public class GetDeviceChain : MessagePayload {

    public static let _size = 0
    public let _size = 0
    public let _type:UInt16 = 701


    public init(){
    }

    public init?(stream:DataInputStream){

    }

    public func emit(stream:DataOutputStream){
    }

}
public class StateDeviceChain : MessagePayload {

    public static let _size = 882
    public let _size = 882
    public let _type:UInt16 = 702

    public var start_index:UInt8
    public var tile_devices:[Tile]
    public var total_count:UInt8

    public init(start_index:UInt8, tile_devices:[Tile], total_count:UInt8){
        self.start_index = start_index
        self.tile_devices = tile_devices
        self.total_count = total_count
    }

    public init?(stream:DataInputStream){

        do{
            start_index = try stream.readByte()
            tile_devices = try stream.readArray(size: 16, generator:{stream in return try throwIfNil(guarded: Tile(stream: stream))})
            total_count = try stream.readByte()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:start_index)
        stream.writeArray(value: tile_devices, writer:{tile_devices, stream in return tile_devices.emit(stream: stream)})
        stream.writeByte(value:total_count)
    }

}
public class SetUserPosition : MessagePayload {

    public static let _size = 11
    public let _size = 11
    public let _type:UInt16 = 703

    public var tile_index:UInt8
    public var reserved:UInt16
    public var user_x:Float32
    public var user_y:Float32

    public init(tile_index:UInt8, reserved:UInt16, user_x:Float32, user_y:Float32){
        self.tile_index = tile_index
        self.reserved = reserved
        self.user_x = user_x
        self.user_y = user_y
    }

    public init?(stream:DataInputStream){

        do{
            tile_index = try stream.readByte()
            reserved = try stream.readShort()
            user_x = try stream.readFloat()
            user_y = try stream.readFloat()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:tile_index)
        stream.writeShort(value:reserved)
        stream.writeFloat(value:user_x)
        stream.writeFloat(value:user_y)
    }

}
public class GetTileState64 : MessagePayload {

    public static let _size = 6
    public let _size = 6
    public let _type:UInt16 = 707

    public var tile_index:UInt8
    public var length:UInt8
    public var reserved:UInt8
    public var x:UInt8
    public var y:UInt8
    public var width:UInt8

    public init(tile_index:UInt8, length:UInt8, reserved:UInt8, x:UInt8, y:UInt8, width:UInt8){
        self.tile_index = tile_index
        self.length = length
        self.reserved = reserved
        self.x = x
        self.y = y
        self.width = width
    }

    public init?(stream:DataInputStream){

        do{
            tile_index = try stream.readByte()
            length = try stream.readByte()
            reserved = try stream.readByte()
            x = try stream.readByte()
            y = try stream.readByte()
            width = try stream.readByte()
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:tile_index)
        stream.writeByte(value:length)
        stream.writeByte(value:reserved)
        stream.writeByte(value:x)
        stream.writeByte(value:y)
        stream.writeByte(value:width)
    }

}
public class StateTileState64 : MessagePayload {

    public static let _size = 517
    public let _size = 517
    public let _type:UInt16 = 711

    public var tile_index:UInt8
    public var reserved:UInt8
    public var x:UInt8
    public var y:UInt8
    public var width:UInt8
    public var colors:[HSBK]

    public init(tile_index:UInt8, reserved:UInt8, x:UInt8, y:UInt8, width:UInt8, colors:[HSBK]){
        self.tile_index = tile_index
        self.reserved = reserved
        self.x = x
        self.y = y
        self.width = width
        self.colors = colors
    }

    public init?(stream:DataInputStream){

        do{
            tile_index = try stream.readByte()
            reserved = try stream.readByte()
            x = try stream.readByte()
            y = try stream.readByte()
            width = try stream.readByte()
            colors = try stream.readArray(size: 64, generator:{stream in return try throwIfNil(guarded: HSBK(stream: stream))})
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:tile_index)
        stream.writeByte(value:reserved)
        stream.writeByte(value:x)
        stream.writeByte(value:y)
        stream.writeByte(value:width)
        stream.writeArray(value: colors, writer:{colors, stream in return colors.emit(stream: stream)})
    }

}
public class SetTileState64 : MessagePayload {

    public static let _size = 522
    public let _size = 522
    public let _type:UInt16 = 715

    public var tile_index:UInt8
    public var length:UInt8
    public var reserved:UInt8
    public var x:UInt8
    public var y:UInt8
    public var width:UInt8
    public var duration:UInt32
    public var colors:[HSBK]

    public init(tile_index:UInt8, length:UInt8, reserved:UInt8, x:UInt8, y:UInt8, width:UInt8, duration:UInt32, colors:[HSBK]){
        self.tile_index = tile_index
        self.length = length
        self.reserved = reserved
        self.x = x
        self.y = y
        self.width = width
        self.duration = duration
        self.colors = colors
    }

    public init?(stream:DataInputStream){

        do{
            tile_index = try stream.readByte()
            length = try stream.readByte()
            reserved = try stream.readByte()
            x = try stream.readByte()
            y = try stream.readByte()
            width = try stream.readByte()
            duration = try stream.readWord()
            colors = try stream.readArray(size: 64, generator:{stream in return try throwIfNil(guarded: HSBK(stream: stream))})
        }catch{
            return nil
        }

    }

    public func emit(stream:DataOutputStream){
        stream.writeByte(value:tile_index)
        stream.writeByte(value:length)
        stream.writeByte(value:reserved)
        stream.writeByte(value:x)
        stream.writeByte(value:y)
        stream.writeByte(value:width)
        stream.writeWord(value:duration)
        stream.writeArray(value: colors, writer:{colors, stream in return colors.emit(stream: stream)})
    }

}
public enum Service : UInt8 {
    case UDP = 1
}
public enum PowerState : UInt16 {
    case OFF = 0
    case ON = 65535
}
public enum WaveformType : UInt8 {
    case SAW = 0
    case SINE = 1
    case HALF_SINE = 2
    case TRIANGLE = 3
    case PULSE = 4
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
    case SetLocation = 49
    case StateLocation = 50
    case GetGroup = 51
    case SetGroup = 52
    case StateGroup = 53
    case EchoRequest = 58
    case EchoResponse = 59
    case LightGet = 101
    case LightSetColor = 102
    case LightSetWaveform = 103
    case LightState = 107
    case LightSetWaveformOptional = 119
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
    case GetDeviceChain = 701
    case StateDeviceChain = 702
    case SetUserPosition = 703
    case GetTileState64 = 707
    case StateTileState64 = 711
    case SetTileState64 = 715
}

public let MessagePayloadFromType : [UInt16:(DataInputStream) -> MessagePayload?] = [
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
    49 : { stream in SetLocation(stream:stream) },
    50 : { stream in StateLocation(stream:stream) },
    51 : { stream in GetGroup(stream:stream) },
    52 : { stream in SetGroup(stream:stream) },
    53 : { stream in StateGroup(stream:stream) },
    58 : { stream in EchoRequest(stream:stream) },
    59 : { stream in EchoResponse(stream:stream) },
    101 : { stream in LightGet(stream:stream) },
    102 : { stream in LightSetColor(stream:stream) },
    103 : { stream in LightSetWaveform(stream:stream) },
    107 : { stream in LightState(stream:stream) },
    119 : { stream in LightSetWaveformOptional(stream:stream) },
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
    701 : { stream in GetDeviceChain(stream:stream) },
    702 : { stream in StateDeviceChain(stream:stream) },
    703 : { stream in SetUserPosition(stream:stream) },
    707 : { stream in GetTileState64(stream:stream) },
    711 : { stream in StateTileState64(stream:stream) },
    715 : { stream in SetTileState64(stream:stream) },
]

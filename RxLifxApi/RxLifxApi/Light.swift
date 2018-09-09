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
import LifxDomain
import RxSwift

public protocol LightSource {
    var tick: Observable<Int> { get }
    var source: UInt32 { get }
    var ioScheduler: SchedulerType { get }
    var mainScheduler: SchedulerType { get }

    func extensionOf<E>() -> E? where E: LightServiceExtension

    var messages: Observable<SourcedMessage> { get }
    func sendMessage(light: Light?, data: Data) -> Bool
}

public protocol LightsChangeDispatcher {
    func notifyChange(light: Light, property: LightPropertyName, oldValue: Any?, newValue: Any?)

    func lightAdded(light: Light)
}

public enum LightPropertyName{
    case color
    case zones
    case power
    case label
    case hostFirmware
    case wifiFirmware
    case version
    case group
    case location
    case infraredBrightness
    case reachable
}

public class Light: Equatable {
    private var disposeBag: CompositeDisposable = CompositeDisposable()
    public let lightSource: LightSource
    public let lightChangeDispatcher: LightsChangeDispatcher

    public let target: UInt64
    public let id: String
    public var addr: sockaddr?

    public var sequence: UInt8 = 0

    public static let refreshMutablePropertiesTickModulo = 20

    public static let productsSupportingMultiZone = [0, 31, 32, 38]

    public static let productsSupportingInfrared = [0, 29, 30, 45, 46]

    public static let productsSupportingTile = [55]

    public lazy var color:LightProperty<HSBK> = { LightProperty<HSBK>(light: self, name: .color) }()

    public lazy var zones:LightProperty<MultiZones> = { LightProperty<MultiZones>(light: self, name: .zones) }()

    public lazy var power: LightProperty<UInt16> = { LightProperty<UInt16>(light: self, name: .power) }()

    public lazy var label: LightProperty<String> = { LightProperty<String>(light: self, name: .label) }()

    public lazy var hostFirmware: LightProperty<FirmwareVersion> = { LightProperty<FirmwareVersion>(light: self, name: .hostFirmware) }()

    public lazy var wifiFirmware: LightProperty<FirmwareVersion> = { LightProperty<FirmwareVersion>(light: self, name: .wifiFirmware) }()

    public lazy var version: LightProperty<LightVersion> = { LightProperty<LightVersion>(light: self, name: .version) }()

    public lazy var group: LightProperty<LightGroup> = { LightProperty<LightGroup>(light: self, name: .group, defaultValue: LightGroup.defaultGroup) }()

    public lazy var location: LightProperty<LightLocation> = { LightProperty<LightLocation>(light: self, name: .location, defaultValue: LightLocation.defaultLocation) }()

    public lazy var infraredBrightness: LightProperty<UInt16> = { LightProperty<UInt16>(light: self, name: .infraredBrightness) }()

    public lazy var reachable: LightProperty<Bool> = { LightProperty<Bool>(light: self, name: .reachable, defaultValue: false) }()

    public var lastSeenAt:Date = Date.distantPast

    public var powerState: Bool {
        get {
            return power.value ?? 0 == 0 ? false : true
        }
    }

    public var supportsMultiZone: Bool {
        get {
            return Light.productsSupportingMultiZone.contains(Int(version.value?.product ?? 0))
        }
    }

    public var supportsInfrared: Bool {
        get {
            return Light.productsSupportingInfrared.contains(Int(version.value?.product ?? 0))
        }
    }

    public var supportsTile: Bool {
        get {
            return Light.productsSupportingTile.contains(Int(version.value?.product ?? 0))
        }
    }

    public init(id: UInt64, lightSource: LightSource, lightChangeDispatcher: LightsChangeDispatcher) {
        self.lightSource = lightSource
        self.lightChangeDispatcher = lightChangeDispatcher
        self.target = id
        self.id = id.toLightId()
    }

    public func dispose() {
        disposeBag.dispose()
    }

    public func getNextSequence() -> UInt8 {
        sequence = sequence &+ 1
        return sequence
    }

    public func updateReachability() {
        reachable.updateFromClient(value: lastSeenAt.timeIntervalSinceNow > -11 )
    }

    public func attach(observable: GroupedObservable<UInt64, SourcedMessage>) -> Light{

        dispose()
        disposeBag = CompositeDisposable()

        _ = disposeBag.insert(observable.subscribe(onNext: {
            (message: SourcedMessage) in
            self.addr = message.sourceAddress

            self.lastSeenAt = Date()
            self.updateReachability()

            LightMessageHandler.handleMessage(light: self, message: message.message)
        }))

        _ = disposeBag.insert(lightSource.tick.subscribe(onNext: {
            c in
            self.pollState()
            self.updateReachability()
            if(c % Light.refreshMutablePropertiesTickModulo == 0){
                self.pollMutableProperties()
            }
            return
        }))

        pollProperties()
        pollState()
        return self
    }

    private func pollState(){
        LightGetCommand.create(light: self).fireAndForget()
        if(supportsMultiZone) {
            MultiZoneGetColorZonesCommand.create(light: self, startIndex: UInt8.min, endIndex: UInt8.max).fireAndForget()
        }
        if(supportsInfrared) {
            LightGetInfraredCommand.create(light: self).fireAndForget()
        }
    }

    private func pollProperties(){
        DeviceGetHostFirmwareCommand.create(light: self).fireAndForget()
        DeviceGetWifiFirmwareCommand.create(light: self).fireAndForget()
        DeviceGetVersionCommand.create(light: self).fireAndForget()
        pollMutableProperties()
    }

    private func pollMutableProperties(){
        DeviceGetGroupCommand.create(light: self).fireAndForget()
        DeviceGetLocationCommand.create(light: self).fireAndForget()
    }

    public static func == (lhs: Light, rhs: Light) -> Bool {
        return lhs.target == rhs.target
    }
}

public class LightProperty<T:Equatable> {

    private var _value: T? = nil
    public var value: T? {
        get {
            return _value
        }
    }

    private let light: Light
    private let name: LightPropertyName
    private var updatedFromClientAt: Date = Date.distantPast
    private let localValueValidityWindow: TimeInterval = -2

    init(light: Light, name: LightPropertyName, defaultValue: T? = nil) {
        self.light = light
        self.name = name
        self._value = defaultValue
    }

    public func updateFromClient(value: T?) {
        if (_value != value) {
            let oldValue = _value
            _value = value
            updatedFromClientAt = Date()
            light.lightChangeDispatcher.notifyChange(light: light, property: name, oldValue: oldValue, newValue: value)
        }
    }

    public func updateFromDevice(value: T?) {
        if (_value != value && !hasRecentlyUpdatedFromClient()) {
            let oldValue = _value
            _value = value
            light.lightChangeDispatcher.notifyChange(light: light, property: name, oldValue: oldValue, newValue: value)
        }
    }

    public func hasRecentlyUpdatedFromClient() -> Bool {
        return updatedFromClientAt.timeIntervalSinceNow > localValueValidityWindow
    }
}

public class FirmwareVersion: Equatable{
    public let build: UInt64
    public let version: UInt32

    init(build: UInt64, version: UInt32){
        self.build = build
        self.version = version
    }

    public static func == (lhs: FirmwareVersion, rhs: FirmwareVersion) -> Bool {
        return lhs.build == rhs.build && lhs.version == rhs.version
    }
}

public class LightVersion: Equatable{
    public let vendor: UInt32
    public let product: UInt32
    public let version: UInt32

    init(vendor: UInt32, product: UInt32, version: UInt32){
        self.vendor = vendor
        self.product = product
        self.version = version
    }

    public static func == (lhs: LightVersion, rhs: LightVersion) -> Bool {
        return lhs.vendor == rhs.vendor && lhs.product == rhs.product && lhs.version == rhs.version
    }
}

public class LightLocation: Equatable{
    static let defaultLocation = LightLocation(id: Array(repeating: 48, count: 8), label: "", updatedAt: Date(timeIntervalSince1970: 0))

    public let id: [UInt8]
    public let label: String
    public let updatedAt: Date
    public lazy var identifier: String = String(describing: id.map({ UnicodeScalar($0) }))

    init(id: [UInt8], label:String, updatedAt: Date){
        self.id = id
        self.label = label
        self.updatedAt = updatedAt
    }

    public static func == (lhs: LightLocation, rhs: LightLocation) -> Bool {
        return lhs.id == rhs.id && lhs.label == rhs.label && lhs.updatedAt == rhs.updatedAt
    }
}

public class LightGroup: Equatable{
    static let defaultGroup = LightGroup(id: Array(repeating: 48, count: 8), label: "", updatedAt: Date(timeIntervalSince1970: 0))

    public let id: [UInt8]
    public let label: String
    public let updatedAt: Date
    public lazy var identifier: String = String(describing: id.map({ UnicodeScalar($0) }))

    init(id: [UInt8], label:String, updatedAt: Date){
        self.id = id
        self.label = label
        self.updatedAt = updatedAt
    }

    public static func == (lhs: LightGroup, rhs: LightGroup) -> Bool {
        return lhs.id == rhs.id && lhs.label == rhs.label && lhs.updatedAt == rhs.updatedAt
    }
}

public class MultiZones: Equatable{
    public var colors:[HSBK] = []

    public static func == (lhs: MultiZones, rhs: MultiZones) -> Bool {
        return false
    }

    func dimTo(_ count: Int) {
        while(colors.count < count){
            colors.append(HSBK(hue: 0, saturation:0, brightness: 0, kelvin: 0))
        }
        while(colors.count > count){
            colors.removeLast()
        }
    }
}
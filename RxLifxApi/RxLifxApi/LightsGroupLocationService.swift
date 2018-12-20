/*

Copyright 2018 Florian Sprenger

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

public class LightsGroup {
    public let identifier: String

    public let location: LightsLocation

    public private(set) var lights: [Light] = []

    init(identifier: String, location: LightsLocation) {
        self.identifier = identifier
        self.location = location
    }

    public var label: String {
        return lights.reduce((Date(timeIntervalSince1970: 0), "")) { (result, light: Light) in
            if let group = light.group.value {
                if (result.0 > group.updatedAt) {
                    return result
                } else {
                    return (group.updatedAt, group.label)
                }
            } else {
                return result
            }
        }.1
    }

    fileprivate func add(light: Light) {
        lights.append(light)
    }

    fileprivate func remove(light: Light) {
        if let index = lights.index(of: light) {
            lights.remove(at: index)
        }
    }
}

public class LightsLocation {
    fileprivate var groupsById: [String: LightsGroup] = [:]
    public let identifier: String

    public var groups: Dictionary<String, LightsGroup>.Values {
        get {
            return groupsById.values
        }
    }

    init(identifier: String) {
        self.identifier = identifier
    }

    public var label: String {
        return groupsById.flatMap { (_, group) in
            group.lights
        }.reduce((Date(timeIntervalSince1970: 0), "")) { (result, light: Light) in
            if let location = light.location.value {
                if (result.0 > location.updatedAt) {
                    return result
                } else {
                    return (location.updatedAt, location.label)
                }
            } else {
                return result
            }
        }.1
    }

    fileprivate func add(group: LightsGroup) {
        groupsById[group.identifier] = group
    }

    fileprivate func remove(group: LightsGroup) {
        groupsById.removeValue(forKey: group.identifier)
    }
}

public protocol GroupLocationChangeDispatcher {
    func groupAdded(group: LightsGroup)
    func groupRemoved(group: LightsGroup)
    func groupChanged(group: LightsGroup)
    func locationAdded(location: LightsLocation)
    func locationRemoved(location: LightsLocation)
    func locationChanged(location: LightsLocation)
}

public class LightsGroupLocationService: LightsChangeDispatcher, LightServiceExtension {


    private var locationsById: [String: LightsLocation] = [:]

    private let lightsChangeDispatcher: LightsChangeDispatcher

    private var groupLocationChangeDispatcher: GroupLocationChangeDispatcher?

    public var locations: Dictionary<String, LightsLocation>.Values {
        get{
            return locationsById.values
        }
    }

    public required init(wrappedChangeDispatcher: LightsChangeDispatcher) {
        self.lightsChangeDispatcher = wrappedChangeDispatcher
    }

    public func setListener( groupLocationChangeDispatcher: GroupLocationChangeDispatcher?){
        self.groupLocationChangeDispatcher = groupLocationChangeDispatcher
    }

    public func start(source: LightSource) {

    }

    public func stop() {
        locationsById = [:]
    }

    public func groupOf(light: Light) -> LightsGroup? {
        return locationsById[light.location.value?.identifier ?? ""]?.groupsById[light.group.value?.identifier ?? ""]
    }

    public func locationOf(light: Light) -> LightsLocation? {
        return locationsById[light.location.value?.identifier ?? ""]
    }

    public func notifyChange(light: Light, property: LightPropertyName, oldValue: Any?, newValue: Any?) {
        switch (property) {
        case LightPropertyName.group:
            if let locationId = light.location.value?.identifier, let groupId = (oldValue as? LightGroup)?.identifier, let location = locationsById[locationId], let group = location.groupsById[groupId] {
                removeLightFromLocationGroup(light: light, location: location, group: group)
            }
            addLightToLocationAndGroup(light: light, location: light.location.value, group: newValue as? LightGroup)
            break;
        case LightPropertyName.location:
            if let locationId = (oldValue as? LightLocation)?.identifier, let groupId = light.location.value?.identifier, let location = locationsById[locationId], let group = location.groupsById[groupId] {
                removeLightFromLocationGroup(light: light, location: location, group: group)
            }
            addLightToLocationAndGroup(light: light, location: newValue as? LightLocation, group: light.group.value )
            break;
        default:
            break;
        }
        lightsChangeDispatcher.notifyChange(light: light, property: property, oldValue: oldValue, newValue: newValue)
    }

    public func lightAdded(light: Light) {
        addLightToLocationAndGroup(light: light, location: light.location.value, group: light.group.value)
        lightsChangeDispatcher.lightAdded(light: light)
    }

    private func removeLightFromLocationGroup(light: Light, location: LightsLocation, group: LightsGroup) {
        group.remove(light: light)
        groupLocationChangeDispatcher?.groupChanged(group: group)
        if (group.lights.count == 0) {
            removeGroupFrom(location: location, group: group)
        }
        if (location.groupsById.count == 0) {
            remove(location: location)
        }
    }

    private func addLightToLocationAndGroup(light: Light, location: LightLocation?, group: LightGroup?) {
        if let locationId = location?.identifier, let groupId = group?.identifier {
            let location: LightsLocation = locationsById[locationId] ?? add(location: LightsLocation(identifier: locationId))
            let group: LightsGroup = location.groupsById[groupId] ?? addGroupTo(location: location, group: LightsGroup(identifier: groupId, location: location))
            group.add(light: light)
            groupLocationChangeDispatcher?.groupChanged(group: group)
            groupLocationChangeDispatcher?.locationChanged(location: location)
        }
    }

    private func addGroupTo(location: LightsLocation, group: LightsGroup) -> LightsGroup {
        location.add(group: group)
        groupLocationChangeDispatcher?.groupAdded(group: group)
        groupLocationChangeDispatcher?.locationChanged(location: location)
        return group
    }

    private func removeGroupFrom(location: LightsLocation, group: LightsGroup) {
        location.remove(group: group)
        groupLocationChangeDispatcher?.groupRemoved(group: group)
    }

    private func add(location: LightsLocation) -> LightsLocation {
        locationsById[location.identifier] = location
        groupLocationChangeDispatcher?.locationAdded(location: location)
        return location
    }

    private func remove(location: LightsLocation) {
        locationsById.removeValue(forKey: location.identifier)
        groupLocationChangeDispatcher?.locationRemoved(location: location)
    }
}

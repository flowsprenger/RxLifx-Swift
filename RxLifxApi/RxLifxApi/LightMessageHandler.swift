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

public class LightMessageHandler {

    public class func handleMessage(light:Light, message:Message){

        switch(message.header.type){
        case MessageType.StateService.rawValue:
            break
        case MessageType.StateHostInfo.rawValue:
            break
        case MessageType.StateHostFirmware.rawValue:
            let stateHostFirmware = message.payload as! StateHostFirmware
            light.hostFirmware.updateFromDevice(value: FirmwareVersion(build: stateHostFirmware.build, version: stateHostFirmware.version))
            break
        case MessageType.StateWifiInfo.rawValue:
            break
        case MessageType.StateWifiFirmware.rawValue:
            let stateWifiFirmware = message.payload as! StateWifiFirmware
            light.wifiFirmware.updateFromDevice(value: FirmwareVersion(build: stateWifiFirmware.build, version: stateWifiFirmware.version))
            break
        case MessageType.StatePower.rawValue:
            let statePower = message.payload as! StatePower
            light.power.updateFromDevice(value: statePower.level)
            break
        case MessageType.StateLabel.rawValue:
            let stateLabel = message.payload as! StateLabel
            light.label.updateFromDevice(value: stateLabel.label)
            break
        case MessageType.StateVersion.rawValue:
            let stateVersion = message.payload as! StateVersion
            light.version.updateFromDevice(value: LightVersion(vendor: stateVersion.vendor, product: stateVersion.product, version: stateVersion.version))
            break
        case MessageType.StateInfo.rawValue:
            break
        case MessageType.Acknowledgement.rawValue:
            break
        case MessageType.StateLocation.rawValue:
            let stateLocation = message.payload as! StateLocation
            light.location.updateFromDevice(value: LightLocation(id: stateLocation.location, label: stateLocation.label, updatedAt: Date(timeIntervalSince1970: Double(stateLocation.updated_at / 1000000000))))
            break
        case MessageType.StateGroup.rawValue:
            let stateGroup = message.payload as! StateGroup
            light.group.updateFromDevice(value: LightGroup(id: stateGroup.group, label: stateGroup.label, updatedAt: Date(timeIntervalSince1970: Double(stateGroup.updated_at / 1000000000))))
            break
        case MessageType.LightState.rawValue:
            let lightState = message.payload as! LightState
            light.color.updateFromDevice(value: lightState.color)
            light.power.updateFromDevice(value: lightState.power)
            light.label.updateFromDevice(value: lightState.label)
            break
        case MessageType.LightStatePower.rawValue:
            let statePower = message.payload as! LightStatePower
            light.power.updateFromDevice(value: statePower.level)
            break
        case MessageType.StateInfrared.rawValue:
            let stateInfrared = message.payload as! StateInfrared
            light.infraredBrightness.updateFromDevice(value: stateInfrared.brightness)
            break
        case MessageType.StateMultiZone.rawValue:
            if(!light.zones.hasRecentlyUpdatedFromClient()) {
                let stateMultiZone = message.payload as! StateMultiZone
                let zones = light.zones.value ?? MultiZones()
                zones.dimTo(Int(stateMultiZone.count))
                var i = 0
                for z in Int(stateMultiZone.index) ..< min(Int(stateMultiZone.index) + stateMultiZone.color.count, light.zones.value?.colors.count ?? 0) {
                    zones.colors[z] = stateMultiZone.color[i]
                    i += 1
                }
                light.zones.updateFromDevice(value: zones)
            }
            break
        case MessageType.StateZone.rawValue:
            if(!light.zones.hasRecentlyUpdatedFromClient()) {
                let stateZone = message.payload as! StateZone
                let zones = light.zones.value ?? MultiZones()
                zones.dimTo(Int(stateZone.count))
                zones.colors[Int(stateZone.index)] = stateZone.color
                light.zones.updateFromDevice(value: zones)
            }
        default:
            break
        }
    }
}

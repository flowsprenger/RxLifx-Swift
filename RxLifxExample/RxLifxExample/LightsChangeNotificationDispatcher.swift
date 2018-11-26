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
import RxLifxApi

class LightsChangeNotificationDispatcher: LightsChangeDispatcher {

    static let LightChangedNotification: Notification.Name = Notification.Name("LightChangedNotification")
    static let LightAddedNotification: Notification.Name = Notification.Name("LightAddedNotification")

    let notificationCenter: NotificationCenter = NotificationCenter.default

    func notifyChange(light: Light, property: LightPropertyName, oldValue: Any?, newValue: Any?) {
        notificationCenter.post(name: LightsChangeNotificationDispatcher.LightChangedNotification, object: light)
    }

    func lightAdded(light: Light){
        notificationCenter.post(name: LightsChangeNotificationDispatcher.LightAddedNotification, object: light)
    }

}

class TileChangeDispatcher: TileServiceListener{
    func tileAdded(tile: TileLight) {
        print("tile added \(tile.light.id)")
    }

    func chainUpdated(tile: TileLight) {
        print("chain updated \(tile.light.id)")
    }

    func deviceUpdated(tile: TileLight, device: TileDevice) {
        print("device updated \(tile.light.id) \(device.index)")
    }
}

class LightsGroupLocationChangeNotificationDispatcher: GroupLocationChangeDispatcher {
    func groupAdded(group: LightsGroup) {
        print("group added \(group.label)")
    }

    func groupRemoved(group: LightsGroup) {
        print("group removed \(group.label)")
    }

    func groupChanged(group: LightsGroup) {
        print("group changed \(group.label)")
    }

    func locationAdded(location: LightsLocation) {
        print("location added \(location.label)")
    }

    func locationRemoved(location: LightsLocation) {
        print("location removed \(location.label)")
    }

    func locationChanged(location: LightsLocation) {
        print("location changed \(location.label)")
    }
}


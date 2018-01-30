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
import RxSwift

public class MultiZoneSetColorZonesCommand {
    public class func create(light: Light, startIndex: UInt8, endIndex: UInt8, color:HSBK, duration: TimeInterval, apply:ApplicationRequest, ackRequired: Bool = false, responseRequired: Bool = false) -> Observable<Result<AnyObject>> {
        let message = Message.createMessageWithPayload(SetColorZones(start_index: startIndex, end_index: endIndex, color: color, duration: UInt32(duration * 1000), apply: apply), target: light.target, source: light.lightSource.source)
        message.header.ackRequired = ackRequired
        message.header.responseRequired = responseRequired
        return AsyncLightCommand.sendMessage(lightSource: light.lightSource, light: light, message: message, sideEffect: {
            let zones = light.zones.value ?? MultiZones()
            for z in Int(startIndex)...min(Int(endIndex), zones.colors.count) {
                zones.colors[z] = color
            }
            light.zones.updateFromDevice(value: zones)
        })
    }
}

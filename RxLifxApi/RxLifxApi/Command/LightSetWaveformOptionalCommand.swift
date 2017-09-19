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

public class LightSetWaveformOptionalCommand {
    public class func create(light: Light, transient: Bool, color: HSBK, period: UInt32, cycles: Float32, skew_ratio: Int16, waveform: WaveformType, set_hue: Bool, set_saturation: Bool, set_brightness: Bool, set_kelvin: Bool, ackRequired: Bool = false, responseRequired: Bool = false) -> Observable<Result<LightStatePower>> {
        let message = Message.createMessageWithPayload(LightSetWaveformOptional(reserved: 0, transient: transient ? 1 : 0, color: color, period: period, cycles: cycles, skew_ratio: skew_ratio, waveform: waveform, set_hue: set_hue ? 1 : 0, set_saturation: set_saturation ? 1: 0, set_brightness: set_brightness ? 1 : 0, set_kelvin: set_kelvin ? 1 :0), target: light.target, source: light.lightSource.source)
        message.header.ackRequired = ackRequired
        message.header.responseRequired = responseRequired
        return AsyncLightCommand.sendMessage(lightSource: light.lightSource, light: light, message: message, sideEffect: {})
    }
}

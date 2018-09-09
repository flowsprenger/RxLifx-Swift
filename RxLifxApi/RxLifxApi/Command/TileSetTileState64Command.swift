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
import RxSwift

public class TileSetTileState64Command {

    public class func create(tileService: LightTileService, light: Light, startIndex: UInt8 = 0, length: UInt8 = 255, x: UInt8 = 0, y: UInt8 = 0, width: UInt8 = 8, duration: TimeInterval, colors: [HSBK], ackRequired: Bool = false, responseRequired: Bool = false) -> Observable<Result<StateTileState64>> {
        let message = Message.createMessageWithPayload(SetTileState64(tile_index: UInt8(startIndex), length: length, reserved: 0, x: x, y: y, width: width, duration: UInt32(duration * 1000), colors: colors), target: light.target, source: light.lightSource.source)
        message.header.ackRequired = ackRequired
        message.header.responseRequired = responseRequired
        return AsyncLightCommand.sendMessage(lightSource: light.lightSource, light: light, message: message) {
            if let tile = tileService.tileOf(light: light){
                for tileIndex in Int(startIndex) ..< min(tile.chain.count, Int(startIndex) + Int(length)) {
                    let device = tile.chain[tileIndex]
                    tileService.updateTile(tile: tile, device: device, setX: Int(x), setY: Int(y), width: Int(width), colors: colors)
                }
            }
        }
    }

    public class func create(light: Light, startIndex: UInt8 = 0, length: UInt8 = 255, x: UInt8 = 0, y: UInt8 = 0, width: UInt8 = 8, duration: TimeInterval, colors: [HSBK], ackRequired: Bool = false, responseRequired: Bool = false) -> Observable<Result<StateTileState64>> {
        let message = Message.createMessageWithPayload(SetTileState64(tile_index: UInt8(startIndex), length: length, reserved: 0, x: x, y: y, width: width, duration: UInt32(duration * 1000), colors: colors), target: light.target, source: light.lightSource.source)
        message.header.ackRequired = ackRequired
        message.header.responseRequired = responseRequired
        return AsyncLightCommand.sendMessage(lightSource: light.lightSource, light: light, message: message)
    }
}

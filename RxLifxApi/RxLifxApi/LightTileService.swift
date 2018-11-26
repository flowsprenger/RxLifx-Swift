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

public class TileDevice {
    public let index: UInt8
    public var userX: Float32
    public var userY: Float32
    public var width: UInt8
    public var height: UInt8
    public var colors: [HSBK] = []

    init(index: UInt8, userX: Float32, userY: Float32, width: UInt8, height: UInt8,  colors: [HSBK]) {
        self.index = index
        self.userX = userX
        self.userY = userY
        self.width = width
        self.height = height
        self.colors = colors
    }
}

public class TileLight {

    public let light: Light
    public var chain: [TileDevice] = []

    init(light: Light) {
        self.light = light
    }
}

public protocol TileServiceListener {
    func tileAdded(tile: TileLight)
    func chainUpdated(tile: TileLight)
    func deviceUpdated(tile: TileLight, device: TileDevice)
}

public class LightTileService: LightServiceExtension {

    private var tilesById: [UInt64: TileLight] = [:]

    public var tiles: Dictionary<UInt64, TileLight>.Values {
        get{
            return tilesById.values
        }
    }

    private let changeDispatcher: LightsChangeDispatcher

    private let disposables = CompositeDisposable()

    private var listener: TileServiceListener?

    public required init(wrappedChangeDispatcher: LightsChangeDispatcher) {
        self.changeDispatcher = wrappedChangeDispatcher
    }

    public func start(source: LightSource) {
        _ = disposables.insert(source.tick.subscribe { it in

            self.tilesById.forEach { (_, tile) in
                TileGetTileState64Command.create(light: tile.light).fireAndForget()
            }
            if (it.element! % 12 == 0) {
                self.tilesById.forEach { (_, tile) in
                    TileGetDeviceChainCommand.create(light: tile.light).fireAndForget()
                }
            }
        })

        _ = disposables.insert(source.messages.observeOn(source.mainScheduler).filter {
            self.tilesById[$0.message.header.target] != nil
        }.subscribe(onNext: { message in
            switch (message.message.header.type) {
            case MessageType.StateDeviceChain.rawValue:
                if let tile = self.tilesById[message.message.header.target], let payload = message.message.payload as? StateDeviceChain {
                    var tileChanged = false
                    let devices = stride(from: 0, to: Int(payload.total_count), by: 1).map { index -> TileDevice in
                        let messageIndex = Int(index - Int(payload.start_index))
                        if (messageIndex > -1 && messageIndex < 16) {
                            let device = payload.tile_devices[messageIndex]
                            if tile.chain.count > Int(index) {
                                let existingDevice = tile.chain[Int(index)]
                                if (existingDevice.userX != device.user_x
                                        || existingDevice.userY != device.user_y
                                        || existingDevice.width != device.width
                                        || existingDevice.height != device.height) {

                                    tileChanged = true

                                    existingDevice.userX = device.user_x
                                    existingDevice.userY = device.user_y
                                    existingDevice.width = device.width
                                    existingDevice.height = device.height
                                }
                                return existingDevice
                            } else {
                                tileChanged = true
                                return TileDevice(
                                        index: UInt8(index),
                                        userX: device.user_x,
                                        userY: device.user_y,
                                        width: device.width,
                                        height: device.height,
                                        colors: Array(repeating: HSBK(hue: 0, saturation:0, brightness: 0, kelvin: 0), count: Int(device.width * device.height))
                                )
                            }
                        } else {

                            tileChanged = true
                            if tile.chain.count > Int(index) {
                                return tile.chain[Int(index)]
                            } else {
                                return TileDevice(
                                        index: UInt8(index),
                                        userX: 0,
                                        userY: 0,
                                        width: 0,
                                        height: 0,
                                        colors: []
                                )
                            }
                        }
                    }
                    if (tileChanged) {
                        tile.chain = devices
                        self.listener?.chainUpdated(tile: tile)
                    }
                }
                break;

            case MessageType.StateTileState64.rawValue:
                if let tile = self.tilesById[message.message.header.target], let payload = message.message.payload as? StateTileState64 {
                    if (tile.chain.count > payload.tile_index) {
                        let device = tile.chain[Int(payload.tile_index)]
                        self.updateTile(tile: tile, device: device, setX: Int(payload.x), setY: Int(payload.y), width: Int(payload.width), colors: payload.colors)
                    }
                }
                break;
            default:
                break;

            }
        }))
    }

    internal func updateTile(tile: TileLight, device: TileDevice, setX: Int, setY: Int, width: Int, colors: Array<HSBK>) {
        var colorsChanged = false

        for x in setX..<min(8, setX + width) {
            for y in setY..<min(8, setY + colors.count / width) {
                let existingColor = device.colors[y * 8 + x]
                let newColor = colors[(y - setY) * width + x - setX]
                if (existingColor != newColor) {
                    device.colors[y * 8 + x] = newColor
                    colorsChanged = true
                }
            }
        }

        if (colorsChanged) {
            listener?.deviceUpdated(tile: tile, device: device)
        }
    }

    public func stop() {
        disposables.dispose()
        tilesById = [:]
    }

    public func setListener(listener: TileServiceListener?) {
        self.listener = listener
    }

    public func tileOf(light: Light) -> TileLight? {
        return tilesById.first{ $0.value.light == light }?.value
    }

    public func notifyChange(light: Light, property: LightPropertyName, oldValue: Any?, newValue: Any?) {
        if (property == LightPropertyName.version && light.supportsTile) {
            trackTile(light: light)
        }
        changeDispatcher.notifyChange(light: light, property: property, oldValue: oldValue, newValue: newValue)
    }

    public func lightAdded(light: Light) {
        if (light.supportsTile) {
            trackTile(light: light)
        }
        changeDispatcher.lightAdded(light: light)
    }

    private func trackTile(light: Light) {
        if (tilesById[light.target] == nil) {
            let tile = TileLight(light: light)
            tilesById[light.target] = tile
            TileGetDeviceChainCommand.create(light: light).fireAndForget()
            TileGetTileState64Command.create(light: light).fireAndForget()
            listener?.tileAdded(tile: tile)
        }
    }

}

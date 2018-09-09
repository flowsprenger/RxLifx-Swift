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

import UIKit
import LifxDomain
import RxLifxApi

class DetailViewController: UIViewController {

    @IBOutlet var background: UIView!

    @IBOutlet weak var powerSwitch: UISwitch!

    @IBOutlet weak var labelTextField: UITextField!

    @IBOutlet weak var hueSlider: UISlider!

    @IBOutlet weak var saturationSlider: UISlider!

    @IBOutlet weak var brightnessSlider: UISlider!

    @IBOutlet weak var tileColorButton: UIButton!
    
    @IBOutlet weak var groupNameLabel: UILabel!
    
    @IBOutlet weak var locationNameLabel: UILabel!
    
    private var viewHasInitialized: Bool = false

    @objc func configureView() {
        if let detail = self.detailItem, viewHasInitialized {

            title = detail.label.value ?? detail.id

            labelTextField.text = detail.label.value ?? detail.id
            powerSwitch.setOn(detail.powerState, animated: false)

            if let color = detail.color.value {
                hueSlider.value = Float(color.hue) / Float(UInt16.max)

                saturationSlider.value = Float(color.saturation) / Float(UInt16.max)

                brightnessSlider.value = Float(color.brightness) / Float(UInt16.max)

                background.backgroundColor = UIColor(cgColor: color.toCGColor())
            }

            if (detail.supportsTile) {
                tileColorButton.isHidden = false
            } else {
                tileColorButton.isHidden = true
            }

            if let groupService: LightsGroupLocationService = detail.lightSource.extensionOf(){
                locationNameLabel.text = groupService.locationOf(light: detail)?.label
                groupNameLabel.text = groupService.groupOf(light: detail)?.label
            }else{
                locationNameLabel.text = "???"
                groupNameLabel.text = "???"
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        viewHasInitialized = true
        self.configureView()
    }

    var detailItem: Light? {
        willSet {
            if let _ = detailItem {
                NotificationCenter.default.removeObserver(self)
            }
        }
        didSet {
            if let light = detailItem {
                NotificationCenter.default.addObserver(self, selector: #selector(configureView), name: LightsChangeNotificationDispatcher.LightChangedNotification, object: light)
            }
            self.configureView()
        }
    }

    func hsbkChanged() {
        if let light = detailItem {
            let _ = LightSetColorCommand.create(light: light, color: HSBK(hue: UInt16(hueSlider.value * Float(UInt16.max)), saturation: UInt16(saturationSlider.value * Float(UInt16.max)), brightness: UInt16(brightnessSlider.value * Float(UInt16.max)), kelvin: 0), duration: 0).fireAndForget()
        }
    }

    @IBAction func hueChanged(_ sender: Any) {
        hsbkChanged()
    }

    @IBAction func saturationChanged(_ sender: Any) {
        hsbkChanged()
    }

    @IBAction func brightnessChanged(_ sender: Any) {
        hsbkChanged()
    }

    @IBAction func powerStateChanged(_ sender: Any) {
        if let light = detailItem {
            LightSetPowerCommand.create(light: light, status: powerSwitch.isOn, duration: 0).fireAndForget()
        }
    }

    @IBAction func blinkRed(_ sender: Any) {
        if let light = detailItem {
            LightSetWaveformCommand.create(light: light, transient: true, color: HSBK(hue: UInt16(0 * Float(UInt16.max)), saturation: UInt16(1 * Float(UInt16.max)), brightness: UInt16(1 * Float(UInt16.max)), kelvin: 0), period: 1000, cycles: 1, skew_ratio: Int16(0.5 * Double(Int16.max)), waveform: WaveformType.SINE).fireAndForget()
        }
    }

    @IBAction func blinkBrightness(_ sender: Any) {
        if let light = detailItem {
            LightSetWaveformOptionalCommand.create(light: light, transient: true, color: HSBK(hue: UInt16(1 * Float(UInt16.max)), saturation: UInt16(0.23 * Float(UInt16.max)), brightness: UInt16(1 * Float(UInt16.max)), kelvin: 0), period: 1000, cycles: 1, skew_ratio: Int16(0.5 * Double(Int16.max)), waveform: WaveformType.SAW, set_hue: false, set_saturation: false, set_brightness: true, set_kelvin: false).fireAndForget()
        }
    }

    @IBAction func colorTile(_ sender: Any) {

        if let light = detailItem, let tileService:LightTileService = light.lightSource.extensionOf(), let tile = tileService.tileOf(light: light) {
            let colors = stride(from: 0, to: 64, by: 1).map{ it in
                HSBK(hue: UInt16(it * Int(UInt16.max) / 64), saturation: UInt16.max, brightness: UInt16.max / 2, kelvin: 0)
            }

            TileSetTileState64Command.create(
                    tileService: tileService,
                    light: tile.light,
                    startIndex: 0,
                    duration: 1,
                    colors: colors
            ).fireAndForget()
        }
    }
}


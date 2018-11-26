# RxLifx-Swift
[![Build Status](https://travis-ci.org/flowsprenger/RxLifx-Swift.svg?branch=master)](https://travis-ci.org/flowsprenger/RxLifx-Swift)

A bundle of libraries that can be utilised to communicate with local LIFX lights using reactive programming and Swift 4.

Individual libraries can be mixed and matched based on use case and preference.

Implements protocol & messages described at https://lan.developer.lifx.com/

## LifxDomain

Message definition and (de)serialization code for integration with your own code.
Has no external dependencies.

To create messages with payload:
```swift
// unicast message to target
let message = Message.createMessageWithPayload(LightGet(), target: target, source: source)

// broadcast message
Message.createBroadcastMessageWithPayload(GetService(), source: source)
```

## RxLifx

Networking code to communicate with LIFX lights on the LAN using UDP packets.
Has a dependency on RxSwift.

Instantiate UdpTransport, subscribe on io queue and observe incoming messages on main queue
```swift
let generator: MessageGenerator = LightMessageGenerator()
let udpTransport = UdpTransport(port: "0", generator: generator)

udpTransport
    .subscribeOn(ioScheduler)
    .observeOn(MainScheduler.instance)
    .subscribe(onNext: { (message: SourcedMessage) in
        print("received message \(message.message) from ip \(message.sourceAddress)")
    })
```

Messages are created using a MessageGenerator for customization
```swift
public protocol MessageGenerator: class {
    associatedtype TM

    func generate(from: sockaddr, data: Data) -> TM
}
```

## RxLifxApi

Simple API demonstrating usage of RxLifx and LifxDomain.

Startup LifxService and listen for changes:
```swift
let changeDispatcher = LightsChangeNotificationDispatcher()
let lightService = LightService(lightsChangeDispatcher: changeDispatcher)

lightService.start()
```

LightsChangeDispatcher accommodates different notification patterns:
```swift
public protocol LightsChangeDispatcher {
    func notifyChange(light: Light, property: String, oldValue: Any?, newValue: Any?)

    func lightAdded(light: Light)
}
```

Sending out messages:
```swift
lightService.sendMessage(light: light, data: serializedMessage)
```

Commands provide easy access to protocol messages:
```swift
let hsbkColor = HSBK(hue: UInt16(hueSlider.value * Float(UInt16.max)), 
                     saturation: UInt16(saturationSlider.value * Float(UInt16.max)), 
                     brightness: UInt16(brightnessSlider.value * Float(UInt16.max)), 
                     kelvin: 0)
let setColorCommand = LightSetColorCommand.create(light: light, color: hsbkColor, duration: 0)

// fire and forget message
setColorCommand.fireAndForget()

// subscribe to responses and acknowledgements
setColorCommand
    .subscribe(onNext: { result: Result<LightState> in 
        print("result received: \(result)") 
    }, onError: { error in 
        print("error received: \(error)")
    }, onCompleted: {
        print("completed")
    })

// onNext is called when 
//     a) a result is received before a timeout occurs (responseRequired 
//        needs to be set on Header for some messages)
//     b) an acknowledgement is received before a timeout occurs (ackRequired 
//        needs to be set on Header)
// onError is called when
//     a) no result is received with a timeframe
//     b) the underlying transport is not connected
// onCompleted is called when 
//     a) the message is send and neither responseRequired not ackRequired
//     b) responseRequired is set and a response has been received
//     c) ackRequired is set and matching acknowledge message has been received
```

## Extensions

The functionality of LightService can be extended by passing a list of extensions types when instantiating it.

#### Tracking group and location:
```swift
// pass LightsGroupLocationService.self as an extension factory
let lightService = LightService(
    lightsChangeDispatcher: groupsLocationService, 
    transportGenerator: UdpTransport.self,
    extensionFactories: [LightsGroupLocationService.self]
)

// after instantiation get a reference to the instatiated extension from LightService
let lightsGroupLocationService: LightsGroupLocationService? = lightService.extensionOf()

// (optional) set a delegate to listen for updates
lightsGroupLocationService?.setListener(groupLocationChangeDispatcher: LightsGroupLocationChangeNotificationDispatcher())

// you can either track all group and location updates through groupLocationChangeDispatcher 
// or query the current state from your LightsGroupLocationService instance

// get the location or group name for a light from LightsGroupLocationService 
// instead of getting the raw value from a light
lightGroupLocationService?.locationOf(light: light).label
lightGroupLocationService?.groupOf(light: light).label

// get all locations, groups, and lights through iteration
lightGroupLocationService?.locations.forEach { value in
    value.groups.forEach { group in
        group.lights.forEach { light in
            print(light)
        }
    }
}
```

#### Support for Tile devices using TileService
```swift
// pass LightTileService.self as an extension factory
let lightService = LightService(
    lightsChangeDispatcher: groupsLocationService,
    transportGenerator: UdpTransport.self,
    extensionFactories: [LightTileService.self]
)

// after instantiation get a reference to the instatiated extension from LightService
let tileService: LightTileService? = lightService.extensionOf()

// (optional) set a delegate to listen for updates
tileService?.setListener(listener: TileServiceListenerImplementation())

// you can either track all group and location updates through the listener
// or query the current state from your LightTileService instance

// get access to the tile data for a light from LightTileService
tileService?.tileOf(light: light)

// get all tiles through iteration
lightGroupLocationService?.tiles.forEach { value in

}
```

## RxLifxExample

Very simple sample app using LifxDomain, RxLifx and RxLifxApi

## Installation

### RxLifxExample

Checkout this repo and bootstrap dependencies using Carthage

`carthage bootstrap`

Then build and deploy the project RxLifExample.

### Integrate into your own project/app

#### Carthage

Add the following to your Cartfile to get a specific commit

`github "flowsprenger/RxLifx-Swift" "commithash"`

Run `carthage update` to fetch dependencies into `Carthage/Checkouts` folder.

Mix and match your frameworks using `Linked frameworks and Libraries`

## External Dependencies

RxSwift, Swift 4

## Known issues/limitations

LifxDomain does not validate sizes of array/string fields

Only iOS frameworks are build at the moment

Protocol data structures containing reserved fields, should have default values

## Further read

https://lan.developer.lifx.com/

https://community.lifx.com/

https://github.com/Carthage/Carthage/

https://github.com/ReactiveX/RxSwift

https://github.com/ReactiveX/RxSwift/wiki/Introduction

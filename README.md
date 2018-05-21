# RxLifx-Swift
[![Build Status](https://travis-ci.org/flowsprenger/RxLifx-Swift.svg?branch=master)](https://travis-ci.org/flowsprenger/RxLifx-Swift)

A bundle of libraries that can be utilised to communicate with local LIFX lights using reactive programming and Swift 3.

Individual libraries can be mixed and matched based on use case and preference.

Implements protocol & messages described at https://lan.developer.lifx.com/

## LifxDomain

Message definition and (de)serialization code for integration with your own code.
Has no external dependencies.

To create messages with payload:
```
// unicast message to target
let message = Message.createMessageWithPayload(LightGet(), target: target, source: source)
// broadcast message
Message.createBroadcastMessageWithPayload(GetService(), source: source)
```

## RxLifx

Networking code to communicate with LIFX lights on the local LAN using UDP packets.
Has a dependency on RxSwift.

Instantiate UdpTransport, subscribe on io queue and observe incoming messages on main queue
```
let generator:MessageGenerator = LightMessageGenerator()

let udpTransport = UdpTransport(port: "0", generator: generator)
udpTransport.subscribeOn(ioScheduler)
            .observeOn(MainScheduler.instance)
            .subscribe(onNext: { (message: SourcedMessage) in
                print("received message \(message.message) from ip \(message.sourceAddress)")
            })
```

Messages are created using a MessageGenerator for customization
```
public protocol MessageGenerator: class {
    associatedtype TM

    func generate(from: sockaddr, data: Data) -> TM
}
```

## RxLifxApi

Simple Api demonstrating usage RxLifx and LifxDomain.

Startup LifxService and listen for changes:
```
let changeDispatcher = LightsChangeNotificationDispatcher()

let lightService = LightService(lightsChangeDispatcher: changeDispatcher)
lightService.start()
```

LightsChangeDispatcher accommodates different notification patterns:
```
public protocol LightsChangeDispatcher {
    func notifyChange(light: Light, property: String, oldValue: Any?, newValue: Any?)

    func lightAdded(light: Light)
}
```

Sending out messages:
```
lightService.sendMessage(light: light, data: serializedMessage)
```

Commands provide easy access to protocol messages:
```
let setColorCommand = LightSetColorCommand.create(light: light, color: HSBK(hue: UInt16(hueSlider.value * Float(UInt16.max)), saturation: UInt16(saturationSlider.value * Float(UInt16.max)), brightness: UInt16(brightnessSlider.value * Float(UInt16.max)), kelvin: 0), duration: 0).fireAndForget()

// fire and forget message
setColorCommand.fireAndForget()

// subscribe to responses and acknowledgements
setColorCommand..subscribe(onNext: { (Result<LightState>) in print("result received") }, onError: { (error:Error) in print("error received"}, onCompleted: {print("completed")}, onDisposed: nil)

// onNext is called when a) a result is received before a timeout occurs (responseRequired needs to be set on Header for some messages)
//                       b) an acknowledgement is received before a timeout occurs (ackRequired needs to be set on Header)
// onError is called when no result is received with a timeframe or the underlying transport is not connected
// onCompleted is called when either a) the message is send and neither responseRequired not ackRequired
//                                  b) responseRequired is set and a response has been received
//                                  c) ackRequired is set and matching acknowledge message has been received
```

Tracking group and location:
```
// instead of passing the lights change dispatcher directly into LightsService decorate it using LightsGroupLocationService
let groupsLocationService = LightsGroupLocationService(lightsChangeDispatcher: LightsChangeNotificationDispatcher(), groupLocationChangeDispatcher: LightsGroupLocationChangeNotificationDispatcher())
LightService(lightsChangeDispatcher: groupsLocationService, transportGenerator: UdpTransport.self)

// you can either track all group and location updates through groupLocationChangeDispatcher or query the current state from your LightsGroupLocationService instance

// get the location or group name for a light from LightsGroupLocationService instead of getting the raw value from a light
lightGroupLocationService.locationOf(light: light).label
lightGroupLocationService.groupOf(light: light).label

// get all locations, groups, and lights through iteration
lightGroupLocationService.locations.forEach{ value in
            value.groups.forEach { group in
                group.lights.forEach { light in
                    print(light)
                }
            }
        }
```

## RxLifxExample

Very simple sample app using LifxDomain, RxLifx and RxLifxApi

## Installation

### RxLifxExample

Checkout this repo and bootstrap dependencies using Carthage

`Carthage bootstrap`

Then build and deploy the project RxLifExample.

### Integrate into your own project/app

#### Carthage

Add the following to your Cartfile to get a specific commit

`github "facebook/AsyncDisplayKit" "commithash"`

Run `Carthage update` to fetch dependencies into `Carthage/Checkouts` folder.

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

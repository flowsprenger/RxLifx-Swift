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
import RxSwift
import RxLifx
import LifxDomain

public class LightService: LightSource {

    public let source = arc4random()

    public let tick = Observable<Int>.interval(5, scheduler: MainScheduler.instance).publish().refCount()

    public let messages: Observable<SourcedMessage>

    private let disposeBag = CompositeDisposable()

    public let lightsChangeDispatcher: LightsChangeDispatcher

    private let udpTransport = UdpTransport(port: "0", generator: LightMessageGenerator())

    private let legacyUdpTransport = UdpTransport(port: String(Header.LIFX_DEFAULT_PORT), generator: LightMessageGenerator())

    private let ioScheduler = ConcurrentDispatchQueueScheduler(qos: .background)

    private var lights:[UInt64:Light] = [:]

    public static let transportRetryTimeout = RxTimeInterval(5)

    public init(lightsChangeDispatcher: LightsChangeDispatcher) {
        self.lightsChangeDispatcher = lightsChangeDispatcher
        let scheduler = ioScheduler

        messages = Observable.of(
                udpTransport.messages.retryWhen({ (errors: Observable<Error>) in return errors.flatMap{ (error:Error) -> Observable<Int64> in Observable.timer(LightService.transportRetryTimeout, scheduler: scheduler)}}),
                legacyUdpTransport.messages.retryWhen({ (errors: Observable<Error>) in return errors.flatMap{ (error:Error) -> Observable<Int64> in Observable.timer(LightService.transportRetryTimeout, scheduler: scheduler)}})
        ).merge()
    }

    public func start() {
        let _ = disposeBag.insert(
                messages.subscribeOn(ioScheduler).observeOn(MainScheduler.instance)
                        .filter({ (message: SourcedMessage) in return message.message.header.target != 0 })
                        .groupBy(keySelector: { (message: SourcedMessage) in return message.message.header.target })
                        .map({ (input: GroupedObservable<UInt64, SourcedMessage>) -> Light in
                            if let light:Light = self.lights[input.key]{
                                return light.attach(observable: input)
                            }else {
                                return Light(observable: input, lightSource: self, lightChangeDispatcher: self.lightsChangeDispatcher)
                            }
                        }).subscribe(onNext: { light in
                            self.lights[light.target] = light
                            self.lightsChangeDispatcher.lightAdded(light: light)
                        }))

        let _ = disposeBag.insert(tick.subscribe({ e in
            BroadcastGetServiceCommand.create(lightSource: self).fireAndForget()
            return
        }))
    }

    public func stop() {
        lights.forEach{ $0.value.dispose() }
        disposeBag.dispose()
    }

    public func sendMessage(light: Light?, data: Data) -> Bool {
        return udpTransport.sendMessage(target: light?.addr ?? sockaddr.broadcastTo(port: Header.LIFX_DEFAULT_PORT), data: data)
    }
}

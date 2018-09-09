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

public struct LightServiceConstants{
    public static let transportRetryTimeout = RxTimeInterval(5)
}

public protocol LightServiceExtension: LightsChangeDispatcher {
    func start(source: LightSource)
    func stop()
    init(wrappedChangeDispatcher: LightsChangeDispatcher)
}

public class LightService<T>: LightSource where T:Transport, T.TMG == LightMessageGenerator{

    public let source = arc4random()

    public let tick: Observable<Int>

    public let messages: Observable<SourcedMessage>

    private var disposeBag = CompositeDisposable()

    public let lightsChangeDispatcher: LightsChangeDispatcher

    internal let udpTransport:T

    internal let legacyUdpTransport:T

    private var lights:[UInt64:Light] = [:]

    public let mainScheduler: SchedulerType
    public let ioScheduler:SchedulerType

    private let extensions:[LightServiceExtension]

    public init(
            lightsChangeDispatcher: LightsChangeDispatcher,
            transportGenerator: T.Type,
            mainScheduler:SchedulerType = MainScheduler.instance,
            ioScheduler: SchedulerType =  ConcurrentDispatchQueueScheduler(qos: .background),
            extensionFactories: Array<LightServiceExtension.Type> = []
    ) {
        let (changeDispatcher, extensions) = extensionFactories.reduce((lightsChangeDispatcher, [LightServiceExtension]())) { (changeDispatcherExtensions, factory) -> (LightsChangeDispatcher, [LightServiceExtension]) in
            let (changeDispatcher, extensions) = changeDispatcherExtensions
            let ext = factory.init(wrappedChangeDispatcher: changeDispatcher)
            return (ext, extensions + [ext])
        }
        self.extensions = extensions
        self.lightsChangeDispatcher = changeDispatcher
        self.tick = Observable<Int>.interval(5, scheduler: mainScheduler).publish().refCount()
        self.mainScheduler = mainScheduler
        self.ioScheduler = ioScheduler

        udpTransport = transportGenerator.init(port: "0", generator: LightMessageGenerator())
        legacyUdpTransport = transportGenerator.init(port: String(Header.LIFX_DEFAULT_PORT), generator: LightMessageGenerator())

        messages = Observable.of(
                udpTransport.messages.retryWhen({ (errors: Observable<Error>) in return errors.flatMap{ (error:Error) -> Observable<Int64> in Observable.timer(LightServiceConstants.transportRetryTimeout, scheduler: ioScheduler)}}),
                legacyUdpTransport.messages.retryWhen({ (errors: Observable<Error>) in return errors.flatMap{ (error:Error) -> Observable<Int64> in Observable.timer(LightServiceConstants.transportRetryTimeout, scheduler: ioScheduler)}})
        ).merge().publish().refCount()
    }

    public func start() {
        disposeBag.dispose()
        disposeBag = CompositeDisposable()
        let _ = disposeBag.insert(
                messages.subscribeOn(ioScheduler)
                        .observeOn(mainScheduler)
                        .filter({ (message: SourcedMessage) in
                            return message.message.header.target != 0
                        })
                        .groupBy(keySelector: { (message: SourcedMessage) in return message.message.header.target })
                        .map({ (input: GroupedObservable<UInt64, SourcedMessage>) -> Light in
                            if let light:Light = self.lights[input.key]{
                                return light.attach(observable: input)
                            }else {
                                let light = Light(id: input.key, lightSource: self, lightChangeDispatcher: self.lightsChangeDispatcher)
                                _ = light.attach(observable: input)
                                return light
                            }
                        }).subscribe(onNext: { light in
                            self.lights[light.target] = light
                            self.lightsChangeDispatcher.lightAdded(light: light)
                        }))

        let _ = disposeBag.insert(tick.subscribe({ e in
            BroadcastGetServiceCommand.create(lightSource: self).fireAndForget()
            return
        }))

        BroadcastGetServiceCommand.create(lightSource: self).fireAndForget()

        extensions.forEach{ $0.start(source: self) }
    }

    public func extensionOf<E>() -> E? where E: LightServiceExtension {
        return extensions.first{ $0 is E } as? E
    }

    public func stop() {
        extensions.forEach{ $0.stop() }
        lights.forEach{ $0.value.dispose() }
        disposeBag.dispose()
    }

    public func sendMessage(light: Light?, data: Data) -> Bool {
        return udpTransport.sendMessage(target: light?.addr ?? sockaddr.broadcastTo(port: Header.LIFX_DEFAULT_PORT), data: data)
    }

    private func broadcastStateServiceDelayed() -> Disposable {
        return Observable<Int>.timer(1, period: nil, scheduler: self.ioScheduler).subscribe{ event in
            switch(event){
            case .next(_):
                BroadcastGetServiceCommand.create(lightSource: self).fireAndForget()
            default: ()
            }

        }
    }
}

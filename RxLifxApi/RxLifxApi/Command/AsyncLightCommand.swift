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

public class AsyncLightCommand{

    static let TIMEOUT:RxTimeInterval = 5

    public class func sendMessage<T>(lightSource: LightSource, light:Light?, message:Message, sideEffect: (() -> ())? = nil) -> Observable<Result<T>>{
        return Observable.create { subscriber in
            var subscription: Disposable? = nil

            if let light:Light = light {
                message.header.sequence = light.getNextSequence()
            }

            var needsResponse = message.header.responseRequired
            var needsAcknowledgement = message.header.ackRequired

            if lightSource.sendMessage(light: light, data: message.toData()) {
                if let sideEffect = sideEffect {
                    if(Thread.isMainThread){
                        sideEffect()
                    }else{
                        DispatchQueue.main.async(execute: sideEffect)
                    }
                }

                if(needsAcknowledgement || needsResponse){
                    subscription = lightSource.messages.filter({m in message.header.source == m.message.header.source && message.header.target == m.message.header.target && message.header.sequence == m.message.header.sequence}).timeout(AsyncLightCommand.TIMEOUT, scheduler: lightSource.ioScheduler).subscribe(onNext: { m in
                        if(m.message.header.type == MessageType.Acknowledgement.rawValue) {
                            subscriber.onNext(Result(status: .Acknowledged, result: nil))
                            needsAcknowledgement = false
                        }else if let result = m.message.payload as? T{
                            subscriber.onNext(Result(status:.Response, result: result))
                            needsResponse = false
                        }

                        if(!needsAcknowledgement && !needsResponse){
                            subscriber.onCompleted()
                        }
                    }, onError: { e in
                        subscriber.onError(SendMessageError.TimeOut)
                    })
                }else{
                    subscriber.onCompleted()
                }
            }else{
                subscriber.onError(SendMessageError.TransportNotReady)
            }

            let disposable = Disposables.create {
                subscription?.dispose()
            }
            return disposable
        }
    }
}

public struct Result<T : AnyObject>{
    let status:ResultStatus
    var result:T?
}

public enum ResultStatus {
    case Acknowledged
    case Response
}

public enum SendMessageError: Error{
    case TimeOut
    case TransportNotReady
}

public extension ObservableType{
    func fireAndForget(){
        let _ = self.subscribe{ _ in }
    }
}
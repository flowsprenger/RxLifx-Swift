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

public class UdpTransport<T:MessageGenerator> {
    public let port: String
    let generator: T

    var publisher:PublishSubject<TargetedData>? = nil

    public init(port: String, generator: T) {
        self.port = port
        self.generator = generator
    }

    public lazy var messages: Observable<T.TM> = {
        return Observable<T.TM>.create { observer in
            let socket = UdpSocket()

            let disposable = Disposables.create {
                socket.closeSocket()
            }

            DispatchQueue.global(qos: .background).async(execute: {
                        switch (socket.connect(port: self.port)) {
                        case let .Success(descriptor):
                            let bufferSize = 100 * 1024
                            var requestBuffer: Array<UInt8> = Array(repeating: 0, count: bufferSize)
                            var bufferPosition: Int = 0

                            let publisher = PublishSubject<TargetedData>()
                            let publisherSubscription = publisher.subscribe{ targetedData in
                                if let element = targetedData.element{
                                    var target = element.target
                                    socket.writeMessage(socketDescriptor: descriptor, addr: &target, data: element.data)
                                }
                            }
                            self.publisher = publisher

                            var result = socket.receive(requestBuffer: &requestBuffer, requestLength: bufferPosition, bufferSize: bufferSize)
                            while case let .Success(receiveResult) = result {
                                if let message = self.generator.generate(from: receiveResult.fromAddr, data: Data(bytes: requestBuffer[0 ..< receiveResult.bytesRead])){
                                    observer.onNext(message)
                                }

                                result = socket.receive(requestBuffer: &requestBuffer, requestLength: bufferPosition, bufferSize: bufferSize)
                            }

                            publisherSubscription.dispose()
                            publisher.dispose()
                            self.publisher = nil

                            if(!disposable.isDisposed){
                                switch(result){
                                    case let .Failure(error):
                                        observer.onError(error)
                                    default : {}()
                                }
                            }

                        case let .Failure(error):
                            observer.onError(error)
                        }

                        socket.closeSocket()
                    })
            return disposable
        }.publish().refCount()
    }()

    public func sendMessage(target: sockaddr, data: Data) -> Bool {
        if let publisher = publisher {
            publisher.onNext(TargetedData(target: target, data: data))
            return true
        }else{
            return false
        }
    }
}

public protocol MessageGenerator: class {
    associatedtype TM

    func generate(from: sockaddr, data: Data) -> TM?
}

public struct TargetedData{
    let target:sockaddr
    let data:Data
}

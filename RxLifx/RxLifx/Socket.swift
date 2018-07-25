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

class UdpSocket {

    let applicationInDebugMode = true

    var status: Int32 = 0
    var socketDescriptor: Int32 = 0

    func connect(port: String = "0", interface: UnsafePointer<Int8>? = nil) -> Either<Int32, SocketError> {

        var hints = addrinfo(
                ai_flags: AI_PASSIVE,
                ai_family: AF_INET,
                ai_socktype: SOCK_DGRAM,
                ai_protocol: 0,
                ai_addrlen: 0,
                ai_canonname: nil,
                ai_addr: nil,
                ai_next: nil)

        var servInfo: UnsafeMutablePointer<addrinfo>? = nil
        let statusGetAddrInfo = getaddrinfo(
                interface,
                port,
                &hints,
                &servInfo)

        if statusGetAddrInfo != 0 {
            var strError: String
            if statusGetAddrInfo == EAI_SYSTEM {
                strError = String(validatingUTF8: strerror(errno)) ?? "Unknown error code"
            } else {
                strError = String(validatingUTF8: gai_strerror(statusGetAddrInfo)) ?? "Unknown error code"
            }
            return .Failure(.GetAddrError(strError))
        }

        if applicationInDebugMode {
            servInfo?.pointee.dumpDescriptions()
        }

        socketDescriptor = socket(
                servInfo!.pointee.ai_family,
                servInfo!.pointee.ai_socktype,
                servInfo!.pointee.ai_protocol)

        if socketDescriptor == -1 {
            let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Socket creation error \(errno) (\(strError))"
            freeaddrinfo(servInfo)
            return .Failure(.SocketCreationError(message))
        }

        var reuseAddressOption: Int = 1;

        let statusSetSockOpt = setsockopt(
                socketDescriptor,
                SOL_SOCKET,
                SO_REUSEADDR,
                &reuseAddressOption,
                socklen_t(MemoryLayout<Int>.size))

        var noSigPipeOption: Int = 1;
        setsockopt(
                socketDescriptor,
                SOL_SOCKET,
                SO_NOSIGPIPE,
                &noSigPipeOption,
                socklen_t(MemoryLayout<Int>.size))

        if statusSetSockOpt == -1 {
            let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Setsockopt error \(errno) (\(strError))"
            freeaddrinfo(servInfo)
            close(socketDescriptor)
            return .Failure(.SetSockOptError(message))
        }

        var broadcastOption: Int = 1;
        let statusSetSockOptBroadcast = setsockopt(
                socketDescriptor,
                SOL_SOCKET,
                SO_BROADCAST,
                &broadcastOption,
                socklen_t(MemoryLayout<Int>.size))

        if statusSetSockOptBroadcast == -1 {
            let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Setsockopt error \(errno) (\(strError))"
            freeaddrinfo(servInfo)
            close(socketDescriptor)
            return .Failure(.SetSockOptError(message))
        }

        let status = bind(
                socketDescriptor,
                servInfo!.pointee.ai_addr,
                servInfo!.pointee.ai_addrlen)

        if status != 0 {
            let strError = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Binding error \(errno) (\(strError))"
            freeaddrinfo(servInfo)
            close(socketDescriptor)
            return .Failure(.BindingError(message))
        }

        freeaddrinfo(servInfo)

        return .Success(socketDescriptor)
    }

    func receive(requestBuffer: inout Array<UInt8>, requestLength: Int, bufferSize: Int) -> Either<ReceiveResult, SocketError> {

        var sourceaddr: sockaddr = sockaddr()
        var socklen: socklen_t = socklen_t(MemoryLayout<sockaddr>.size)

        let bytesRead = recvfrom(
                socketDescriptor,
                &requestBuffer[requestLength],
                bufferSize,
                0, &sourceaddr, &socklen)

        if bytesRead == -1 {

            let errString = String(utf8String: strerror(errno)) ?? "Unknown error code"
            let message = "Recv error = \(errno) (\(errString))"

            return .Failure(.ReadError(message))
        }

        if bytesRead == 0 {

            let message = "Client closed connection"

            return .Failure(.ClosedError(message))
        }

        let result = ReceiveResult(bytesRead:bytesRead, fromAddr: sourceaddr)
        return .Success(result)
    }

    class func htons(value: CUnsignedShort) -> CUnsignedShort {
        return (value << 8) + (value >> 8);
    }

    func writeMessage(socketDescriptor: Int32, addr: inout sockaddr, data: Data) -> Int{

        return data.withUnsafeBytes { bytes in
            return sendto(socketDescriptor, bytes, data.count, 0, &addr, socklen_t(addr.sa_len))
        }
    }

    func closeSocket() {
        close(socketDescriptor)
    }
}

extension sockaddr {
    public func host() -> String? {
        var addr = self

        var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        if (getnameinfo(&addr, socklen_t(addr.sa_len),
                &hostBuffer, socklen_t(hostBuffer.count), nil, 0,
                NI_NUMERICHOST) == 0) {
            return String(cString: hostBuffer)
        }
        return nil
    }

    func sockaddrDescription() -> (String?, String?) {

        var addr = self
        var host: String?
        var service: String?

        var hostBuffer = [CChar](repeating: 0, count: Int(NI_MAXHOST))
        var serviceBuffer = [CChar](repeating: 0, count: Int(NI_MAXSERV))

        if getnameinfo(
                &addr,
                socklen_t(addr.sa_len),
                &hostBuffer,
                socklen_t(hostBuffer.count),
                &serviceBuffer,
                socklen_t(serviceBuffer.count),
                NI_NUMERICHOST | NI_NUMERICSERV)

                   == 0 {

            host = String(cString: hostBuffer)
            service = String(cString: serviceBuffer)
        }
        return (host, service)

    }

    public static func broadcastTo(port: UInt16) -> sockaddr {
        let address = in_addr(s_addr: INADDR_BROADCAST)
        var addr = sockaddr_in(
                sin_len: __uint8_t(MemoryLayout<sockaddr_in>.size),
                sin_family: sa_family_t(AF_INET),
                sin_port: UdpSocket.htons(value: port),
                sin_addr: address,
                sin_zero: (0, 0, 0, 0, 0, 0, 0, 0)
        )
        return withUnsafePointer(to: &addr) { ptr in
            ptr.withMemoryRebound(to: sockaddr.self, capacity: 1, { ptrSockAddr in
                ptrSockAddr.pointee
            })
        }
    }
}

extension addrinfo{

    func dumpDescriptions(){
        var info:addrinfo? = self
        while info != nil {
            let (clientIp, service) = info!.ai_addr.pointee.sockaddrDescription()
            print("HostIp: \(clientIp ?? "?") at port: \(service ?? "?")")
            info = info!.ai_next?.pointee
        }
    }
}

enum Either<TSuccess,TFailure> {
    case Success(TSuccess)
    case Failure(TFailure)
}

struct ReceiveResult{
    let bytesRead:Int
    let fromAddr:sockaddr
}

enum SocketError : Error {
    case ReadError(String)
    case ClosedError(String)
    case GetAddrError(String)
    case SocketCreationError(String)
    case SetSockOptError(String)
    case BindingError(String)
}

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

public class DataInputStream {
    private var pos: Int = 0
    private let data: Data

    public init(data: Data) {
        self.data = data
    }

    func readByte() -> UInt8 {
        let value = data[pos]
        pos += 1
        return value
    }

    func readShort() -> UInt16 {
        let value = UInt16(readByte()) | (UInt16(readByte()) << 8)
        return value
    }

    func readWord() -> UInt32 {
        let value = UInt32(readShort()) | (UInt32(readShort()) << 16)
        return value
    }

    func readFloat() -> Float32 {
        return Float32(bitPattern: readWord())
    }

    func readLong() -> UInt64 {
        let value = UInt64(readWord()) | (UInt64(readWord()) << 32)
        return value
    }

    func readString(size:Int) -> String {
        var s = String()
        for _ in 0..<size{
            s.append(Character(UnicodeScalar(readByte())))
        }
        return s
    }

    func readArray<T>(size: Int, generator: @escaping (DataInputStream) -> (T)) -> [T] {
        return (0 ..< size).map {
            _ in generator(self)
        }
    }

}

public class DataOutputStream
{
    private var pos: Int = 0
    private var data: Data

    init(size:Int){
        data = Data(count: size)
    }

    func writeByte(value:UInt8)
    {
        data[pos] = value
        pos += 1
    }

    func writeShort(value:UInt16){

        writeByte(value: UInt8(truncatingBitPattern: value))
        writeByte(value: UInt8(truncatingBitPattern: value >> 8))
    }

    func writeWord(value:UInt32){
        writeShort(value: UInt16(truncatingBitPattern: value))
        writeShort(value: UInt16(truncatingBitPattern: value >> 16))
    }

    func writeFloat(value:Float32){
        writeWord(value: value.bitPattern)
    }

    func writeLong(value:UInt64){
        writeWord(value: UInt32(truncatingBitPattern: value))
        writeWord(value: UInt32(truncatingBitPattern: value >> 32))
    }

    func writeString(value:String, size:Int){
        let padding = size - value.utf8.count
        for _ in 0..<padding{
            writeByte(value: 20)
        }
        value.utf8.forEach{ writeByte(value: UInt8($0)) }
    }

    func writeArray<T>(value:[T], writer: (T, DataOutputStream) -> () ){
        for item in value {
            writer(item, self)
        }
    }

    func finalize() -> Data{
        return data
    }
}

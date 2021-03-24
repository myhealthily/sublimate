import class Dispatch.DispatchQueue
import protocol FluentKit.Database
import class NIO.EventLoopFuture
import SublimateNIO

public extension Database {
    /// Not recommended, but can ease porting
    /// - Note: doesn’t seem to work for XCTFluent’s TestDatabase
    func sublimate<Value>(file: String = #file, line: UInt = #line, use closure: @escaping (CO₂DB) throws -> Value) -> EventLoopFuture<Value> {
        DispatchQueue.global().async(on: eventLoop) {
            try closure(CO₂DBStruct(db: self))
        }
    }
}

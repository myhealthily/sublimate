import class Dispatch.DispatchQueue
import protocol FluentKit.Database
import class NIO.EventLoopFuture
import SublimateNIO

public extension Database {
    /// Not recommended, but can ease porting
    /// - Note: doesn’t seem to work for XCTFluent’s TestDatabase
    func sublimate<Value>(use closure: @escaping (CO₂DB) throws -> Value) -> EventLoopFuture<Value> {
        DispatchQueue.global().async(on: eventLoop) {
            try closure(ConcreteCO₂DB(db: self))
        }
    }

    func sublimate<Value>(in: CO₂RouteOptions, use closure: @escaping (CO₂DB) throws -> Value) -> EventLoopFuture<Value> {
        transaction { db in
            DispatchQueue.global().async(on: db.eventLoop) {
                try closure(ConcreteCO₂DB(db: db))
            }
        }
    }
}

/// Provides `.transaction`
public enum CO₂RouteOptions {
    /// Is `.transaction`
    case transaction
}

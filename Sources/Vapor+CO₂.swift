import class Dispatch.DispatchQueue
import protocol FluentKit.Database
import class NIO.EventLoopFuture
import class Vapor.Request
import struct Vapor.Abort

public extension Vapor.Request {
    /// Not recommended, but can ease porting
    func sublimate<Value>(use closure: @escaping (CO₂) throws -> Value, file: String = #file, line: UInt = #line) -> EventLoopFuture<Value> {
        DispatchQueue.global().async(on: eventLoop) {
            guard !self.db.inTransaction else {
                throw Abort(.internalServerError, reason: "Using rq.db from inside a transaction will deadlock Vapor", file: file, line: line)
            }
            return try closure(CO₂(rq: self, db: self.db))
        }
    }
}

public extension FluentKit.Database {
    /// Not recommended, but can ease porting
    /// - Note: doesn’t seem to work for XCTFluent’s TestDatabase
    func sublimate<Value>(use closure: @escaping (CO₂DB) throws -> Value, file: String = #file, line: UInt = #line) -> EventLoopFuture<Value> {
        DispatchQueue.global().async(on: eventLoop) {
            guard !self.inTransaction else {
                throw Abort(.internalServerError, reason: "Using rq.db from inside a transaction will deadlock Vapor", file: file, line: line)
            }
            return try closure(CO₂DB(db: self))
        }
    }
}

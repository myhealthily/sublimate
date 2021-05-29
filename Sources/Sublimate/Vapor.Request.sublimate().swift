import SublimateVapor
import Fluent
import Vapor

public extension Vapor.Request {
    /// Not recommended, but can ease porting
    func sublimate<Value>(file: String = #file, line: UInt = #line, use closure: @escaping (CO₂) throws -> Value) -> EventLoopFuture<Value> {
        DispatchQueue.global().async(on: eventLoop) {
            try closure(CO₂(rq: self, db: self.db))
        }
    }
}

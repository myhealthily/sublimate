import Vapor

public extension Request {
    func sublimate<T>(use closure: @escaping (CO₂) throws -> T) -> EventLoopFuture<T> {
        eventLoop.dispatch {
            guard !self.db.inTransaction else {
                throw Abort(.internalServerError, reason: "Using rq.db from inside a transaction will deadlock Vapor")
            }
            return try closure(CO₂(rq: self, db: self.db))
        }
    }
}

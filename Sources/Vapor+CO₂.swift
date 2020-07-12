import Vapor

public extension Request {
    func sublimate<T>(use closure: @escaping (Sublimate) throws -> T) -> EventLoopFuture<T> {
        eventLoop.dispatch {
            guard !self.db.inTransaction else {
                throw Abort(.internalServerError, reason: "Using rq.db from inside a transaction will deadlock Vapor")
            }
            return try closure(Sublimate(rq: self, db: self.db))
        }
    }
}

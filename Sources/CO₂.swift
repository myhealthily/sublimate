import protocol FluentKit.Database
import Vapor

public class CO₂DB {
    public let db: Database

    init(db: Database) {
        self.db = db
    }
}

public extension CO₂DB {
    @inlinable var eventLoop: EventLoop { db.eventLoop }
}

public final class CO₂: CO₂DB {
    public let rq: Request

    init(rq: Request, db: Database) {
        self.rq = rq
        super.init(db: db)
    }
}

public extension CO₂ {
    @inlinable var client: Client { rq.client }
    @inlinable var content: ContentContainer { rq.content }
    @inlinable var auth: Request.Authentication { rq.auth }
    @inlinable var parameters: Parameters { rq.parameters }
}

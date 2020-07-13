import protocol FluentKit.Database
import Vapor

public final class CO₂ {
    public let db: Database
    public let rq: Request

    init(rq: Request, db: Database) {
        self.rq = rq
        self.db = db
    }
}

public extension CO₂ {
    @inlinable var client: Client { rq.client }
    @inlinable var content: ContentContainer { rq.content }
    @inlinable var auth: Request.Authentication { rq.auth }
    @inlinable var eventLoop: EventLoop { rq.eventLoop }
    @inlinable var parameters: Parameters { rq.parameters }
}

import protocol FluentKit.Database
import Vapor

public final class Sublimate {
    public let db: Database
    public let rq: Request

    init(rq: Request, db: Database) {
        self.rq = rq
        self.db = db
    }
}

public extension Sublimate {
    var client: Client { rq.client }
    var content: ContentContainer { rq.content }
    var auth: Request.Authentication { rq.auth }
    var eventLoop: EventLoop { rq.eventLoop }
}

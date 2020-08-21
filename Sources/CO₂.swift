import protocol Vapor.URLQueryContainer
import protocol Vapor.ContentContainer
import protocol FluentKit.Database
import protocol Fluent.Database
import struct Vapor.HTTPHeaders
import struct Vapor.Parameters
import class Vapor.Application
import protocol NIO.EventLoop
import protocol Vapor.Client
import struct Vapor.Logger
import class Vapor.Request

/// Sublimate utility object wrapping a Fluent `Database` object.
public class CO₂DB {
    /// - Returns: The underlying Fluent `Database` object.
    public let db: Database

    init(db: Database) {
        self.db = db
    }
}

public extension CO₂DB {
    /// - Returns: The underlying NIO `EventLoop` object.
    @inlinable var eventLoop: EventLoop { db.eventLoop }
}

/// Sublimate utility object wrapping a Vapor `Request` object and a Fluent `Database` object.
public final class CO₂: CO₂DB {
    /// - Returns: The underlying Vapor `Request` object.
    public let rq: Request

    init(rq: Request, db: Database) {
        self.rq = rq
        super.init(db: db)
    }
}

public extension CO₂ {
    /// - Returns: Creates a Vapor `Client` object.
    @inlinable var client: Client { rq.client }
    /// - Returns: Returns the Vapor `Request`’s `ContentContainer`.
    @inlinable var content: ContentContainer { rq.content }
    /// - Returns: Returns the Vapor `Request`’s `Authentication`.
    @inlinable var auth: Request.Authentication { rq.auth }
    /// - Returns: Returns the Vapor `Request`’s `Parameters`.
    @inlinable var parameters: Parameters { rq.parameters }
    /// - Returns: Returns the Vapor `Request`’s `HTTPHeaders`.
    @inlinable var headers: HTTPHeaders { rq.headers }
    /// - Returns: Returns the Vapor `Request`’s `URLQueryContainer`.
    @inlinable var query: URLQueryContainer { rq.query }
    /// - Returns: Returns the Vapor `Request`’s `Logger`.
    @inlinable var logger: Logger { rq.logger }
    /// - Returns: Returns the Vapor `Application`.
    @inlinable var application: Application { rq.application }
}

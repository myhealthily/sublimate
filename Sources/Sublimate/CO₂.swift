@_exported import SublimateFluentKit
import protocol FluentKit.Database
@_exported import SublimateNIO
import Vapor

public struct CO₂: CO₂Protocol, CO₂DB {
    public let rq: Request
    public let db: Database

    init(rq: Request, db: Database) {
        self.rq = rq
        self.db = db
    }

    public var eventLoop: EventLoop { rq.eventLoop }

    /// Provided for API compatability
    public typealias QueryOptions = CO₂QueryOptions
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
    /// - Returns: Returns the Vapor `Request`’s `Body`
    @inlinable var body: Vapor.Request.Body { rq.body }

    /// Returns the current `Session` or creates one.
    ///
    ///     router.get("session") { req -> String in
    ///         req.session.data["name"] = "Vapor"
    ///         return "Session set"
    ///     }
    ///
    /// - note: `SessionsMiddleware` must be added and enabled.
    /// - returns: `Session` for this `Request`.
    @inlinable var session: Vapor.Session { rq.session }

    /// Creates a redirect `Response`.
    ///
    ///     router.get("redirect") { req in
    ///         return req.redirect(to: "https://vapor.codes")
    ///     }
    ///
    /// Set type to '.permanently' to allow caching to automatically redirect from browsers.
    /// Defaulting to non-permanent to prevent unexpected caching.
    @inlinable func redirect(to: URL) -> Vapor.Response {
        rq.redirect(to: to.absoluteString)
    }
}

extension SublimateAbort: AbortError
{}

import protocol FluentKit.Database
@_exported import SublimateVapor
import Vapor

/**
 Creates a sublimate routable for a route that returns `Vapor.Response`

     let route = sublimate { rq in
         Vapor.Response(status: .ok)
     }

     app.routes.get(use: route)

 - Parameter in: Provide `.transaction` to have this route contained in a database transaction.
 */
@_disfavoredOverload
public func sublimate(in options: CO₂.RouteOptions? = nil, use closure: @escaping (CO₂) throws -> Response) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        options.go(on: rq) { db in
            try closure(CO₂(rq: rq, db: db))
        }
    }
}

/**
 Creates a sublimate routable for a route that returns `NIOHTTP1.HTTPResponseStatus`

     let route = sublimate { rq in
         NIOHTTP1.HTTPResponseStatus.ok
     }

     app.routes.get(use: route)

 - Parameter in: Provide `.transaction` to have this route contained in a database transaction.
 */
public func sublimate(in options: CO₂.RouteOptions? = nil, use closure: @escaping (CO₂) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        options.go(on: rq) { db in
            try closure(CO₂(rq: rq, db: db))
            return .ok
        }
    }
}

/**
 Creates an authenticated sublimate routable for a route that returns `Vapor.Response`

 - Note: You must specify the type of the user parameter, it must conform to `Vapor.Authenticatable`

     let route = sublimate { (rq, user: MyUser) in
         Vapor.Response(status: .ok)
     }

     app.routes.get(use: route)

 - Parameter in: Provide `.transaction` to have this route contained in a database transaction.
 */
@_disfavoredOverload
public func sublimate<User: Authenticatable>(in options: CO₂.RouteOptions? = nil, use closure: @escaping (CO₂, User) throws -> Response) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return options.go(on: rq) { db in
            try closure(CO₂(rq: rq, db: db), user)
        }
    }
}

/**
 Creates a sublimate routable for a route that returns `ResponseEncodable`

 - Note: `Fluent.Model` conforms to `ResponseEncodable`, as does `Vapor.Content`

     let route = sublimate { rq in
         try MyModel.query(on: rq).all()
     }

     app.routes.get(use: route)

 - Parameter in: Provide `.transaction` to have this route contained in a database transaction.
 */
@_disfavoredOverload
public func sublimate<E: ResponseEncodable>(in options: CO₂.RouteOptions? = nil, use closure: @escaping (CO₂) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        options.go(on: rq) { db in
            try closure(CO₂(rq: rq, db: db)).encodeResponse(for: rq).wait()
        }
    }
}

/**
 Creates an authenticated sublimate routable for a route that returns `ResponseEncodable`

 - Note: `Fluent.Model` conforms to `ResponseEncodable`, as does `Vapor.Content`
 - Note: You must specify the type of the user parameter, it must conform to `Vapor.Authenticatable`

     let route = sublimate { (rq, user: MyUser) in
         try MyModel.query(on: rq).filter(\.$userID == user.id).all()
     }

     app.routes.get(use: route)

 - Parameter in: Provide `.transaction` to have this route contained in a database transaction.
 */
@_disfavoredOverload
public func sublimate<E: ResponseEncodable, User: Authenticatable>(in options: CO₂.RouteOptions? = nil, use closure: @escaping (CO₂, User) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return options.go(on: rq) { db in
            try closure(CO₂(rq: rq, db: db), user).encodeResponse(for: rq).wait()
        }
    }
}

/**
 Creates an authenticated sublimate routable for a route that returns `Void`

 - Note: Sublimate will return a `Vapor.Response(status: .ok)` for you
 - Note: You must specify the type of the user parameter, it must conform to `Vapor.Authenticatable`

     let route = sublimate { (rq, user: MyUser) in
         try MyModel.query(on: rq).filter(\.$userID == user.id).delete()
     }

     app.routes.delete(use: route)

 - Parameter in: Provide `.transaction` to have this route contained in a database transaction.
 */
public func sublimate<User: Authenticatable>(in options: CO₂.RouteOptions? = nil, use closure: @escaping (CO₂, User) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return options.go(on: rq) { db in
            try closure(CO₂(rq: rq, db: db), user)
            return .ok
        }
    }
}

/// Provides `.transaction`
public extension CO₂ {
    /// Is `.transaction`
    typealias RouteOptions = CO₂RouteOptions
    // ^^ provided for API back-compat
}

private extension Optional where Wrapped == CO₂.RouteOptions {
    @inline(__always)
    func go<Value>(on rq: Request, body: @escaping (FluentKit.Database) throws -> Value) -> EventLoopFuture<Value> {
        switch self {
        case nil:
            return DispatchQueue.global().async(on: rq.eventLoop) {
                try body(rq.db)
            }
        case .transaction:
            return rq.db.transaction { db in
                DispatchQueue.global().async(on: rq.eventLoop) {
                    try body(db)
                }
            }
        }
    }
}

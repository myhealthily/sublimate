import enum NIOHTTP1.HTTPResponseStatus
import protocol Vapor.ResponseEncodable
import protocol Vapor.Authenticatable
import class Dispatch.DispatchQueue
import class NIO.EventLoopFuture
import protocol NIO.EventLoop
import class Vapor.Response
import class Vapor.Request

/**
 Creates a sublimate routable for a route that returns `Vapor.Response`

     let route = sublimate { rq in
         Vapor.Response(status: .ok)
     }

     app.routes.get(use: route)
 */
public func sublimate(use closure: @escaping (CO₂) throws -> Response) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        DispatchQueue.global().async(on: rq.eventLoop) {
            try closure(CO₂(rq: rq, db: rq.db))
        }
    }
}

/**
 Creates a sublimate routable for a route that returns `NIOHTTP1.HTTPResponseStatus`

     let route = sublimate { rq in
         NIOHTTP1.HTTPResponseStatus.ok
     }

     app.routes.get(use: route)
 */
public func sublimate(use closure: @escaping (CO₂) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        DispatchQueue.global().async(on: rq.eventLoop) {
            try closure(CO₂(rq: rq, db: rq.db))
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
 */
public func sublimate<User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> Response) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return DispatchQueue.global().async(on: rq.eventLoop) {
            try closure(CO₂(rq: rq, db: rq.db), user)
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
 */
public func sublimate<E: ResponseEncodable>(use closure: @escaping (CO₂) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        return DispatchQueue.global().async(on: rq.eventLoop) {
            try closure(CO₂(rq: rq, db: rq.db)).encodeResponse(for: rq).wait()
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
 */
public func sublimate<E: ResponseEncodable, User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return DispatchQueue.global().async(on: rq.eventLoop) {
            try closure(CO₂(rq: rq, db: rq.db), user).encodeResponse(for: rq).wait()
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
 */
public func sublimate<User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return DispatchQueue.global().async(on: rq.eventLoop) {
            try closure(CO₂(rq: rq, db: rq.db), user)
            return .ok
        }
    }
}

public extension CO₂DB {
    /// Provides `.transaction`
    enum RouteOptions {
        /// Is `.transaction`
        case transaction
    }
}

public func sublimate<User: Authenticatable>(in: CO₂DB.RouteOptions, use closure: @escaping (CO₂, User) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return rq.db.transaction { db in
            DispatchQueue.global().async(on: rq.eventLoop) {
                try closure(CO₂(rq: rq, db: db), user)
                return .ok
            }
        }
    }
}

public func sublimate(in: CO₂DB.RouteOptions, use closure: @escaping (CO₂) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        rq.db.transaction { db in
            DispatchQueue.global().async(on: rq.eventLoop) {
                try closure(CO₂(rq: rq, db: db))
                return .ok
            }
        }
    }
}

public func sublimate<E: ResponseEncodable>(in: CO₂DB.RouteOptions, use closure: @escaping (CO₂) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        return rq.db.transaction { db in
            DispatchQueue.global().async(on: rq.eventLoop) {
                try closure(CO₂(rq: rq, db: db)).encodeResponse(for: rq).wait()
            }
        }
    }
}

public func sublimate<E: ResponseEncodable, User: Authenticatable>(in: CO₂DB.RouteOptions, use closure: @escaping (CO₂, User) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return rq.db.transaction { db in
            DispatchQueue.global().async(on: rq.eventLoop) {
                try closure(CO₂(rq: rq, db: db), user).encodeResponse(for: rq).wait()
            }
        }
    }
}

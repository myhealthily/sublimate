import enum NIOHTTP1.HTTPResponseStatus
import protocol Vapor.ResponseEncodable
import protocol Vapor.Authenticatable
import class NIO.EventLoopFuture
import class Vapor.Response
import class Vapor.Request

public func sublimate(use closure: @escaping (CO₂) throws -> Response) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        return rq.eventLoop.dispatch {
            try closure(CO₂(rq: rq, db: rq.db))
        }
    }
}

public func sublimate(use closure: @escaping (CO₂) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        return rq.eventLoop.dispatch {
            try closure(CO₂(rq: rq, db: rq.db))
            return .ok
        }
    }
}

public func sublimate<User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> Response) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return rq.eventLoop.dispatch {
            try closure(CO₂(rq: rq, db: rq.db), user)
        }
    }
}

public func sublimate<E: ResponseEncodable, User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return rq.eventLoop.dispatch {
            try closure(CO₂(rq: rq, db: rq.db), user).encodeResponse(for: rq).wait()
        }
    }
}

public func sublimate<E: ResponseEncodable>(use closure: @escaping (CO₂) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        return rq.eventLoop.dispatch {
            try closure(CO₂(rq: rq, db: rq.db)).encodeResponse(for: rq).wait()
        }
    }
}

public func sublimate<User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return rq.eventLoop.dispatch {
            try closure(CO₂(rq: rq, db: rq.db), user)
            return .ok
        }
    }
}

public func transaction<User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return rq.db.transaction { db in
            rq.eventLoop.dispatch {
                try closure(CO₂(rq: rq, db: db), user)
                return .ok
            }
        }
    }
}

public func transaction(use closure: @escaping (CO₂) throws -> Void) -> (Request) throws -> EventLoopFuture<HTTPResponseStatus> {
    return { rq in
        rq.db.transaction { db in
            rq.eventLoop.dispatch {
                try closure(CO₂(rq: rq, db: db))
                return .ok
            }
        }
    }
}

public func transaction<E: ResponseEncodable>(use closure: @escaping (CO₂) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        return rq.db.transaction { db in
            rq.eventLoop.dispatch {
                try closure(CO₂(rq: rq, db: db)).encodeResponse(for: rq).wait()
            }
        }
    }
}

public func transaction<E: ResponseEncodable, User: Authenticatable>(use closure: @escaping (CO₂, User) throws -> E) -> (Request) throws -> EventLoopFuture<Response> {
    return { rq in
        let user = try rq.auth.require(User.self)
        return rq.db.transaction { db in
            rq.eventLoop.dispatch {
                try closure(CO₂(rq: rq, db: db), user).encodeResponse(for: rq).wait()
            }
        }
    }
}

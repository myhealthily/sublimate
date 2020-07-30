import FluentKit

public protocol SublimateModelMiddleware {
    associatedtype Model: FluentKit.Model

    func create(model: Model, on db: CO₂DB, next: AnyModelResponder) throws
    func update(model: Model, on db: CO₂DB, next: AnyModelResponder) throws
    func delete(model: Model, force: Bool, on db: CO₂DB, next: AnyModelResponder) throws
    func softDelete(model: Model, on db: CO₂DB, next: AnyModelResponder) throws
    func restore(model: Model, on db: CO₂DB, next: AnyModelResponder) throws
}

public extension SublimateModelMiddleware {
    func create(model: Model, on db: CO₂DB, next: AnyModelResponder) throws {
        try next.create(model, on: db.db).wait()
    }

    func update(model: Model, on db: CO₂DB, next: AnyModelResponder) throws {
        try next.update(model, on: db.db).wait()
    }

    func delete(model: Model, force: Bool, on db: CO₂DB, next: AnyModelResponder) throws {
        try next.delete(model, force: force, on: db.db).wait()
    }

    func softDelete(model: Model, on db: CO₂DB, next: AnyModelResponder) throws {
        try next.softDelete(model, on: db.db).wait()
    }

    func restore(model: Model, on db: CO₂DB, next: AnyModelResponder) throws {
        try next.restore(model, on: db.db).wait()
    }
}

private struct Wrapper<MW: SublimateModelMiddleware>: ModelMiddleware {
    let mw: MW

    func create(model: MW.Model, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        db.sublimate { db in
            try self.mw.create(model: model, on: db, next: next)
        }
    }

    func update(model: MW.Model, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        db.sublimate { db in
            try self.mw.update(model: model, on: db, next: next)
        }
    }

    func delete(model: MW.Model, force: Bool, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        db.sublimate { db in
            try self.mw.delete(model: model, force: force, on: db, next: next)
        }
    }

    func softDelete(model: MW.Model, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        db.sublimate { db in
            try self.mw.softDelete(model: model, on: db, next: next)
        }
    }

    func restore(model: MW.Model, on db: Database, next: AnyModelResponder) -> EventLoopFuture<Void> {
        db.sublimate { db in
            try self.mw.restore(model: model, on: db, next: next)
        }
    }
}

public extension FluentKit.Databases.Middleware {
    func use<MW: SublimateModelMiddleware>(_ mw: MW, on id: DatabaseID? = nil) {
        use(Wrapper<MW>(mw: mw), on: id)
    }
}

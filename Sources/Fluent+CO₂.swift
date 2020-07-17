import struct Vapor.Abort
import Fluent

public extension Array where Element: Model {
    func delete(on subl: CO₂DB) throws {
        try delete(on: subl.db).wait()
    }

    @discardableResult
    func create(on subl: CO₂DB) throws -> [Element] {
        try create(on: subl.db).wait()
        return self
    }
}

public extension Model {
    static func query(on subl: CO₂DB) -> SublimateQueryBuilder<Self> {
        return SublimateQueryBuilder(qb: query(on: subl.db))
    }

    static func find(_ id: IDValue?, on subl: CO₂DB) throws -> Self? {
        if let id = id {
            return try find(id, on: subl.db).wait()
        } else {
            return nil
        }
    }

    @discardableResult
    func create(on subl: CO₂DB) throws -> Self {
        try create(on: subl.db).wait()
        return self
    }

    @discardableResult
    func update(on subl: CO₂DB) throws -> Self {
        try update(on: subl.db).wait()
        return self
    }

    @discardableResult
    func save(on subl: CO₂DB) throws -> Self {
        try save(on: subl.db).wait()
        return self
    }

    func delete(on subl: CO₂DB) throws {
        try delete(on: subl.db).wait()
    }

    static func findOrAbort(_ id: IDValue, on subl: CO₂DB, file: String = #file, line: UInt = #line) throws -> Self {
        let e = Abort(.notFound, reason: "\(type(of: self)) not found for ID: \(id)", file: file, line: line)
        return try find(id, on: subl.db).unwrap(or: e).wait()
    }
}

public extension ParentProperty {
    func query(on subl: CO₂DB) -> SublimateQueryBuilder<To> {
        .init(qb: query(on: subl.db))
    }

    func get(on subl: CO₂DB) throws -> To {
        try query(on: subl).one()
    }
}

public extension ChildrenProperty {
    func query(on subl: CO₂DB) -> SublimateQueryBuilder<To> {
        .init(qb: query(on: subl.db))
    }

    func all(on subl: CO₂DB) throws -> [To] {
        try query(on: subl.db).all().wait()
    }
}

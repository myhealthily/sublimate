import FluentKit

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
        return SublimateQueryBuilder(query(on: subl.db))
    }

    static func find(_ id: IDValue?, on subl: CO₂DB) throws -> Self? {
        if let id = id {
            return try find(id, on: subl.db).wait()
        }
        return nil
    }

    static func find(or _: CO₂QueryOptions, id: IDValue?, on subl: CO₂DB, file: StaticString = #file, line: UInt = #line) throws -> Self {
        if let id = id {
            guard let model = try find(id, on: subl) else {
                throw SublimateAbort(.notFound, reason: "\(type(of: self)) not found for ID: \(id)", file: file, line: line)
            }
            return model
        }
        throw SublimateAbort(.badRequest, reason: "\(type(of: self)) not found for `nil` ID", file: file, line: line)
    }

    @discardableResult
    @inlinable
    func create(on subl: CO₂DB) throws -> Self {
        try create(on: subl.db).wait()
        return self
    }

    @discardableResult
    @inlinable
    func update(on subl: CO₂DB) throws -> Self {
        try update(on: subl.db).wait()
        return self
    }

    @discardableResult
    @inlinable
    func save(on subl: CO₂DB) throws -> Self {
        try save(on: subl.db).wait()
        return self
    }

    @inlinable
    func delete(on subl: CO₂DB) throws {
        try delete(on: subl.db).wait()
    }

    func restore(on subl: CO₂DB) throws {
        try restore(on: subl.db).wait()
    }
}

public extension ParentProperty {
    func query(on subl: CO₂DB) -> SublimateQueryBuilder<To> {
        .init(query(on: subl.db))
    }

    func get(on subl: CO₂DB, file: StaticString = #file, line: UInt = #line) throws -> To {
        try query(on: subl).first(or: .abort, file: file, line: line)
    }

    func load(on subl: CO₂DB) throws {
        try load(on: subl.db).wait()
    }
}

public extension ChildrenProperty {
    @inlinable
    func query(on subl: CO₂DB) -> SublimateQueryBuilder<To> {
        .init(query(on: subl.db))
    }

    @inlinable
    func all(on subl: CO₂DB) throws -> [To] {
        try query(on: subl.db).all().wait()
    }

    @inlinable
    func create(_ to: [To], on subl: CO₂DB) throws {
        try create(to, on: subl.db).wait()
    }

    @inlinable
    func create(_ to: To, on subl: CO₂DB) throws {
        try create(to, on: subl.db).wait()
    }

    @inlinable
    func load(on subl: CO₂DB) throws {
        try load(on: subl.db).wait()
    }
}

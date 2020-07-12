import struct Vapor.Abort
import Fluent

public struct SublimateQueryBuilder<T: Model> {
    let qb: QueryBuilder<T>
}

public extension SublimateQueryBuilder {
    @discardableResult
    func join<Foreign, Local, Value>(
        _ foreign: Foreign.Type,
        on filter: JoinFilter<Foreign, Local, Value>,
        method: DatabaseQuery.Join.Method = .inner
    ) -> Self
        where Foreign: Schema, Local: Schema
    {
        qb.join(foreign, on: filter, method: method)
        return self
    }

    @discardableResult
    func filter(_ filter: ModelValueFilter<T>) -> Self {
        qb.filter(filter)
        return self
    }

    @discardableResult
    func filter<Joined>(_ schema: Joined.Type, _ filter: FluentKit.ModelValueFilter<Joined>) -> Self where Joined : FluentKit.Schema {
        qb.filter(schema, filter)
        return self
    }

    func all() throws -> [T] {
        return try qb.all().wait()
    }

    func first() throws -> T? {
        return try qb.first().wait()
    }

    func one(file: String = #file, line: UInt = #line) throws -> T {
        guard let foo = try qb.first().wait() else {
            throw Abort(.notFound, reason: "\(T.self)s not found for this input.", file: file, line: line)
        }
        return foo
    }

    func one<M: Model>(with other: M.Type, file: String = #file, line: UInt = #line) throws -> (T, M) {
        guard let foo = try qb.first().wait() else {
            throw Abort(.notFound, reason: "\(T.self)s not found for this input.", file: file, line: line)
        }
        let bar = try foo.joined(other)
        return (foo, bar)
    }

    func count() throws -> Int {
        return try qb.count().wait()
    }

    func isEmpty() throws -> Bool {
        return try count() == 0
    }

    func isNotEmpty() throws -> Bool {
        return try count() > 0
    }

    @inlinable
    func exists() throws -> Bool {
        try isNotEmpty()
    }

    func sort<Field>(_ key: KeyPath<T, Field>, _ direction: DatabaseQuery.Sort.Direction = .ascending) -> Self where Field: QueryableProperty, Field.Model == T {
        _ = qb.sort(key, direction)
        return self
    }

    func range(_ range: PartialRangeThrough<Int>) -> Self {
        _ = qb.range(range)
        return self
    }

    func delete() throws {
        try qb.delete().wait()
    }
}

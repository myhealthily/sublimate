import struct Vapor.Abort
import Fluent

public extension CO₂ {
    enum QueryOptions {
        case abort
    }
}

public struct SublimateQueryBuilder<Model: FluentKit.Model> {
    // `public` so we can be inlinable
    public let kernel: QueryBuilder<Model>
}

public extension SublimateQueryBuilder {
    @discardableResult
    @inlinable
    func join<Foreign, Local, Value>(
        _ foreign: Foreign.Type,
        on filter: JoinFilter<Foreign, Local, Value>,
        method: DatabaseQuery.Join.Method = .inner
    ) -> Self
        where Foreign: Schema, Local: Schema
    {
        kernel.join(foreign, on: filter, method: method)
        return self
    }

    @discardableResult
    @inlinable
    func group(
        _ relation: DatabaseQuery.Filter.Relation = .and,
        _ closure: (QueryBuilder<Model>) throws -> ()
    ) rethrows -> Self {
        try kernel.group(relation, closure)
        return self
    }

    @discardableResult
    @inlinable
    func filter(_ filter: ModelValueFilter<Model>) -> Self {
        kernel.filter(filter)
        return self
    }

    @discardableResult
    @inlinable
    func filter<Joined>(_ schema: Joined.Type, _ filter: FluentKit.ModelValueFilter<Joined>) -> Self where Joined : FluentKit.Schema {
        kernel.filter(schema, filter)
        return self
    }

    @inlinable
    func all() throws -> [Model] {
        try kernel.all().wait()
    }

    @inlinable
    func first() throws -> Model? {
        try kernel.first().wait()
    }

    func first(or _: CO₂.QueryOptions, file: String = #file, line: UInt = #line) throws -> Model {
        guard let foo = try kernel.first().wait() else {
            throw Abort(.notFound, reason: "\(Model.self)s not found for this input.", file: file, line: line)
        }
        return foo
    }

    func first<With: FluentKit.Model>(or _: CO₂.QueryOptions, with other: With.Type, file: String = #file, line: UInt = #line) throws -> (Model, With) {
        guard let foo = try kernel.first().wait() else {
            throw Abort(.notFound, reason: "\(Model.self)s not found for this input.", file: file, line: line)
        }
        let bar = try foo.joined(other)
        return (foo, bar)
    }

    @inlinable
    func count() throws -> Int {
        try kernel.count().wait()
    }

    @inlinable
    func exists() throws -> Bool {
        try count() > 0
    }

    @inlinable
    func range(_ range: PartialRangeThrough<Int>) -> Self {
        _ = kernel.range(range)
        return self
    }

    @inlinable
    func delete() throws {
        try kernel.delete().wait()
    }
}

public extension SublimateQueryBuilder {
    @inlinable
    func with<Relation>(_ relationKey: KeyPath<Model, Relation>) -> Self where Relation: EagerLoadable, Relation.From == Model {
        kernel.with(relationKey)
        return self
    }
}

public extension SublimateQueryBuilder {
    @inlinable
    func sort<Field>(_ field: KeyPath<Model, Field>, _ direction: DatabaseQuery.Sort.Direction = .ascending) -> Self where Field: QueryableProperty, Field.Model == Model {
        _ = kernel.sort(field, direction)
        return self
    }

    @inlinable
    func sort(_ path: FieldKey, _ direction: DatabaseQuery.Sort.Direction = .ascending) -> Self {
        _ = kernel.sort(path, direction)
        return self
    }

    @inlinable
    func sort(_ path: [FieldKey], _ direction: DatabaseQuery.Sort.Direction = .ascending) -> Self {
        _ = kernel.sort(path, direction)
        return self
    }

    @inlinable
    func sort<Joined, Field>(
        _ joined: Joined.Type,
        _ field: KeyPath<Joined, Field>,
        _ direction: DatabaseQuery.Sort.Direction = .ascending,
        alias: String? = nil
    ) -> Self
    where
        Field: QueryableProperty,
        Field.Model == Joined,
        Joined: Schema
    {
        _ = kernel.sort(joined, field, direction, alias: alias)
        return self
    }

    @inlinable
    func sort<Joined>(
        _ model: Joined.Type,
        _ path: FieldKey,
        _ direction: DatabaseQuery.Sort.Direction = .ascending,
        alias: String? = nil
    ) -> Self
    where Joined: Schema
    {
        _ = kernel.sort(model, path, direction, alias: alias)
        return self
    }

    @inlinable
    func sort<Joined>(
        _ model: Joined.Type,
        _ path: [FieldKey],
        _ direction: DatabaseQuery.Sort.Direction = .ascending,
        alias: String? = nil
    ) -> Self
    where Joined: Schema
    {
        _ = kernel.sort(model, path, direction, alias: alias)
        return self
    }

    @inlinable
    func sort(
        _ field: DatabaseQuery.Field,
        _ direction: DatabaseQuery.Sort.Direction
    ) -> Self {
        _ = kernel.sort(field, direction)
        return self
    }

    @inlinable
    func sort(_ sort: DatabaseQuery.Sort) -> Self {
        _ = kernel.sort(sort)
        return self
    }
}

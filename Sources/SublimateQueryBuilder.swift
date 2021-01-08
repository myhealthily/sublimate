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

    // Allows you to convert `Fluent.QueryBuilder`s
    public init(_ kernel: QueryBuilder<Model>) {
        self.kernel = kernel
    }
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
    func filter<Field>(
        _ field: KeyPath<Model, Field>,
        _ method: DatabaseQuery.Filter.Method,
        _ value: Field.Value
    ) -> Self
        where Field: QueryableProperty, Field.Model == Model
    {
        kernel.filter(field, method, value)
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
    func limit(_ count: Int) -> Self {
        kernel.query.limits.append(.count(count))
        return self
    }

    @inlinable
    func offset(_ count: Int) -> Self {
        kernel.query.offsets.append(.count(count))
        return self
    }

    @inlinable
    func unique() -> Self {
        kernel.query.isUnique = true
        return self
    }

    @inlinable
    func chunk(max: Int, closure: @escaping ([Result<Model, Error>]) -> ()) throws -> Void {
        try kernel.chunk(max: max, closure: closure).wait()
    }

    @inlinable
    func first() throws -> Model? {
        try kernel.first().wait()
    }

    func first<With: FluentKit.Model>(with other: With.Type) throws -> (Model, With)? {
        if let foo = try kernel.first().wait() {
            let bar = try foo.joined(other)
            return (foo, bar)
        }
        return nil
    }

    func first<With: FluentKit.Model, And: FluentKit.Model>(with: With.Type, _ and: And.Type) throws -> (Model, With, And)? {
        if let foo = try kernel.first().wait() {
            let bar = try foo.joined(with)
            let baz = try foo.joined(and)
            return (foo, bar, baz)
        }
        return nil
    }

    func first(or _: CO₂.QueryOptions? = nil, file: String = #file, line: UInt = #line) throws -> Model {
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

public extension SublimateQueryBuilder {
    @inlinable
    func count() throws -> Int {
        try kernel.count().wait()
    }

    @inlinable
    func count<Field>(_ key: KeyPath<Model, Field>) throws -> Int
        where
            Field: QueryableProperty,
            Field.Model == Model
    {
        try kernel.count(key).wait()
    }

    @inlinable
    func sum<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value?
        where
            Field: QueryableProperty,
            Field.Model == Model
    {
        try kernel.sum(key).wait()
    }

    @inlinable
    func sum<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value
        where
            Field: QueryableProperty,
            Field.Value: OptionalType,
            Field.Model == Model
    {
        try kernel.sum(key).wait()
    }


    @inlinable
    func average<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value?
        where
            Field: QueryableProperty,
            Field.Model == Model
    {
        try kernel.average(key).wait()
    }

    @inlinable
    func average<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value
        where
            Field: QueryableProperty,
            Field.Value: OptionalType,
            Field.Model == Model
    {
        try kernel.average(key).wait()
    }

    @inlinable
    func min<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value?
        where
            Field: QueryableProperty,
            Field.Model == Model
    {
        try kernel.min(key).wait()
    }

    @inlinable
    func min<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value
        where
            Field: QueryableProperty,
            Field.Value: OptionalType,
            Field.Model == Model
    {
        try kernel.min(key).wait()
    }

    @inlinable
    func max<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value?
        where
            Field: QueryableProperty,
            Field.Model == Model
    {
        try kernel.max(key).wait()
    }

    @inlinable
    func max<Field>(_ key: KeyPath<Model, Field>) throws -> Field.Value
        where
            Field: QueryableProperty,
            Field.Value: OptionalType,
            Field.Model == Model
    {
        try kernel.max(key).wait()
    }
}

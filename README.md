# Sublimate

A developer-experience (DX) improvement layer for Vapor 4.

## Rationale

Swift is a remarkably safe language, predominantly because of its wonderful syntactic features.
However Vapor is built on NIO and NIO uses *futures*. Working with futures sucks.

Sublimate makes using Vapor procedural, like normal code.

### Pain Points Removed

* Bored with Swift complaining everything is ambiguous?
    > You will get 90% less of this.
* Finding doing (basic) logic tedious or untenable with futures?
    > You can write normal Swift with Sublimate

## Comparison

```swift
func route(on rq: Request) -> EventLoopFuture<[String]> {
    guard let groupID = rq.parameters.get("groupID") else {
        return rq.eventLoop.future(Abort(.badRequest))
    }
    return Group.find(groupID, on: rq)
        .unwrap(or: Abort(.notFound))
        .flatMap { group -> EventLoopFuture<[Association]> in
            guard group.enrolled else {
                return rq.eventLoop.makeFailedFuture(Abort(.notAcceptable))
            }
            return group.$associations.query(on: rq).all()
        }.map {
            $0.map(\.email)
        }
}
```

Versus:

```swift
let route = sublimate { rq -> [String] in
    let group = try Group.findOrAbort(rq.parameters.get("groupID"), on: rq) // †
    guard group.enrolled else { throw Abort(.notAcceptable) }
    return try group.$associations.all(on: rq).map(\.email) // ‡
}
```

> † Our find functions take optional IDs.\
> ‡ We provide convenience functions to keep your code tight; here you don’t have to call `query()` first.

We also provide `SublimateMigration`, which wraps your regular migration in a Sublimate+transaction layer for a more declarative syntax.

```swift
import Fluent
import SQLKit

public struct RenameMultipleItems: Migration {
    public func prepare(on db: Database) -> EventLoopFuture<Void> {
        db.transaction { db in
            let tx = (db as! SQLDatabase)
            return tx.raw(#"UPDATE payment_info SET "paymentStatus" = 'noPaymentMethod' WHERE "paymentID" IS NULL"#).run().flatMap {
                tx.raw(#"UPDATE payment_info SET "paymentStatus" = 'paymentMethodReceived' WHERE "paymentID" IS NOT NULL AND "paymentStatus" = 'unpaid'"#).run().flatMap {
                    tx.raw(#"UPDATE payment_info SET "paymentStatus" = 'errored' WHERE "paymentStatus" = 'error'"#).run()
                }
            }
        }
    }

    public func revert(on db: Database) -> EventLoopFuture<Void> {
        db.transaction { db in
            let tx = (db as! SQLDatabase)
            return tx.raw(#"UPDATE payment_info SET "paymentStatus" = 'unpaid' WHERE "paymentID" IS NULL"#).run().flatMap {
                tx.raw(#"UPDATE payment_info SET "paymentStatus" = 'unpaid' WHERE "paymentID" IS NOT NULL AND "paymentStatus" = 'paymentMethodReceived'"#).run().flatMap {
                    tx.raw(#"UPDATE payment_info SET "paymentStatus" = 'error' WHERE "paymentStatus" = 'errored'"#).run()
                }
            }
        }
    }
}
```

Versus:

```swift
import Sublimate
import Fluent

public struct OnlyHaveOnePaymentStatusType: SublimateMigration {
    public func prepare(on db: CO₂DB) throws {
        try db.raw(sql: #"UPDATE payment_info SET "paymentStatus" = 'noPaymentMethod' WHERE "paymentID" IS NULL"#).run()
        try db.raw(sql: #"UPDATE payment_info SET "paymentStatus" = 'paymentMethodReceived' WHERE "paymentID" IS NOT NULL AND "paymentStatus" = 'unpaid'"#).run()
        try db.raw(sql: #"UPDATE payment_info SET "paymentStatus" = 'errored' WHERE "paymentStatus" = 'error'"#).run()
    }

    public func revert(on db: CO₂DB) throws {
        try db.raw(sql: #"UPDATE payment_info SET "paymentStatus" = 'unpaid' WHERE "paymentID" IS NULL"#).run()
        try db.raw(sql: #"UPDATE payment_info SET "paymentStatus" = 'unpaid' WHERE "paymentID" IS NOT NULL AND "paymentStatus" = 'paymentMethodReceived'"#).run()
        try db.raw(sql: #"UPDATE payment_info SET "paymentStatus" = 'error' WHERE "paymentStatus" = 'errored'"#).run()
    }
}
```

## Examples

```swift
import Sublimate
import Vapor

private Response: Encodable {
    let foo: Foo
    let bar: Bool
}

let route = sublimate { rq -> Response in
    // ^^ `rq` is not a `Vapor.Request`, it is our own object that wraps the Vapor `Request`

    guard let parameter = rq.parameters.get("id") else {
        throw Abort(.badRequest)
    }

    let foo = try Foo.query(on: rq)
        .filter(\.$foo == parameter)
        .firstOrAbort()
    // ^^ `foo` is the model object, not a future
    // Sublimate provides `firstOrAbort` since we are a DX layer

    print(foo.baz)

    return Foo(foo: foo, bar: Bool.random())
}

app.routes.get("foo", ":id", use: route)
```

```swift
import Sublimate
import Vapor

private Response: Content {  // must be Content due to Vapor 4 restriction on returning Arrays
    let foo: Int
    let bar: Bool
}

let route = sublimate { (rq, user: User) -> [Response] in
    // ^^ `User` is your `Authenticatable` implementation
    // Sublimate automatically fetches this when you use the 2 parameter variant for your convenience

    let foos = try Foo.query(on: rq)
        .filter(\.$something == user.something)
        .all()

    // more easily use great Swift features like guard
    guard foos.count >= 2 else { throw … }

    // more easily use `for` loops and everything else too
    for foo in foos where foo.baz == .baz {
        guard … else { throw … }
    }

    // `Sequence.map` not `EventLoopFuture.map`
    return foos.map {
        try Response(foo: $0.foo, bar $0.bar == .bar)
    }
}

app.routes.get("foo", use: route)
```

## Usage

We have tried to provide sublimation for everything Vapor and Fluent provide, so generally you should
find it just works.

## Transactions

We provide `transaction()` to have an entire route in a transaction, usage is the same as `sublimate()`.

## Installation

```swift
package.dependencies.append(.package(
    url: "https://github.com/candor/sublimate.git",
    from: "0.4.0"
))
```

## How it works

Sublimate is a small wrapper on top of a `Request` and `Database` pair that mirrors most functions
and calls `wait()`.

This works because we also spawn a separate thread to `wait()` within.

### Why This is Fine

We found that mostly you have to fetch one thing at a time when doing Vapor dev anyway.

You *still can* fire off multiple requests simultaneously if you need to
(query on the `rq` property of your Sublimate object then use our `flatten()` function).

### Thread‑Safety

Sublimate is as thread-safe as Vapor; see their guidelines.

### Caveats

* This will cause a small performance hit to your server.
* Having multiple in-flight database requests simultaneously becomes more tedious (but is still possible).

## Dependencies

* Vapor 4 (for `Content`)
* Fluent (for `var Request.db`) †
* SQLKit (for `SQLDatabase.raw`, SQLKit is in fact a dependency of Fluent *anyway*)
* Swift 5.2 (due to Vapor 4)
* macOS 10.15 (Catalina), (due to Vapor 4), or any Swift 5.2 supported Linux

> † We cannot just depend on FluentKit due to the need for `rq.db`.

## Suggested Usage

* We suggest a separate module for your routes.
* We don’t suggest controllers, but using controllers should still be fine, if not open a ticket and we’ll look into what we can do to improve this usage.

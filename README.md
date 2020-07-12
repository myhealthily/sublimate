# Sublimate

A developer-experience (DX) improvement layer for Vapor 4.

# Rational

Swift is a remarkably safe language, predominantly because of its wonderful syntatic features.
However Vapor is built on NIO and NIO uses *futures*. Working with futures sucks.

Sublimate makes using Vapor procedural, like normal code.

# Examples

```swift
import Sublimate

private Response: Encodable {
    let foo: Foo
    let bar: Bool
}

let route = sublimate<User> { rq, user -> Response in
    guard let parameter = rq.parameters.get("id") else {
        throw Abort(.badRequest)
    }

    let foo = try Foo.query(on: rq)
        .filter(\.$foo == parameter)
        .firstOrAbort()
    // ^^ `foo` is the model object, not a future

    return Foo(foo: foo, bar: Bool.random())
}

app.routes.get("foo", ":id", use: route)
```

```swift
import Sublimate

private Response: Content {  // must be Content due to Vapor 4 restriction on returning Arrays
    let foo: Int
    let bar: Bool
}

let route = sublimate<User> { rq, user -> [Response] in
    // ^^ `User` is your `Authenticatable` implementation

    let foos = try Foo.query(on: rq)
        .filter(\.$something == user.something)
        .all()
        
    // use great Swift features like guard
    guard foos.count >= 2 else { throw … }
    
    // use `for` loops and everything else too
    for (foo in foos) where foo.baz == .baz {
        guard … else { throw … }
    }
    
    return foos.map {
        try Repsonse(foo: $0.foo, bar $0.bar == .bar)
    }
}

app.routes.get("foo", use: route)
```

# How it works

Sublimate is a small wrapper on top of a `Request` and `Database` pair that mirrors most functions
and calls `wait()`.

This works because we also spawn a separate thread to `wait()` within.

## Caveats

* This will cause a small performance hit to your server.
* Having multiple in flight database requests simultaneously becomes more tedious (but is still possible).

## Dependencies

* Vapor 4 (for `Content`)
* Fluent (for `var Request.db`)†
* SQLKit (for `SQLDatabase.raw`, SQLKit is in fact a dependency of Fluent *anyway*)

> † We cannot just depend on FluentKit due to the need for `rq.db`.

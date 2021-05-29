import class Dispatch.DispatchQueue
import class NIO.EventLoopFuture
import protocol NIO.EventLoop

public extension DispatchQueue {
    /// `DispatchQueue.async` but returning a NIO future wrapping the closure return.
    func async<Value>(on eventLoop: EventLoop, use closure: @escaping () throws -> Value) -> EventLoopFuture<Value> {
        let promise = eventLoop.makePromise(of: Value.self)
        async {
            do {
                promise.succeed(try closure())
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
}

public extension Collection {
    /**
     Waits on a `Collection` of `EventLoopFuture` returning `Array<EventLoopFuture.Value>`
     - Note: the order of the results will match the order of the EventLoopFutures in the input `Collection`.
     - Note: They must be the same type, a strategy for waiting on mixed futures is to `Void` them all and then work with the original futures
     */
    func flatten<Value>(on db: CO₂NIO) throws -> [Value] where Element == EventLoopFuture<Value> {
        try EventLoopFuture.whenAllSucceed(Array(self), on: db.eventLoop).wait()
    }
}

public extension Collection where Element == EventLoopFuture<Void> {
    /// Waits on a `Collection` of `EventLoopFuture<Void>`
    func flatten(on db: CO₂NIO) throws {
        _ = try EventLoopFuture.whenAllSucceed(Array(self), on: db.eventLoop).wait()
    }
}

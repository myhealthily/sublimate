import class Dispatch.DispatchQueue
import NIO

public extension EventLoop {
    func dispatch<T>(use closure: @escaping () throws -> T) -> EventLoopFuture<T> {
        let promise = makePromise(of: T.self)
        DispatchQueue.global().async {
            do {
                promise.succeed(try closure())
            } catch {
                promise.fail(error)
            }
        }
        return promise.futureResult
    }
}

public extension EventLoopFuture {
    /// better readability in our “syncronous” world
    /// - Note: will crash your app if you didn’t `wait()` first or use a Sublimate method to get the future
    var value: Value {
        return try! wait()
    }
}

extension Collection {
    /// Flattens an array of EventLoopFutures into a EventLoopFuture with an array of results.
    /// - note: the order of the results will match the order of the EventLoopFutures in the input array.
    public func flatten<T>(on subl: CO₂) throws -> [T] where Element == EventLoopFuture<T> {
        return try EventLoopFuture.whenAllSucceed(Array(self), on: subl.eventLoop).wait()
    }
}

extension Collection where Element == EventLoopFuture<Void> {
/// Flattens an array of void EventLoopFutures into a single one.
    public func flatten(on subl: CO₂) throws {
        _ = try EventLoopFuture.whenAllSucceed(Array(self), on: subl.eventLoop).wait()
    }
}

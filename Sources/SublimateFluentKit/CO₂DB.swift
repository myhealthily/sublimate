import SublimateNIO
import FluentKit

public protocol CO₂DB: CO₂NIO {
    var db: Database { get }
}

public extension CO₂DB {
    var eventLoop: EventLoop { db.eventLoop }
}

public struct ConcreteCO₂DB: CO₂DB {
    public let db: Database

    public init(db: Database) {
        self.db = db
    }
}

public enum CO₂QueryOptions {
    case abort
}

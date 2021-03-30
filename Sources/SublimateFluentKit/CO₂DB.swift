import SublimateNIO
import FluentKit

public protocol CO₂DB: CO₂Protocol {
    var db: Database { get }
}

public extension CO₂DB {
    var eventLoop: EventLoop { db.eventLoop }
}

struct CO₂DBStruct: CO₂DB {
    let db: Database
}

public enum CO₂QueryOptions {
    case abort
}

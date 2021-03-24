import SublimateNIO
import FluentKit

public protocol CO₂DB: CO₂Protocol {
    var db: Database { get }
}

struct CO₂DBStruct {
    let db: Database
}

extension CO₂DBStruct: CO₂DB {
    var eventLoop: EventLoop { db.eventLoop }
}

public enum CO₂QueryOptions {
    case abort
}

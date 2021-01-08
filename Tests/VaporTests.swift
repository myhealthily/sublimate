import Sublimate
import XCTest
import Vapor

class VaporTests: CO₂TestCase {
    func testRequestSublimate() throws {
        app.routes.get("foo", use: { rq in
            rq.sublimate { rq in
                HTTPResponseStatus.ok
            }
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: { XCTAssertEqual($0.status, .ok) })
    }

    func testDatabaseSublimate() throws {
        app.routes.get("foo", use: { rq in
            rq.db.sublimate { db in
                HTTPResponseStatus.ok
            }
        })

        try app.testable(method: .inMemory).test(.GET, "foo", afterResponse: { XCTAssertEqual($0.status, .ok) })
    }
}

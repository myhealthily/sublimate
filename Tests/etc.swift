import FluentSQLiteDriver
import Sublimate
import Fluent
import XCTest
import Vapor

class CO₂TestCase: XCTestCase {
    var app: Application!

    override func setUp() {
        app = Application(.testing)
        app.databases.use(.sqlite(.memory), as: .sqlite)
        let migrations = self.migrations
        app.migrations.add(migrations)
        app.migrations.add(sublimateMigrations)
        if hasMigrations {
            try! app.autoMigrate().wait()
        }
    }

    var migrations: [Migration] {[]}
    var sublimateMigrations: [SublimateMigration] {[]}

    var hasMigrations: Bool { !(migrations.isEmpty && sublimateMigrations.isEmpty) }

    override func tearDown() {
        if hasMigrations {
            try! app.autoRevert().wait()
        }
        app.shutdown()
    }
}

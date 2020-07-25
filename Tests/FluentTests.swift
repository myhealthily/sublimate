@testable import Sublimate
import XCTFluent
import Fluent
import XCTest

final class FluentTests: XCTestCase {
    var db: ArrayTestDatabase!

    override func setUp() {
        db = ArrayTestDatabase()
        db.append(input)
    }

    func testAll() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try TestModel.query(on: db).all(),
                input)
        }.wait()
    }

    func testFilter() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try TestModel.query(on: db).filter(\.$field == "foo").first(or: .abort).field,
                "foo")
        }.wait()
    }
}

private let input = [
    TestModel(field: "foo"),
    TestModel(field: "bar")
]

private final class TestModel: Model {
    @ID(key: .id) var id: UUID?
    @Field(key: "field") var field: String

    init()
    {}

    init(field: String) {
        self.id = UUID()
        self.field = field
    }

    static let schema = "models"
}

extension TestModel: Equatable {
    static func == (lhs: TestModel, rhs: TestModel) -> Bool {
        lhs.id == rhs.id
    }
}

extension TestDatabase {
    func sublimate<T>(use closure: @escaping (CO₂DB) throws -> T) -> EventLoopFuture<T> {
        DispatchQueue.global().async(on: db.eventLoop) {
            try closure(CO₂DB(db: self.db))
        }
    }
}

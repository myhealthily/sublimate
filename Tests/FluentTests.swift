@testable import Sublimate
import XCTFluent
import Fluent
import XCTest

final class FluentTests: CO₂TestCase {
    var db: Database { app.db }
    private var input: [(Star, [Planet])]!

    override func setUp() {
        input = [
            (Star(name: "The Sun", distance: 149_597_870), [Planet(name: "Mercury"), Planet(name: "Venus"), Planet(name: "Earth")]),
            (Star(name: "Proxima Centauri", distance: 40_208_000_000_000), []),
            (Star(name: "Alpha Centauri A"), []),
            (Star(name: "Alpha Centauri B"), [])
        ]
        super.setUp()
    }

    override func tearDown() {
        input = []
        super.tearDown()
    }

    override var sublimateMigrations: [SublimateMigration] {
        [Migration(input: input)]
    }

    func testFirst() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Star.query(on: db).filter(\.$name == "The Sun").first()?.name,
                "The Sun")
            XCTAssertEqual(
                try Star.query(on: db).filter(\.$name == "The Sun").first(or: .abort).name,
                "The Sun")
            XCTAssertThrowsError(try Star.query(on: db).filter(\.$name == "Betelgeuse").first(or: .abort))
        }.wait()
    }

    func testAll() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Star.query(on: db).all(),
                self.input.map(\.0))
        }.wait()
    }

    func testFilter() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Star.query(on: db).filter(\.$name == "The Sun").first(or: .abort).name,
                "The Sun")
            XCTAssertEqual(
                try Star.query(on: db).filter(\.$name, .equal, "The Sun").first(or: .abort).name,
                "The Sun")
        }.wait()
    }

    func testRange() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Planet.query(on: db).range(...1).count(),
                3) // Vapor is b0rked?
        }.wait()
    }

    func testSort() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Planet.query(on: db).sort(\.$name, .ascending).all().map(\.name),
                ["Earth", "Mercury", "Venus"])
            XCTAssertEqual(
                try Planet.query(on: db).sort(\.$name).all().map(\.name),
                ["Earth", "Mercury", "Venus"])
            XCTAssertEqual(try Planet.query(on: db).sort([.id]).all().count, 3)
            XCTAssertEqual(try Planet.query(on: db).sort([.id], .descending).all().count, 3)
            XCTAssertEqual(try Planet.query(on: db).sort(.string("name")).all().count, 3)
            XCTAssertEqual(try Planet.query(on: db).sort(.string("name"), .descending).all().count, 3)
            XCTAssertEqual(try Planet.query(on: db).sort(.sort(.path([.string("name")], schema: Planet.schema), .ascending)).all().count, 3)
            XCTAssertEqual(try Planet.query(on: db).sort(.path([.string("name")], schema: Planet.schema), .descending).all().count, 3)
        }.wait()
    }

    func testDelete() throws {
        try db.sublimate { db in
            try Planet.query(on: db).filter(\.$name == "Earth").delete()
            XCTAssertEqual(try Planet.query(on: db).count(), 2)
        }.wait()
    }

    func testExists() throws {
        try db.sublimate { db in
            XCTAssertTrue(try Star.query(on: db).filter(\.$name == "The Sun").exists())
        }.wait()
    }

    func testCount() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Star.query(on: db).count(),
                self.input.count)
        }.wait()
    }

    func testCountField() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Star.query(on: db).count(\.$distance),
                2)
        }.wait()
    }

    func testSum() throws {
        try db.sublimate { db in
            XCTAssertEqual(
                try Star.query(on: db).sum(\.$distance),
                self.input.compactMap { (star, _) -> Double? in
                    return star.distance
                }.reduce(0, +))
        }.wait()
    }

    func testAverage() throws {
        try db.sublimate { db in
            let starsAverageDistance = try Star.query(on: db).average(\.$distance)!
            let distances = self.input.compactMap { (star, _) -> Double? in
                return star.distance
            }
            XCTAssertEqual(starsAverageDistance, distances.reduce(0, +) / Double(distances.count))
        }.wait()
    }

    func testMin() throws {
        try db.sublimate { db in
            let minStar = try Star.query(on: db).min(\.$distance)!
            let min = self.input.compactMap { $0.0.distance }.min()!
            XCTAssertEqual(minStar, min)
        }.wait()
    }

    func testMax() throws {
        try db.sublimate { db in
            let maxStar = try Star.query(on: db).max(\.$distance)!
            let max = self.input.compactMap { $0.0.distance }.max()!
            XCTAssertEqual(maxStar, max)
        }.wait()
    }

    func testFirstWith() throws {
        try db.sublimate { db in
            let tuple = try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .first(with: Star.self)

            XCTAssertEqual(tuple?.0.$star.id, tuple?.1.id)
            XCTAssertEqual(tuple?.1.name, "The Sun")

            XCTAssertThrowsError(try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .filter(Planet.self, \.$name == "Saturn")
                .first(or: .abort, with: Star.self))
        }.wait()
    }

    func testFirstWithOrAbort() throws {
        try db.sublimate { db in
            let (planet, star) = try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .first(or: .abort, with: Star.self)

            XCTAssertEqual(planet.$star.id, star.id)
            XCTAssertEqual(star.name, "The Sun")

            XCTAssertThrowsError(try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .filter(Planet.self, \.$name == "Saturn")
                .first(or: .abort, with: Star.self))
        }.wait()
    }

    func testFirstWithAnd() throws {
        try db.sublimate { db in
            let tuple = try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .first(with: Star.self, Star.self)

            XCTAssertEqual(tuple?.0.$star.id, tuple?.1.id)
            XCTAssertEqual(tuple?.0.$star.id, tuple?.2.id)
            XCTAssertEqual(tuple?.1.name, "The Sun")
            XCTAssertEqual(tuple?.2.name, "The Sun")

            XCTAssertThrowsError(try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .filter(Planet.self, \.$name == "Saturn")
                .first(or: .abort, with: Star.self))
        }.wait()
    }

    func testWith() throws {
        try db.sublimate { db in
            for planet in try Planet.query(on: db).with(\.$star).all() {
                XCTAssertEqual(planet.star.name, "The Sun")
            }
        }.wait()
    }

    func testJoinFilter() throws {
        try db.sublimate { db in
            let star = try Star.query(on: db)
                .join(Planet.self, on: \Star.$id == \.$star.$id)
                .filter(Planet.self, \.$name == "Earth")
                .first()
            XCTAssertEqual(star?.name, "The Sun")
        }.wait()
    }

    func testJoinSort() throws {
        try db.sublimate { db in
            let star1 = try Star.query(on: db)
                .join(Planet.self, on: \Star.$id == \.$star.$id)
                .sort(Planet.self, \.$name)
                .first()
            XCTAssertEqual(star1?.name, "The Sun")

            let star2 = try Star.query(on: db)
                .join(Planet.self, on: \Star.$id == \.$star.$id)
                .sort(Planet.self, [.string("name")])
                .first()
            XCTAssertEqual(star2?.name, "The Sun")

            let star3 = try Star.query(on: db)
                .join(Planet.self, on: \Star.$id == \.$star.$id)
                .sort(Planet.self, .string("name"))
                .first()
            XCTAssertEqual(star3?.name, "The Sun")
        }.wait()
    }

    func testLimit() throws {
        try db.sublimate { db in
            let stars = try Star.query(on: db)
                .limit(1)
                .all()
            XCTAssertEqual(stars, [self.input[0].0])
        }.wait()
    }

    func testOffset() throws {
        try db.sublimate { db in
            let stars = try Star.query(on: db)
                .limit(2)
                .offset(1)
                .all()
            XCTAssertEqual(stars, self.input[1...2].map { $0.0 })
        }.wait()
    }

    func testUnique() throws {
        try db.sublimate { db in
            let stars = try Star.query(on: db)
                .join(Planet.self, on: \Star.$id == \.$star.$id)
                .filter(Star.self, \.$name == "The Sun")
                .all()
            XCTAssertEqual(stars.first?.name, "The Sun")
        }.wait()
    }

    func testGroup() throws {
        try db.sublimate { db in
            let planets = try Planet.query(on: db)
                .group {
                    $0.filter(\.$name == "Earth")
                }.all()
            XCTAssertEqual(planets.count, 1)
        }.wait()
    }
}

private final class Star: Model {
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    @Field(key: "distance") var distance: Double? // in km
    @Children(for: \.$star) var planets: [Planet]

    init()
    {}

    init(name: String, distance: Double? = nil) {
        self.name = name
        self.distance = distance
    }

    static let schema = "stars"
}

private final class Planet: Model {
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    @Parent(key: "star_id") var star: Star

    init()
    {}

    init(name: String) {
        self.name = name
    }

    static let schema = "planets"
}

extension Star: Equatable {
    static func == (lhs: Star, rhs: Star) -> Bool {
        lhs.id == rhs.id
    }
}

private struct Migration: SublimateMigration {
    let input: [(Star, [Planet])]

    func prepare(on db: CO₂DB) throws {
        try db.schema(Star.schema)
            .id()
            .field("name", .string, .required)
            .field("distance", .double)
            .create()
        try db.schema(Planet.schema)
            .id()
            .field("name", .string, .required)
            .field("star_id", .uuid, .required, .references(Star.schema, "id"))
            .create()
        for (star, planets) in input {
            try star.create(on: db)
            try star.$planets.create(planets, on: db)
        }
    }

    func revert(on db: CO₂DB) throws {
        try db.schema(Planet.schema).delete()
        try db.schema(Star.schema).delete()
    }
}

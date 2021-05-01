@testable import Sublimate
import XCTFluent
import Fluent
import XCTest

final class FluentTests: CO₂TestCase {
    var db: Database { app.db }
    private var input: [(Star, [Planet])]!

    override func setUp() {
        input = [
            (Star(name: "The Sun", distance: 149_597_870, mass: 1.939e30), [Planet(name: "Mercury"), Planet(name: "Venus"), Planet(name: "Earth")]),
            (Star(name: "Proxima Centauri", distance: 40_208_000_000_000, mass: 2.446e29), []),
            (Star(name: "Alpha Centauri A", mass: 2.188e30), []),
            (Star(name: "Alpha Centauri B", mass: 1.804e30), [])
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

    func testArrayDelete() throws {
        try db.sublimate { db in
            let planets = try Planet.query(on: db).filter(\.$name == "Earth").all()
            try planets.delete(on: db)
            XCTAssertEqual(try Planet.query(on: db).count(), 2)
        }.wait()
    }

    func testArrayCreate() throws {
        try db.sublimate { db in
            try [
                Star(name: "Barnard's Star", mass: 2.864e29),
                Star(name: "Wolf 359", mass: 1.79e29),
            ].create(on: db)
            XCTAssertEqual(try Star.query(on: db).count(), self.input.count + 2)
        }.wait()
    }

    func testFind() throws {
        try db.sublimate { db in
            let first = try Star.query(on: db).first()!
            XCTAssertEqual(first, try Star.find(first.id, on: db))
            XCTAssertNil(try Star.find(UUID(), on: db))
            XCTAssertNil(try Star.find(nil, on: db))

            XCTAssertEqual(first, try Star.find(or: .abort, id: first.id, on: db))
            XCTAssertThrowsError(try Star.find(or: .abort, id: UUID(), on: db))
            XCTAssertThrowsError(try Star.find(or: .abort, id: nil, on: db))
        }.wait()
    }

    func testSave() throws {
        try db.sublimate { db in
            let star = try Star.query(on: db).first()!
            star.name = "Some other star"
            try star.save(on: db)
            XCTAssertEqual(star, try Star.find(star.id, on: db))
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
                self.input.compactMap(\.0.distance).reduce(0, +))

            XCTAssertEqual(
                try Star.query(on: db).sum(\.$mass),
                self.input.map(\.0.mass).reduce(0, +))
        }.wait()
    }

    func testAverage() throws {
        try db.sublimate { db in
            let starsAverageDistance = try Star.query(on: db).average(\.$distance)!
            let distances = self.input.compactMap(\.0.distance)
            XCTAssertEqual(starsAverageDistance, distances.reduce(0, +) / Double(distances.count))

            let starsAverageMass = try Star.query(on: db).average(\.$mass)
            let masses = self.input.map(\.0.mass)
            XCTAssertEqual(starsAverageMass, masses.reduce(0, +) / Double(masses.count))
        }.wait()
    }

    func testMin() throws {
        try db.sublimate { db in
            let minDistance = try Star.query(on: db).min(\.$distance)!
            let minDistance2 = self.input.compactMap { $0.0.distance }.min()!
            XCTAssertEqual(minDistance, minDistance2)

            let minMass = try Star.query(on: db).min(\.$mass)
            let minMass2 = self.input.map(\.0.mass).min()
            XCTAssertEqual(minMass, minMass2)
        }.wait()
    }

    func testMax() throws {
        try db.sublimate { db in
            let maxDistance = try Star.query(on: db).max(\.$distance)!
            let maxDistance2 = self.input.compactMap { $0.0.distance }.max()!
            XCTAssertEqual(maxDistance, maxDistance2)

            let maxMass = try Star.query(on: db).max(\.$mass)
            let maxMass2 = self.input.map(\.0.mass).max()
            XCTAssertEqual(maxMass, maxMass2)
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

            XCTAssertNil(try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .filter(Planet.self, \.$name == "Tiny Planet")
                .first(with: Star.self))
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

            XCTAssertNil(try Planet.query(on: db)
                .join(Star.self, on: \Planet.$star.$id == \.$id)
                .filter(Planet.self, \.$name == "Tiny Planet")
                .first(with: Star.self, Star.self))
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
                .unique()
                .all()
            XCTAssertEqual(stars.first?.name, "The Sun")
        }.wait()
    }

    func testChunk() throws {
        try db.sublimate { db in
            var total = 0
            try Star.query(on: db).chunk(max: 1) { star in
                XCTAssertEqual(star.count, 1)
                total += 1
            }
            XCTAssertEqual(total, 4)
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

    func testParent() throws {
        try db.sublimate { db in
            let earth = try Planet.query(on: db).filter(\.$name == "Earth").first()!
            let sun = try earth.$star.query(on: db).first()!
            XCTAssertEqual(sun, self.input.first(where: { $0.0.name == "The Sun" })!.0)

            XCTAssertEqual(sun, try earth.$star.get(on: db))

            try earth.$star.load(on: db)
            XCTAssertEqual(sun, earth.star)
        }.wait()
    }

    func testChildren() throws {
        try db.sublimate { db in
            let sun = try Star.query(on: db).filter(\.$name == "The Sun").first()!
            let planets = try sun.$planets.query(on: db).all()
            XCTAssertEqual(planets, self.input.first(where: { $0.0.name == "The Sun" })!.1)

            XCTAssertEqual(planets, try sun.$planets.all(on: db))

            try sun.$planets.load(on: db)
            XCTAssertEqual(planets, sun.planets)

            let mars = Planet(name: "Mars")
            try sun.$planets.create(mars, on: db)
            XCTAssertEqual(try sun.$planets.all(on: db), self.input.first(where: { $0.0.name == "The Sun" })!.1 + [mars])
        }.wait()
    }

    func testWithDeleted() throws {
        try db.sublimate { db in
            let sun = try Star.query(on: db).filter(\.$name == "The Sun").first()!
            XCTAssertEqual(sun, self.input.first(where: { $0.0.name == "The Sun" })!.0)
            try sun.delete(on: db)

            let noSun = try Star.query(on: db).filter(\.$name == "The Sun").first()
            XCTAssertNil(noSun)

            let deletedSun = try Star.query(on: db).filter(\.$name == "The Sun").withDeleted().first()!
            XCTAssertNotNil(deletedSun.deletedAt)
        }.wait()
    }
}

private final class Star: Model {
    @ID(key: .id) var id: UUID?
    @Field(key: "name") var name: String
    @OptionalField(key: "distance") var distance: Double? // in km
    @Field(key: "mass") var mass: Double // in kg
    @Timestamp(key: "deleted_at", on: .delete) var deletedAt: Date?
    @Children(for: \.$star) var planets: [Planet]

    init()
    {}

    init(name: String, distance: Double? = nil, mass: Double) {
        self.name = name
        self.distance = distance
        self.mass = mass
        self.deletedAt = nil
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

extension Planet: Equatable {
    static func == (lhs: Planet, rhs: Planet) -> Bool {
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
            .field("mass", .double)
            .field("deleted_at", .date)
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

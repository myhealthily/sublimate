import FluentSQLiteDriver
import Sublimate
import Fluent
import Vapor

let app = Application(.production)
app.logger.logLevel = .error
app.databases.use(.sqlite(), as: .sqlite)

app.routes.get("/std") { _ in
    HTTPStatus.ok
}

app.routes.get("/CO2") { _ in
    HTTPStatus.ok
}

defer { app.shutdown() }
try app.run()

import Fluent
import Vapor

func routes(_ app: Application) throws {
    app.get { req in
        return "It's alive!"
    }
//
//    app.get("hello") { req -> String in
//        return "Hello, world!"
//    }

    try app.register(collection: EarthModelController())
    try app.register(collection: CountryModelController())
    try app.register(collection: GameController())
    
}

//
//  LoginTests.swift
//  
//
//  Created by Maarten Engels on 11/01/2022.
//

@testable import App
import XCTVapor

final class LoginTests: XCTestCase {
    var app: Application!
    
    let TEST_PLAYER_EMAIL = "test@example.org"
    let TEST_PASSWORD = "12345678"
    let TEST_PLAYER_NAME = "testUser"
    
    var testPlayerToken: UserToken?
    
    override func setUpWithError() throws {
        print("setUpWithError")
        app = Application(.testing)
        app.environment = .testing
        //defer { app.shutdown() }
        try configure(app)
        
        _ = try Player.query(on: app.db).count().wait()
    }
    
    override func tearDown() {
        print("setUpWithError")
        
        try? cleanup()
        
        app.shutdown()
    }
    
    func testNocredentialsGives401() throws {
        try app.test(.POST, "players/login") { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func cleanup() throws {
        let players = try Player.query(on: app.db).all().wait()
        
        try players.forEach { player in
                try player.delete(on: app.db).wait()
        }
    }
    
    func testCreatePlayer() throws {
        try cleanup()
        
        let playerCreate = Player.Create(name: TEST_PLAYER_NAME, email: TEST_PLAYER_EMAIL, password: TEST_PASSWORD, confirmPassword: TEST_PASSWORD)
        
        try app.test(.POST, "players", beforeRequest: { req in
            try req.content.encode(playerCreate)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            XCTAssertEqual(try res.content.decode(String.self), "Player succesfully created. You can now log in.")
        }
    }
    
    func testLoginPlayerUserIDPassword() throws {
        try cleanup()
        
        try testCreatePlayer()
        
        try app.test(.POST, "players/login", beforeRequest: { req in
            req.headers.basicAuthorization = .init(username: TEST_PLAYER_EMAIL, password: TEST_PASSWORD)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let token = try res.content.decode(UserToken.self)
            let player = try token.$player.get(on: app.db).wait()
            
            XCTAssertEqual(player.name, TEST_PLAYER_NAME)
            XCTAssertEqual(player.email, TEST_PLAYER_EMAIL)
            
            testPlayerToken = token
        }
    }
    
    func testLoginPlayerUserIDInvalidPasswordFails() throws {
        try cleanup()
        
        try testCreatePlayer()
        
        try app.test(.POST, "players/login", beforeRequest: { req in
            req.headers.basicAuthorization = .init(username: TEST_PLAYER_EMAIL, password: TEST_PASSWORD + "_INVALID")
        }) { res in
            XCTAssertEqual(res.status, .unauthorized)
        }
    }
    
    func testLoginPlayerToken() throws {
        try cleanup()
        
        try testLoginPlayerUserIDPassword()
        
        guard let token = testPlayerToken else {
            XCTFail("Expected token, but was not set.")
            return
        }
        
        try app.test(.GET, "players/checkLogin", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: token.value)
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let result = try res.content.decode(Bool.self)
            XCTAssertTrue(result)
        }
    }
    
    func testLoginPlayerInvalidTokenFails() throws {
        try cleanup()
        
        try testLoginPlayerUserIDPassword()
        
        try app.test(.GET, "players/checkLogin", beforeRequest: { req in
            req.headers.bearerAuthorization = .init(token: "foo")
        }) { res in
            XCTAssertEqual(res.status, .ok)
            let result = try res.content.decode(Bool.self)
            XCTAssertFalse(result)
        }
    }
    
    func testLoginPlayerNoTokenFails() throws {
        try cleanup()
        
        try testLoginPlayerUserIDPassword()
        
        try app.test(.GET, "players/checkLogin") { res in
            XCTAssertEqual(res.status, .ok)
            let result = try res.content.decode(Bool.self)
            XCTAssertFalse(result)
        }
    }
}

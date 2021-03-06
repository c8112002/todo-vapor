//
//  TodoServiceTest.swift
//  AppTests
//
//  Created by Masahiko Sato on 2018/10/17.
//
@testable import App
import XCTest
import Vapor
import FluentSQLite

final class TodoServiceTests: BaseTestCase {
    
    var todoService: TodoServiceType!
    var conn: SQLiteConnection!
    
    override func setUp() {
        super.setUp()
        conn = try! app.newConnection(to: .sqlite).wait()
        todoService = try! app.make(TodoServiceType.self)
    }

    func testRetrieveAllTodos() throws {
        prepareTodos(on: conn)

        let todos = try todoService.retrieveAllTodos(on: conn).wait()
        
        XCTAssertEqual(2, todos.count, "全件取得できること")
        
        XCTAssertEqual(1, todos[0].id)
        XCTAssertEqual("title1", todos[0].title)
        XCTAssertEqual("detail1", todos[0].detail)
        XCTAssertFalse(todos[0].done)
        
        XCTAssertEqual(2, todos[1].id)
        XCTAssertEqual("title2", todos[1].title)
        XCTAssertEqual(nil, todos[1].detail)
        XCTAssertTrue(todos[1].done)
    }
    
    func testRetrieveTodo() throws {
        prepareTodos(on: conn)

        let todo1 = try todoService.retrieveTodo(id: 1, on: conn).wait()
        XCTAssertEqual(1, todo1.id)
        XCTAssertEqual("title1", todo1.title)
        XCTAssertEqual("detail1", todo1.detail)
        XCTAssertFalse(todo1.done)
        
        let todo2 = try todoService.retrieveTodo(id: 2, on: conn).wait()
        XCTAssertEqual(2, todo2.id)
        XCTAssertEqual("title2", todo2.title)
        XCTAssertEqual(nil, todo2.detail)
        XCTAssertTrue(todo2.done)
    }
    
    func testRetrieveTodo_idが不正な場合例外を投げること() throws {
        prepareTodos(on: conn)

        XCTAssertThrowsError(try todoService.retrieveTodo(id: 3, on: conn).wait()) { error in
            XCTAssertEqual(error as? CustomError, CustomError.notFoundTodo)
        }
    }
    
    func testCreateTodo() throws {
        let request = TodoRequest(title: "title1", detail: "detail1", done: false)
        let todos = try todoService.createTodo(request, on: conn).wait()
        
        XCTAssertEqual(1, todos.count)
        XCTAssertEqual(1, todos[0].id)
        XCTAssertEqual("title1", todos[0].title)
        XCTAssertEqual("detail1", todos[0].detail)
        XCTAssertEqual(false, todos[0].done)
    }
    
    func testEditTodo() throws {
        prepareTodos(on: conn)
        let request = TodoRequest(title: "title", detail: "detail", done: true)
        let todos = try todoService.editTodo(request , id: 1, on: conn).wait()

        XCTAssertEqual(2, todos.count)

        let todo = try todoService.retrieveTodo(id: 1, on: conn).wait()
        XCTAssertEqual(1, todo.id)
        XCTAssertEqual("title", todo.title)
        XCTAssertEqual("detail", todo.detail)
        XCTAssertEqual(true, todo.done)
    }
    
    func testEditTodo_idが不正な場合例外を投げること() throws {
        prepareTodos(on: conn)
        
        let request = TodoRequest(title: "title", detail: "detail", done: true)
        XCTAssertThrowsError(try todoService.editTodo(request, id: 3, on: conn).wait()) { error in
            XCTAssertEqual(error as? CustomError, CustomError.notFoundTodo)
        }
    }
    
    func testDeleteTodo() throws {
        prepareTodos(on: conn)
        
        let todos = try todoService.deleteTodo(id: 1, on: conn).wait()
        XCTAssertEqual(1, todos.count)
        
        XCTAssertThrowsError(try todoService.retrieveTodo(id: 1, on: conn).wait() ) { error in
            XCTAssertEqual(error as? CustomError, CustomError.notFoundTodo)
        }
    }
    
    func testDeleteTodo_idが不正な場合例外を投げること() throws {
        prepareTodos(on: conn)
        
        XCTAssertThrowsError(try todoService.deleteTodo(id: 3, on: conn).wait()) { error in
            XCTAssertEqual(error as? CustomError, CustomError.notFoundTodo)
        }
    }

    override func tearDown() {
        super.tearDown()
        conn.close()
    }
}

extension TodoServiceTests: TodoPreparable {}

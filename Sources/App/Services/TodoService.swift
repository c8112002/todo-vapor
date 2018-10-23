//
//  TodoService.swift
//  App
//
//  Created by Masahiko Sato on 2018/09/27.
//

import Foundation
import Vapor

protocol TodoServiceType {
    func retrieveAllTodos(on conn: DatabaseConnectable) -> Future<[Todo]>
    func retrieveTodo(id: Int, on conn: DatabaseConnectable) throws -> Future<Todo>
}


final class TodoService {}

extension TodoService: TodoServiceType {
    func retrieveAllTodos(on conn: DatabaseConnectable) -> Future<[Todo]> {
        return Todo.query(on: conn).sort(\.id, .ascending).all()
    }
    
    func retrieveTodo(id: Int, on conn: DatabaseConnectable) throws -> EventLoopFuture<Todo> {
        let todo = Todo.find(id, on: conn).map(to: Todo.self) { todo in
            guard let t = todo else {
                throw CustomError.notFoundTodo
            }
            return t
        }

        return todo
    }
}

extension TodoService: ServiceType {
    static var serviceSupports: [Any.Type] {
        return [TodoServiceType.self]
    }
    static func makeService(for worker: Container) throws -> TodoService {
        return TodoService()
    }
}

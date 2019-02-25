//
//  SqlDatabase.swift
//  Audio Tech Spike
//
//  Created by Buddy Reno on 2/25/19.
//  Copyright © 2019 Buddy Reno. All rights reserved.
//

import Foundation
import SQLite3

enum SqliteError: Error {
    case OpenDatabase(message: String)
    case Prepare(message: String)
    case Step(message: String)
    case Bind(message: String)
}

protocol SQLTable {
    static var createStatement: String { get }
    static var deleteStatement: String { get }
}

class SQLiteDatabase {
    fileprivate let dbPointer: OpaquePointer?
    
    fileprivate init(dbPointer: OpaquePointer?) {
        self.dbPointer = dbPointer
    }
    
    var errorMessage: String {
        if let errorPointer = sqlite3_errmsg(dbPointer) {
            let errorMessage = String(cString: errorPointer)
            return errorMessage
        } else {
            return "No error message provided from sqlite."
        }
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
    
    static func open(path: String) throws -> SQLiteDatabase {
        var db: OpaquePointer? = nil
        
        if sqlite3_open(path, &db) == SQLITE_OK {
            return SQLiteDatabase(dbPointer: db)
        } else {
            defer {
                if db != nil {
                    sqlite3_close(db)
                }
            }
            
            if let errorPointer = sqlite3_errmsg(db) {
                let message = String.init(cString: errorPointer)
                throw SqliteError.OpenDatabase(message: message)
            } else {
                throw SqliteError.OpenDatabase(message: "No error message provided from sqlite.")
            }
        }
    }
}

extension SQLiteDatabase {
    func prepareStatement(sql: String) throws -> OpaquePointer? {
        var statement: OpaquePointer? = nil
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SqliteError.Prepare(message: errorMessage)
        }
        
        return statement;
    }
    
    static func createDB() -> URL {
        do {
            let fileUrl = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent("tdrsAppDatabase.sqlite")
            return fileUrl
        } catch let error as Error {
            print("Problem creating db file: \(error)")
        }
    }
    
    func createTable(table: SQLTable.Type) throws {
        // 1
        let createTableStatement = try prepareStatement(sql: table.createStatement)
        // 2
        defer {
            sqlite3_finalize(createTableStatement)
        }
        // 3
        guard sqlite3_step(createTableStatement) == SQLITE_DONE else {
            throw SqliteError.Step(message: errorMessage)
        }
        print("\(table) table created.")
    }
    
    func dropTable(table: SQLTable.Type) throws {
        let deleteTableStatement = try prepareStatement(sql: table.deleteStatement)
        
        defer {
            sqlite3_finalize(deleteTableStatement)
        }
        
        guard sqlite3_step(deleteTableStatement) == SQLITE_DONE
            else {
                throw SqliteError.Step(message: errorMessage)
        }
        print("\(table) table deleted.")
    }
    
    func insertEpisode(episode: Episode) throws {
        let insertSql = "INSERT INTO Episode (id, hourNumber, title, audioUrl, duration, progress) VALUES (?, ?, ?, ?, ?, ?);"
        let insertStatement = try prepareStatement(sql: insertSql)
        defer {
            sqlite3_finalize(insertStatement)
        }
        
        guard sqlite3_bind_int(insertStatement, 1, episode.id) == SQLITE_OK  &&
            sqlite3_bind_int(insertStatement, 2, episode.hourNumber) == SQLITE_OK &&
        sqlite3_bind_text(insertStatement, 3, episode.title, -1, nil) == SQLITE_OK &&
        sqlite3_bind_text(insertStatement, 4, episode.audioUrl, -1, nil) == SQLITE_OK &&
        sqlite3_bind_int(insertStatement, 5, episode.duration) == SQLITE_OK &&
        sqlite3_bind_double(insertStatement, 6, Double(episode.progress)) == SQLITE_OK else {
                throw SqliteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(insertStatement) == SQLITE_DONE else {
            throw SqliteError.Step(message: errorMessage)
        }
        
        print("Successfully inserted row.")
    }
    
    func updateEpisode(episode: Episode) throws {
        let updateSql = "UPDATE Episode set id = ?, hourNumber = ?, title = ?, audioUrl = ?, duration = ?, progress = ? WHERE id = ?"
        
        let updateStatement = try prepareStatement(sql: updateSql)
        
        defer {
            sqlite3_finalize(updateStatement)
        }
        
        guard sqlite3_bind_int(updateStatement, 1, episode.id) == SQLITE_OK  &&
            sqlite3_bind_int(updateStatement, 2, episode.hourNumber) == SQLITE_OK &&
            sqlite3_bind_text(updateStatement, 3, episode.title, -1, nil) == SQLITE_OK &&
            sqlite3_bind_text(updateStatement, 4, episode.audioUrl, -1, nil) == SQLITE_OK &&
            sqlite3_bind_int(updateStatement, 5, episode.duration) == SQLITE_OK &&
            sqlite3_bind_int(updateStatement, 6, episode.progress) == SQLITE_OK &&
            sqlite3_bind_int(updateStatement, 7, episode.id) == SQLITE_OK else {
                throw SqliteError.Bind(message: errorMessage)
        }
        
        guard sqlite3_step(updateStatement) == SQLITE_DONE else {
            throw SqliteError.Step(message: errorMessage)
        }
        
        print("Successfully updated row.")
    }
    
    func episode(id: Int32) -> Episode? {
        let querySql = "SELECT * FROM Episode WHERE id = ?;"
        guard let queryStatement = try? prepareStatement(sql: querySql) else {
            return nil
        }
        
        defer {
            sqlite3_finalize(queryStatement)
        }
        
        guard sqlite3_bind_int(queryStatement, 1, id) == SQLITE_OK else {
            return nil
        }
        
        guard sqlite3_step(queryStatement) == SQLITE_ROW else {
            return nil
        }
        
        let id = sqlite3_column_int(queryStatement, 0)
        let hourNumber = sqlite3_column_int(queryStatement, 1)
        let title = String(cString: sqlite3_column_text(queryStatement, 2))
        let audioUrl = String(cString: sqlite3_column_text(queryStatement, 3))
        let duration = sqlite3_column_int(queryStatement, 4)
        let progress = sqlite3_column_int(queryStatement, 5)
        
//        let queryResultCol1 = sqlite3_column_text(queryStatement, 1)
//        let name = String(cString: queryResultCol1!) as NSString
        
        return Episode(id: id, hourNumber: hourNumber, title: title, audioUrl: audioUrl, duration: duration, progress: progress)
    }
}

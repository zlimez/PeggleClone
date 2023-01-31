//
//  DataManager.swift
//  Peggle
//
//  Created by James Chiu on 31/1/23.
//

import Foundation

final class DataManager {
    private static func load<T: Decodable>(_ filename: String) -> T {
        let data: Data

        guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
            fatalError("Couldn't find \(filename) in main bundle.")
        }

        do {
            data = try Data(contentsOf: file)
        } catch {
            fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
        }

        do {
            let decoder = JSONDecoder()
            return try decoder.decode(T.self, from: data)
        } catch {
            fatalError("Couldn't parse \(filename) as \(T.self):\n\(error)")
        }
    }
    
    static func createDataFile(_ filename: String) {
        let filePath = "\(NSHomeDirectory())/\(filename)"
        FileManager.default.createFile(atPath: filePath, contents: nil)
    }
    
    static func writeTo<T: Encodable>(_ filename: String, object: T) throws {
        let encoder = JSONEncoder()
        let folderURL = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        
        let fileURL = folderURL.appendingPathComponent(filename)
        let data = try encoder.encode(object)
        try data.write(to: fileURL)
    }
    
    static func loadLevels() -> [String: Board] {
        let filePath = "\(NSHomeDirectory())/levels.json"
        if !FileManager.default.fileExists(atPath: filePath) {
            return [:]
        }
        return DataManager.load("levels.json")
    }
    
    static func storeLevels(_ levels: [String: Board]) throws {
        try DataManager.writeTo("levels.json", object: levels)
    }
}

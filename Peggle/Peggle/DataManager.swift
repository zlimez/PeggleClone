//
//  DataManager.swift
//  Peggle
//
//  Created by James Chiu on 31/1/23.
//

import Foundation

final class DataManager {
    private static func fileURL(_ filename: String) throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
           .appendingPathComponent(filename)
    }

    static func load<T: Decodable>(filename: String, initValue: T, completion: @escaping (Result<T, Error>) -> Void) {
          DispatchQueue.global(qos: .background).async {
              do {
                  let fileURL = try fileURL(filename)
                  guard let file = try? FileHandle(forReadingFrom: fileURL) else {
                      DispatchQueue.main.async {
                          completion(.success(initValue))
                      }
                      return
                  }
                  let values = try JSONDecoder().decode(T.self, from: file.availableData)
                  DispatchQueue.main.async {
                      completion(.success(values))
                  }
              } catch {
                  DispatchQueue.main.async {
                      completion(.failure(error))
                  }
              }
          }
      }

    static func save<T: Encodable>(values: T, filename: String, completion: @escaping (Result<Bool, Error>) -> Void) {
       DispatchQueue.global(qos: .background).async {
           do {
               let data = try JSONEncoder().encode(values)
               let outfile = try fileURL(filename)
               try data.write(to: outfile)
               DispatchQueue.main.async {
                   completion(.success(true))
               }
           } catch {
               DispatchQueue.main.async {
                   completion(.failure(error))
               }
           }
       }
   }
}

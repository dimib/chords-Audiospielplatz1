//
//  FileStorage.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation

/// A simple file storage functionality that can be used to read or write f
final class JSONFileStorage<Storage: Storable> {
    let fileUrl: URL
    
    init(url: URL) {
        self.fileUrl = url
    }
    
    init(path: String) {
        self.fileUrl = URL(fileURLWithPath: path)
    }
    
    func load() throws -> Storage {
        do {
            let data = try Data(contentsOf: fileUrl)
            return try JSONDecoder().decode(Storage.self, from: data)
        } catch {
            print("☠️ error loading from \(fileUrl.absoluteString): \(error.localizedDescription)")
            throw error
        }
    }
    
    func save(storage: Storage) throws {
        do {
            let data = try JSONEncoder().encode(storage)
            try data.write(to: fileUrl)
        } catch {
            print("☠️ error writing to \(fileUrl.absoluteString): \(error.localizedDescription)")
            throw error
        }
    }
}

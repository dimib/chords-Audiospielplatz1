//
//  ResourceStorageLoader.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import Foundation

final class ResourceStorageLoader<Storage: Storable> {
    let resourceName: String
    
    init(name: String) {
        resourceName = name
    }
    
    func load() throws -> Storage {
        guard let url = Bundle.main.url(forResource: resourceName, withExtension: Storage.resourceExtension) else {
            throw AppError.illegalUrl
        }
        
        do {
            let data = try Data(contentsOf: url)
            let storable = try JSONDecoder().decode(Storage.self, from: data)
            return storable
        } catch {
            print("☠️ could not load resource \(url), error=\(error.localizedDescription)")
            throw error
        }
    }
}

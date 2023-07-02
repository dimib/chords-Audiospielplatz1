//
//  FileListView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 02.07.23.
//

import SwiftUI

struct FileListView: View {
    
    let files: [String]
    var body: some View {
        VStack {
            List {
                ForEach(files, id: \.self) { file in
                    HStack {
                        Text(file)
                            .font(.headline)
                        Spacer()
                    }
                }
            }
        }
    }
}

struct FileListView_Previews: PreviewProvider {
    static let files: [String] = [
        "c_maj/cmaj_00001.wav",
        "c_maj/cmaj_00002.wav",
        "c_maj/cmaj_00003.wav",
        "c_maj/cmaj_00004.wav",
        "d_maj/dmaj_00001.wav",
        "d_maj/dmaj_00002.wav",
        "d_maj/dmaj_00003.wav",
        "d_maj/dmaj_00004.wav"
    ]

    static var previews: some View {
        FileListView(files: files)
    }
}
/*
struct FileListView_Previews: PreviewProvider {
    
    static let files: [String] = [
        "c_maj/cmaj_00001.wav",
        "c_maj/cmaj_00002.wav",
        "c_maj/cmaj_00003.wav",
        "c_maj/cmaj_00004.wav",
        "d_maj/dmaj_00001.wav",
        "d_maj/dmaj_00002.wav",
        "d_maj/dmaj_00003.wav",
        "d_maj/dmaj_00004.wav"
    ]
    
    static var previews: some View {
        FileListView(files: Self.files)
    }
}
*/

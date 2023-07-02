//
//  AudioFileSplitterView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 28.06.23.
//

import SwiftUI

struct AudioFileSplitterView: View {
    
    @StateObject var viewModel = AudioSplitterViewModel()
    
    var body: some View {
        VStack {
            VStack(alignment: .leading, spacing: 1) {
                HStack {
                    Button(action: {
                        chooseSessionDirectory()
                    }, label: {
                        Image(systemName: "folder")
                            .imageScale(.large)
                    })
                    .buttonStyle(.plain)
                    .frame(width: 40, height: 40)
                    
                    Text("\(viewModel.sessionDirectory)")
                        .font(.headline)
                    Spacer()
                }
                
                HStack {
                    Button(action: {
                        chooseOutputDirectory()
                    }, label: {
                        Image(systemName: "square.and.arrow.down.on.square")
                            .imageScale(.large)
                    })
                    .buttonStyle(.plain)
                    .frame(width: 40, height: 40)
                    
                    Text("\(viewModel.outputDirectory)")
                        .font(.headline)
                    Spacer()
                }
            }
            .border(Color.gray)
            .padding(.horizontal, 10)
            .padding(.top, 10)
            
            VStack {
                FileListView(files: viewModel.inputFiles)
                ProgressView(value: viewModel.splitProgress)
            }
            .padding(10)
            
            HStack {
                Button(action: {
                    viewModel.splitAudioFiles()
                }, label: {
                    Text("Split")
                })
                Spacer()
            }
            .padding(10)
            
            Spacer()
        }
        .frame(minWidth: 400, minHeight: 300)
    }
        
    private func chooseSessionDirectory() {
        RecordingSessionHelper.chooseDirectory { path in
            viewModel.setSessionDirectory(path)
        }
    }
    
    private func chooseOutputDirectory() {
        RecordingSessionHelper.chooseDirectory { path in
            viewModel.setOutputDirectory(path)
        }
    }
}

struct AudioFileSplitterView_Previews: PreviewProvider {
    static var previews: some View {
        AudioFileSplitterView()
    }
}

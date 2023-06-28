//
//  VolumeSettingsView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import SwiftUI

struct VolumeSettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @StateObject var viewModel = VolumeSettingsViewModel()

    var body: some View {
        VStack {
            Grid(alignment: .leading) {
                GridRow(alignment: .lastTextBaseline) {
                    Text("Start at")
                    VStack(alignment: .trailing) {
                        Text("\(viewModel.startVolume)")
                        Slider(value: $viewModel.startVolume, in: 0.0...8.00)
                    }
                }
                GridRow(alignment: .lastTextBaseline) {
                    Text("End at")
                    VStack(alignment: .trailing) {
                        Text("\(viewModel.endVolume)")
                        Slider(value: $viewModel.endVolume, in: 0.0...8.00)
                    }
                }
            }
            Spacer()
            HStack {
                Button(action: {
                    viewModel.save()
                    dismiss()
                }, label: {
                    Text("Save")
                })

                Button(action: {
                    dismiss()
                }, label: {
                    Text("Cancel")
                })
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 24)
        .padding(.bottom, 12)
    }
}

struct VolumeSettingsView_Previews: PreviewProvider {
    static var previews: some View {
        VolumeSettingsView()
            .frame(width: 300, height: 100)
    }
}

//
//  VolumeSettingsView.swift
//  AudioSpielplatz1
//
//  Created by Dimitri Brukakis on 25.06.23.
//

import SwiftUI

struct VolumeSettingsView: View {
    
    @Environment(\.dismiss) var dismiss
    
    @State var startVolume: Double = 0
    @State var endVolume: Double = 0

    var body: some View {
        VStack {
            Grid(alignment: .leading) {
                GridRow(alignment: .lastTextBaseline) {
                    Text("Start at")
                    VStack(alignment: .trailing) {
                        Text("\(startVolume)")
                        Slider(value: $startVolume, in: 0.0...8.00)
                    }
                }
                GridRow(alignment: .lastTextBaseline) {
                    Text("End at")
                    VStack(alignment: .trailing) {
                        Text("\(endVolume)")
                        Slider(value: $endVolume, in: 0.0...8.00)
                    }
                }
            }
            Spacer()
            HStack {
                Button(action: {
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

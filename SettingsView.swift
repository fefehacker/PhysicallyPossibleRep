import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isFeature1Enabled = false
    @State private var isFeature2Enabled = false
    @State private var isFeature3Enabled = false

    var body: some View {
        NavigationView {
            Form {
                Toggle("Enable Feature 1", isOn: $isFeature1Enabled)
                Toggle("Enable Feature 2", isOn: $isFeature2Enabled)
                Toggle("Enable Feature 3", isOn: $isFeature3Enabled)
            }
            .navigationTitle("Settings")
            .navigationBarItems(trailing: Button(action: {
                presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "xmark")
            })
        }
    }
}

import SwiftUI

struct SettingsSheetView: View {
    @Environment(\.dismiss) private var dismiss

    @Binding var revealMath: Bool
    @Binding var showRuneNumbers: Bool
    @Binding var soundEnabled: Bool

    var body: some View {
        NavigationStack {
            Form {
                Section("Learning View") {
                    Toggle("Reveal Mathematical Form", isOn: $revealMath)
                    Toggle("Show Rune Numbers", isOn: $showRuneNumbers)
                }

                Section("Experience") {
                    Toggle("Sound Effects", isOn: $soundEnabled)
                }

                Section("About") {
                    Text("Neural Spellbook is fully offline and built to make neural networks understandable as a glass box.")
                        .font(Typography.body)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}

import SwiftUI

struct HelpAboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    GlassCard {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Neural Spellbook: The Living Network")
                                .font(Typography.title)
                            Text("A 3-4 minute guided story plus a sandbox that teaches neural networks as a transparent system.")
                                .font(Typography.body)
                        }
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("How to Learn Fast", systemImage: "book")
                                .font(Typography.section)
                            Text("1. Run Guided Journey once for the narrative arc.")
                            Text("2. Enter Free Play and break things on purpose.")
                            Text("3. Use Diagnostics cards to recover with one tap.")
                        }
                        .font(Typography.body)
                    }

                    GlassCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Label("Honesty Note", systemImage: "checkmark.seal")
                                .font(Typography.section)
                            Text("Rune meanings are intuition aids, not strict proofs. They help beginners build mental models.")
                                .font(Typography.body)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
                .padding(20)
            }
            .navigationTitle("Help & About")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
}

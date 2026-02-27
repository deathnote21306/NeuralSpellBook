import SwiftUI

struct DiagnosticsPanelView: View {
    @ObservedObject var diagnosticsViewModel: DiagnosticsViewModel
    @ObservedObject var sandboxViewModel: SandboxViewModel

    var body: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Label("Diagnostics", systemImage: "stethoscope")
                        .font(Typography.section)
                    Spacer()
                    Button("Refresh") {
                        diagnosticsViewModel.refresh(using: sandboxViewModel)
                    }
                    .font(Typography.caption)
                    .buttonStyle(.bordered)
                }

                if diagnosticsViewModel.issues.isEmpty {
                    Text("No major issues detected right now.")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(diagnosticsViewModel.issues) { issue in
                        VStack(alignment: .leading, spacing: 6) {
                            HStack {
                                Image(systemName: issue.icon)
                                Text(issue.title)
                                    .font(Typography.body)
                                    .fontWeight(.semibold)
                            }
                            .foregroundStyle(colorForSeverity(issue.severity))

                            Text(issue.explanation)
                                .font(Typography.caption)
                                .foregroundStyle(.secondary)

                            Button(issue.fixTitle) {
                                diagnosticsViewModel.applyFix(issue, to: sandboxViewModel)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(Theme.starlight)
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
        }
        .onAppear {
            diagnosticsViewModel.refresh(using: sandboxViewModel)
        }
        .onChange(of: sandboxViewModel.currentStep) {
            diagnosticsViewModel.refresh(using: sandboxViewModel)
        }
        .onChange(of: sandboxViewModel.learningRate) {
            diagnosticsViewModel.refresh(using: sandboxViewModel)
        }
        .onChange(of: sandboxViewModel.batchSize) {
            diagnosticsViewModel.refresh(using: sandboxViewModel)
        }
        .onChange(of: sandboxViewModel.dropout) {
            diagnosticsViewModel.refresh(using: sandboxViewModel)
        }
        .onChange(of: sandboxViewModel.normalizeData) {
            diagnosticsViewModel.refresh(using: sandboxViewModel)
        }
        .onChange(of: sandboxViewModel.outputMode) {
            diagnosticsViewModel.refresh(using: sandboxViewModel)
        }
    }

    private func colorForSeverity(_ severity: DiagnosticsSeverity) -> Color {
        switch severity {
        case .high:
            return Theme.danger
        case .medium:
            return Theme.warning
        case .low:
            return Theme.mint
        }
    }
}

import SwiftUI

struct SandboxView: View {
    @ObservedObject var viewModel: SandboxViewModel
    @ObservedObject var diagnosticsViewModel: DiagnosticsViewModel

    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showSettings = false
    @State private var refreshDebouncer = Debouncer(milliseconds: 160)

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ParticlesBackground(density: 100, speed: 0.24)

            SplitLabLayout(
                wideBreakpoint: 980,
                leftRatio: 0.34,
                topBar: { topBar },
                leftPanel: { controlsColumn },
                rightStage: { stageColumn },
                bottomBar: { bottomBar }
            )

            if let toast = currentToast {
                VStack {
                    Spacer()
                    FeedbackToast(text: toast)
                        .padding(.bottom, 24)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
                .onAppear {
                    let fromDiagnostics = diagnosticsViewModel.toastText != nil
                    Task {
                        try? await Task.sleep(for: .seconds(2.1))
                        if fromDiagnostics {
                            diagnosticsViewModel.toastText = nil
                        } else {
                            viewModel.uiToastMessage = nil
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView(
                revealMath: $viewModel.revealMathematicalForm,
                showRuneNumbers: $viewModel.showRuneNumbers,
                soundEnabled: $viewModel.soundEnabled
            )
        }
        .sheet(isPresented: $viewModel.showRuneInspector) {
            if let rune = viewModel.selectedRune {
                RuneInspectorView(rune: rune) {
                    viewModel.pinSelectedRune()
                }
            }
        }
        .sheet(isPresented: $viewModel.showTensorInspector) {
            if let tensor = viewModel.selectedTensor {
                TensorInspectorView(tensor: tensor)
            }
        }
        .onAppear {
            diagnosticsViewModel.refresh(using: viewModel)
        }
        .onChange(of: viewModel.boundaryResolution) {
            refreshDebouncer.schedule {
                viewModel.refreshVisuals()
            }
        }
    }

    private var currentToast: String? {
        diagnosticsViewModel.toastText ?? viewModel.uiToastMessage
    }

    private var topBar: some View {
        GlassCard {
            HStack(alignment: .top, spacing: 12) {
                Button {
                    appState.goHome()
                } label: {
                    Label("Home", systemImage: "house")
                }
                .buttonStyle(.bordered)

                VStack(alignment: .leading, spacing: 5) {
                    Text("Free Play Sandbox")
                        .font(Typography.title)
                    Text("Glyphs -> Forward -> Instability -> Backprop -> Update")
                        .font(Typography.caption)
                        .foregroundStyle(.white.opacity(0.75))
                    Label(freePlayHint, systemImage: "arrow.right.circle")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.mint)
                }

                Spacer()

                ToggleChip(title: "Math Form", isOn: $viewModel.revealMathematicalForm)
                ToggleChip(title: "Sound", isOn: $viewModel.soundEnabled)

                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "slider.horizontal.3")
                }
                .buttonStyle(.bordered)
            }
        }
    }

    private var controlsColumn: some View {
        VStack(spacing: 12) {
            NextActionCard(
                instruction: freePlayHint,
                buttonTitle: freePlayPrimaryActionTitle,
                systemImage: freePlayPrimaryActionIcon,
                whyText: freePlayWhy,
                disabledReason: freePlayDisabledReason
            ) {
                freePlayPrimaryAction()
            }

            DatasetBuilderView(viewModel: viewModel)
            ModelBuilderView(viewModel: viewModel)
            TrainingView(viewModel: viewModel)
            tensorList
            DiagnosticsPanelView(diagnosticsViewModel: diagnosticsViewModel, sandboxViewModel: viewModel)
        }
    }

    private var stageColumn: some View {
        VStack(spacing: 12) {
            StatusChipsRow(chips: stageStatusChips)
            LivingStageView(viewModel: viewModel, reducedMotion: reduceMotion)
        }
    }

    private var stageStatusChips: [StatusChip] {
        var chips: [StatusChip] = []
        chips.append(
            StatusChip(
                title: viewModel.isPlaying ? "Ritual running" : "Ritual paused",
                systemImage: viewModel.isPlaying ? "play.fill" : "pause.fill",
                tint: viewModel.isPlaying ? Theme.starlight : Theme.warning
            )
        )
        chips.append(
            StatusChip(
                title: viewModel.dataset.normalized ? "Glyphs normalized" : "Glyphs unnormalized",
                systemImage: "arrow.up.and.down",
                tint: viewModel.dataset.normalized ? Theme.mint : Theme.warning
            )
        )
        if viewModel.instabilityLevel > 0.65 {
            chips.append(StatusChip(title: "Chaos detected", systemImage: "bolt.trianglebadge.exclamationmark", tint: Theme.danger))
        }
        if viewModel.showRuneInspector {
            chips.append(StatusChip(title: "Inspect mode", systemImage: "magnifyingglass", tint: Theme.gold))
        }
        return chips
    }

    private var tensorList: some View {
        GlassCard {
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(
                    title: "Tensor Snapshots",
                    subtitle: "What just happened internally?",
                    systemImage: "scope"
                )

                if viewModel.tensorSummaries.isEmpty {
                    Text("Run one training step, then inspect tensors.")
                        .font(Typography.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(viewModel.tensorSummaries) { tensor in
                        Button {
                            viewModel.selectedTensor = tensor
                            viewModel.showTensorInspector = true
                        } label: {
                            HStack {
                                Text(tensor.name)
                                    .font(Typography.body)
                                Spacer()
                                Text(tensor.shape.map(String.init).joined(separator: "×"))
                                    .font(Typography.mono)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .buttonStyle(.plain)
                        .padding(.vertical, 3)
                        .frame(minHeight: 44)
                    }
                }
            }
        }
    }

    private var bottomBar: some View {
        GlassCard {
            HStack(spacing: 10) {
                PrimaryButton(title: viewModel.isPlaying ? "Pause" : "Play", systemImage: viewModel.isPlaying ? "pause.fill" : "play.fill") {
                    viewModel.togglePlayPause()
                }
                .frame(maxWidth: 170)

                PrimaryButton(title: "Step", systemImage: "forward.frame.fill", prominent: false) {
                    viewModel.stepTraining()
                }
                .frame(maxWidth: 150)

                LabeledSliderRow(
                    title: "Speed",
                    helper: "Training playback speed",
                    value: $viewModel.speed,
                    range: 0.05...1,
                    step: 0.01,
                    format: "%.2f"
                )
                .frame(maxWidth: 270)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Step \(viewModel.currentStep)")
                        .font(Typography.caption)
                    Text("Loss \(String(format: "%.3f", viewModel.lossHistory.last?.loss ?? 0))")
                        .font(Typography.mono)
                        .foregroundStyle(.white.opacity(0.86))
                }

                PrimaryButton(title: "Reset", systemImage: "arrow.counterclockwise", prominent: false) {
                    viewModel.resetEverything()
                }
                .frame(maxWidth: 170)
            }
        }
    }

    private var freePlayHint: String {
        if viewModel.currentStep == 0 {
            return "Cast one step to reveal prediction + instability."
        }
        if viewModel.isPlaying {
            return "Watch the barrier evolve, then pause to inspect runes."
        }
        if viewModel.instabilityLevel > 0.65 {
            return "Mana is chaotic. Lower mana flow."
        }
        return "Change one control, cast one step, compare."
    }

    private var freePlayWhy: String {
        "Beginners learn fastest with one change at a time: change one setting, run one step, inspect what changed, and repeat."
    }

    private var freePlayPrimaryActionTitle: String {
        if viewModel.currentStep == 0 { return "Run One Step" }
        return viewModel.isPlaying ? "Pause Training" : "Resume Training"
    }

    private var freePlayPrimaryActionIcon: String {
        if viewModel.currentStep == 0 { return "forward.frame.fill" }
        return viewModel.isPlaying ? "pause.fill" : "play.fill"
    }

    private var freePlayDisabledReason: String? {
        if viewModel.currentStep == 0, viewModel.isPlaying {
            return "Pause first, then step once for a clear before/after view."
        }
        return nil
    }

    private func freePlayPrimaryAction() {
        if viewModel.currentStep == 0 {
            viewModel.stepTraining()
            return
        }
        viewModel.togglePlayPause()
    }
}

import SwiftUI

struct GuidedJourneyView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel
    @ObservedObject var diagnosticsViewModel: DiagnosticsViewModel

    @EnvironmentObject private var appState: AppState
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    @State private var showSettings = false
    @State private var guidedModeEnabled = true

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ParticlesBackground(density: 120, speed: 0.2)

            if viewModel.chapter == .awakening {
                ChapterAwakeningView(viewModel: viewModel)
            } else {
                journeyLayout
            }

            if viewModel.showLossExplanationOverlay {
                lossOverlay
            }

            if let toast = currentToast {
                VStack {
                    Spacer()
                    FeedbackToast(text: toast)
                        .padding(.bottom, 24)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .onAppear {
                    let fromJourney = viewModel.toastMessage != nil
                    Task {
                        try? await Task.sleep(for: .seconds(2))
                        if fromJourney {
                            viewModel.toastMessage = nil
                        } else {
                            viewModel.sandbox.uiToastMessage = nil
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showSettings) {
            SettingsSheetView(
                revealMath: $viewModel.sandbox.revealMathematicalForm,
                showRuneNumbers: $viewModel.sandbox.showRuneNumbers,
                soundEnabled: $viewModel.sandbox.soundEnabled
            )
        }
        .sheet(isPresented: $viewModel.sandbox.showRuneInspector) {
            if let rune = viewModel.sandbox.selectedRune {
                RuneInspectorView(rune: rune) {
                    viewModel.sandbox.pinSelectedRune()
                }
            }
        }
        .onAppear {
            guidedModeEnabled = true
            diagnosticsViewModel.refresh(using: viewModel.sandbox)
        }
    }

    private var currentToast: String? {
        viewModel.toastMessage ?? viewModel.sandbox.uiToastMessage
    }

    private var journeyLayout: some View {
        SplitLabLayout(
            wideBreakpoint: 980,
            leftRatio: 0.34,
            topBar: { topBar },
            leftPanel: { leftPanel },
            rightStage: { rightStage },
            bottomBar: { bottomBar }
        )
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

                PathHeaderCard(
                    title: viewModel.chapter.title,
                    goal: viewModel.chapterGoalLine,
                    progressText: "\(viewModel.chapter.rawValue)/6",
                    progressValue: viewModel.chapterProgressValue,
                    hint: viewModel.whatToDoNowHint
                )
                .frame(maxWidth: .infinity, alignment: .leading)

                VStack(alignment: .trailing, spacing: 8) {
                    ToggleChip(title: "Guided Mode", isOn: Binding(
                        get: { guidedModeEnabled },
                        set: { newValue in
                            guidedModeEnabled = newValue
                            if !newValue {
                                appState.enterFreePlay()
                            }
                        }
                    ))

                    HStack(spacing: 6) {
                        ToggleChip(title: "Sound", isOn: $viewModel.sandbox.soundEnabled)
                        ToggleChip(title: "Reveal Math", isOn: $viewModel.sandbox.revealMathematicalForm)
                    }

                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
    }

    private var leftPanel: some View {
        VStack(spacing: 12) {
            JourneyBreadcrumbView(currentChapter: viewModel.chapter)

            switch viewModel.chapter {
            case .awakening:
                EmptyView()
            case .firstSpell:
                ChapterForwardView(viewModel: viewModel)
            case .instability:
                ChapterLossView(viewModel: viewModel)
            case .backprop:
                ChapterBackpropView(viewModel: viewModel)
            case .manaControls:
                ChapterManaControlsView(viewModel: viewModel)
            case .inspect:
                ChapterInspectView(viewModel: viewModel)
            case .evolution:
                ChapterFinaleView(
                    viewModel: viewModel,
                    onReplay: { appState.replayGuidedJourney() },
                    onEnterFreePlay: { appState.enterFreePlay() }
                )
            }
        }
    }

    private var rightStage: some View {
        VStack(spacing: 12) {
            LivingStageView(viewModel: viewModel.sandbox, reducedMotion: reduceMotion)

            StatusChipsRow(chips: guidedStatusChips)

            if let disabledReason = viewModel.nextActionDisabledReason {
                GlassCard {
                    Label(disabledReason, systemImage: "lock.fill")
                        .font(Typography.caption)
                        .foregroundStyle(Theme.warning)
                }
            }
        }
    }

    private var guidedStatusChips: [StatusChip] {
        var chips: [StatusChip] = []
        chips.append(
            StatusChip(
                title: viewModel.sandbox.isPlaying ? "Ritual running" : "Ritual paused",
                systemImage: viewModel.sandbox.isPlaying ? "play.fill" : "pause.fill",
                tint: viewModel.sandbox.isPlaying ? Theme.starlight : Theme.warning
            )
        )

        chips.append(
            StatusChip(
                title: viewModel.sandbox.dataset.normalized ? "Glyphs normalized" : "Glyphs unnormalized",
                systemImage: "arrow.up.and.down",
                tint: viewModel.sandbox.dataset.normalized ? Theme.mint : Theme.warning
            )
        )

        if viewModel.sandbox.instabilityLevel > 0.65 {
            chips.append(StatusChip(title: "Chaos detected", systemImage: "bolt.trianglebadge.exclamationmark", tint: Theme.danger))
        }

        if viewModel.sandbox.showRuneInspector {
            chips.append(StatusChip(title: "Inspect mode", systemImage: "magnifyingglass", tint: Theme.gold))
        }

        return chips
    }

    private var bottomBar: some View {
        GlassCard {
            HStack(spacing: 10) {
                PrimaryButton(
                    title: viewModel.sandbox.isPlaying ? "Pause" : "Play",
                    systemImage: viewModel.sandbox.isPlaying ? "pause.fill" : "play.fill"
                ) {
                    viewModel.sandbox.togglePlayPause()
                }
                .frame(maxWidth: 170)

                PrimaryButton(title: "Step", systemImage: "forward.frame.fill", prominent: false) {
                    viewModel.sandbox.stepTraining()
                }
                .frame(maxWidth: 140)

                LabeledSliderRow(
                    title: "Speed",
                    helper: "Training animation pace",
                    value: $viewModel.sandbox.speed,
                    range: 0.05...1,
                    step: 0.01,
                    format: "%.2f"
                )
                .frame(maxWidth: 270)

                Spacer(minLength: 8)

                VStack(alignment: .trailing, spacing: 4) {
                    Text("Step \(viewModel.sandbox.currentStep)")
                        .font(Typography.caption)
                    Text("Loss \(String(format: "%.3f", viewModel.sandbox.lossHistory.last?.loss ?? 0))")
                        .font(Typography.mono)
                        .foregroundStyle(.white.opacity(0.85))
                }

                PrimaryButton(title: "Reset", systemImage: "arrow.counterclockwise", prominent: false) {
                    viewModel.sandbox.resetEverything()
                    viewModel.resetJourney()
                    viewModel.performPrimaryAction()
                }
                .frame(maxWidth: 170)
            }
        }
    }

    private var lossOverlay: some View {
        Color.black.opacity(0.5)
            .ignoresSafeArea()
            .overlay {
                GlassCard {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Why this failed")
                            .font(Typography.title)
                        Text("Prediction and truth did not match.")
                            .font(Typography.caption)
                            .foregroundStyle(.white.opacity(0.9))
                        Text("Instability (loss) = how wrong the spell is.")
                            .font(Typography.body)
                            .foregroundStyle(Theme.warning)
                        PrimaryButton(title: "Continue", systemImage: "arrow.right") {
                            viewModel.continueAfterOverlay()
                        }
                    }
                    .frame(maxWidth: 440)
                }
            }
    }
}

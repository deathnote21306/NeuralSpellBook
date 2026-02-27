import SwiftUI

struct ChapterAwakeningView: View {
    @ObservedObject var viewModel: GuidedJourneyViewModel

    var body: some View {
        ZStack {
            Theme.background.ignoresSafeArea()
            ParticlesBackground(density: 140, speed: 0.12)

            VStack(spacing: 24) {
                Spacer()

                Text(viewModel.storyLine)
                    .font(Typography.title)
                    .foregroundStyle(.white.opacity(0.92))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(LinearGradient(colors: [Color(red: 0.20, green: 0.13, blue: 0.09), Color(red: 0.12, green: 0.08, blue: 0.08)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: viewModel.spellbookOpened ? 260 : 210, height: 150)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(Theme.gold.opacity(0.35), lineWidth: 2)
                        )
                        .scaleEffect(viewModel.spellbookOpened ? 1.06 : 1)
                        .animation(.spring(response: 0.45, dampingFraction: 0.78), value: viewModel.spellbookOpened)

                    Image(systemName: viewModel.spellbookOpened ? "book.pages.fill" : "book.closed.fill")
                        .font(.system(size: 52, weight: .medium))
                        .foregroundStyle(viewModel.spellbookOpened ? Theme.gold : .white.opacity(0.8))
                }
                .onTapGesture {
                    viewModel.openSpellbook()
                }

                if viewModel.spellbookOpened {
                    Button {
                        viewModel.performPrimaryAction()
                    } label: {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Theme.starlight.opacity(0.85), Theme.nebula], startPoint: .top, endPoint: .bottom))
                                .frame(width: 124, height: 124)
                                .shadow(color: Theme.starlight.opacity(0.7), radius: 24)
                            Text("Awaken")
                                .font(Typography.section)
                                .foregroundStyle(.white)
                        }
                    }
                    .buttonStyle(.plain)
                    .transition(.scale.combined(with: .opacity))
                }

                Spacer()
            }
        }
    }
}

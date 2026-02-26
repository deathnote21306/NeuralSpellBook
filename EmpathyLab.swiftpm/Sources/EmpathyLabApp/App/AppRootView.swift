import SwiftUI

struct AppRootView: View {
    enum Route: Hashable {
        case home
        case selection
        case lab
        case results
        case designFix
        case debrief
        case about
    }

    @State private var path = NavigationPath()
    @State private var isSafetySheetPresented = false

    var body: some View {
        NavigationStack(path: $path) {
            HomeView(
                onStartExperience: {
                    push(.selection)
                },
                onOpenAbout: {
                    push(.about)
                }
            )
            .navigationDestination(for: Route.self) { route in
                destination(for: route)
            }
            .sheet(isPresented: $isSafetySheetPresented) {
                SafetySheetView(
                    onStart: {
                        isSafetySheetPresented = false
                        push(.lab)
                    },
                    onCancel: {
                        isSafetySheetPresented = false
                    }
                )
            }
        }
    }

    @ViewBuilder
    private func destination(for route: Route) -> some View {
        switch route {
        case .home:
            HomeView(
                onStartExperience: {
                    push(.selection)
                },
                onOpenAbout: {
                    push(.about)
                }
            )
        case .selection:
            SelectionView(
                onContinueToSafety: {
                    isSafetySheetPresented = true
                },
                onBack: {
                    pop()
                }
            )
        case .lab:
            LabPayBillView(
                onFinishLab: {
                    push(.results)
                }
            )
        case .results:
            ResultsView(
                onTryFix: {
                    push(.designFix)
                },
                onBackHome: {
                    popToRoot()
                }
            )
        case .designFix:
            DesignFixPayBillView(
                onFinishFix: {
                    push(.debrief)
                }
            )
        case .debrief:
            DebriefView(
                onBackHome: {
                    popToRoot()
                }
            )
        case .about:
            AboutView(
                onBack: {
                    pop()
                }
            )
        }
    }

    private func push(_ route: Route) {
        path.append(route)
    }

    private func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    private func popToRoot() {
        path = NavigationPath()
    }
}

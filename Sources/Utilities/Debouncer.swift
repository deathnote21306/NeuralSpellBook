import Foundation

@MainActor
public final class Debouncer {
    private var task: Task<Void, Never>?
    private let delay: Duration

    public init(milliseconds: Int) {
        self.delay = .milliseconds(milliseconds)
    }

    public func schedule(_ action: @escaping @MainActor () -> Void) {
        task?.cancel()
        task = Task {
            try? await Task.sleep(for: delay)
            guard !Task.isCancelled else { return }
            action()
        }
    }

    public func cancel() {
        task?.cancel()
        task = nil
    }
}

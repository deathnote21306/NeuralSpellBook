import Foundation

public enum SpellSceneID: String, CaseIterable, Identifiable {
    case awakening = "awakening"
    case introForward = "intro-forward"
    case sceneForward = "scene-forward"
    case introLoss = "intro-loss"
    case sceneLoss = "scene-loss"
    case introBackprop = "intro-backprop"
    case sceneBackprop = "scene-backprop"
    case introHyper = "intro-hyper"
    case sceneHyper = "scene-hyper"
    case introInspect = "intro-inspect"
    case sceneInspect = "scene-inspect"
    case sceneFinale = "scene-finale"

    public var id: String { rawValue }

    public var displayTitle: String {
        switch self {
        case .awakening: return "The Awakening"
        case .introForward: return "Chapter I Intro"
        case .sceneForward: return "Forward Pass"
        case .introLoss: return "Chapter II Intro"
        case .sceneLoss: return "Loss"
        case .introBackprop: return "Chapter III Intro"
        case .sceneBackprop: return "Backprop"
        case .introHyper: return "Chapter IV Intro"
        case .sceneHyper: return "Hyperparameters"
        case .introInspect: return "Chapter V Intro"
        case .sceneInspect: return "Inspect"
        case .sceneFinale: return "Finale"
        }
    }
}

public struct SpellModalSection: Identifiable {
    public enum Kind {
        case text
        case formula
        case callout
    }

    public let id = UUID()
    public let kind: Kind
    public let title: String?
    public let body: String

    public init(kind: Kind, title: String? = nil, body: String) {
        self.kind = kind
        self.title = title
        self.body = body
    }
}

public enum SpellModalKey: String, Identifiable {
    case forward
    case loss
    case backprop
    case hyper

    public var id: String { rawValue }

    public var title: String {
        switch self {
        case .forward: return "The Forward Pass"
        case .loss: return "Loss — The Measure of Failure"
        case .backprop: return "Backpropagation"
        case .hyper: return "Hyperparameters"
        }
    }

    public var subtitle: String {
        switch self {
        case .forward: return "What Happens When A Network Thinks"
        case .loss: return "Why Getting It Wrong Is The First Step To Getting It Right"
        case .backprop: return "The Ritual of Guided Correction"
        case .hyper: return "The Three Powers That Govern Learning"
        }
    }

    public var sections: [SpellModalSection] {
        switch self {
        case .forward:
            return [
                .init(
                    kind: .text,
                    title: "What It Is",
                    body: "A neural network is made of layers of neurons, which this spellbook calls runes. The forward pass is information flowing from the input layer, through hidden layers, to an output. Each neuron multiplies its inputs by learned weights, sums them, and applies an activation function, a mathematical gate deciding how strongly to fire."
                ),
                .init(
                    kind: .text,
                    title: "Why It Matters",
                    body: "Without the forward pass there is no prediction. Every time the network sees a new example it runs a forward pass to produce an answer. The quality of this answer depends entirely on the learned weights, which is exactly why training and backpropagation exist."
                ),
                .init(
                    kind: .text,
                    title: "What You Are Seeing",
                    body: "Glowing nodes are neurons activating. The brighter the node, the higher its value, meaning it recognized something in the input. Light flowing forward represents data transforming through each layer and becoming more abstract with each step."
                ),
                .init(
                    kind: .callout,
                    body: "\"A network that never fails never learns. Cast the spell — and let it be wrong.\""
                )
            ]

        case .loss:
            return [
                .init(
                    kind: .text,
                    title: "Why 0.53 Is Bad",
                    body: "A loss of 0.53 does not mean 53% wrong. It means the squared distance between prediction and truth is 0.53. A loss of 0 means perfect prediction. A loss above 0.3 means the network is performing poorly. Here, 0.53 is roughly ten times worse than what we consider acceptable."
                ),
                .init(
                    kind: .text,
                    title: "Why We Square The Error",
                    body: "Squaring makes every value positive so errors in different directions do not cancel out, and it punishes large errors disproportionately. An error of 0.73 becomes 0.53 when squared, highlighting that it is a big problem rather than a small slip."
                ),
                .init(
                    kind: .formula,
                    body: "Loss = (Truth − Prediction)²\n= (1.00 − 0.27)²\n= (0.73)² = 0.53"
                ),
                .init(
                    kind: .text,
                    title: "What Good Looks Like",
                    body: "Loss below 0.05 means the network is predicting well. Below 0.01 is excellent. We started at 0.53, about fifty times worse than excellent. Loss gives training a precise target: shrink it, step by step, through backpropagation."
                ),
                .init(
                    kind: .callout,
                    body: "\"Loss is not defeat. It is information. Without it, the network has no direction to grow.\""
                )
            ]

        case .backprop:
            return [
                .init(
                    kind: .text,
                    title: "Why This Fixes The Loss",
                    body: "After computing loss we know how wrong we are, but not which weights caused it. Backpropagation uses the chain rule of calculus to trace the error backward through every layer, computing each weight's exact contribution to the mistake."
                ),
                .init(
                    kind: .text,
                    title: "What A Gradient Is",
                    body: "A gradient is a direction number. For each weight it tells us: if you increase this weight slightly, does the loss go up or down, and by how much? We then move each weight in the opposite direction of the gradient. This is gradient descent."
                ),
                .init(
                    kind: .formula,
                    body: "W_new = W_old − α × ∂Loss/∂W\n\nα = learning rate (how big the step)\n∂Loss/∂W = gradient (direction of blame)"
                ),
                .init(
                    kind: .text,
                    title: "Why Each Layer Fires Separately",
                    body: "Each layer receives its gradient from the layer ahead of it, so correction travels backward in sequence. Output runes receive blame first, then hidden runes, then input connections. That is why the animation moves right to left: the error cascades back through every thread."
                ),
                .init(
                    kind: .callout,
                    body: "\"Every weight carries a share of responsibility for the error. Backprop distributes the blame — fairly, mathematically.\""
                )
            ]

        case .hyper:
            return [
                .init(
                    kind: .text,
                    title: "Learning Rate",
                    body: "Learning rate controls how large each weight update is. Too high, above roughly 0.1, and the network overshoots every correction, causing loss to oscillate or explode. Too low, below roughly 0.001, and updates are so small the network barely moves."
                ),
                .init(
                    kind: .text,
                    title: "Batch Size",
                    body: "Instead of using all training data at once, we use random subsets called batches. Smaller batches create faster but noisier updates. Larger batches are slower but smoother. A value around 32 is a classic engineering sweet spot."
                ),
                .init(
                    kind: .text,
                    title: "Epochs",
                    body: "One epoch means the network has seen every training example once. More epochs means more chances to learn. But too many without safeguards causes overfitting, where the network memorizes training data and fails on anything new."
                ),
                .init(
                    kind: .callout,
                    body: "\"Hyperparameters are the most human part of AI. The math is automatic. Choosing how fast to learn and how much to see still requires wisdom.\""
                )
            ]
        }
    }
}

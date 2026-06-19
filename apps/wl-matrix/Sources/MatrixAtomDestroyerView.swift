import SwiftUI

public struct MatrixAtomDestroyerView: View {
    public init() {}

    public var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let t = timeline.date.timeIntervalSinceReferenceDate
                ZStack {
                    Color.wlBackground.ignoresSafeArea()
                    ForEach(0..<24, id: \.self) { i in
                        let angle = Double(i) * .pi * 2 / 24 + t * (0.4 + Double(i % 5) * 0.07)
                        let radius = 80 + CGFloat((i % 7) * 18)
                        let x = proxy.size.width / 2 + cos(angle) * radius
                        let y = proxy.size.height / 2 + sin(angle * 1.31) * radius

                        Circle()
                            .fill(i % 3 == 0 ? Color.wlCyan : i % 3 == 1 ? Color.wlPurple : Color.wlGreen)
                            .frame(width: 6 + CGFloat(i % 4) * 2, height: 6 + CGFloat(i % 4) * 2)
                            .position(x: x, y: y)
                            .shadow(color: .wlCyan.opacity(0.7), radius: 10)
                    }
                }
            }
        }
    }
}

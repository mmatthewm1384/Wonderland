import SwiftUI

public struct FluderationView: View {
    public init() {}

    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.wlBackground))

                for i in 0..<36 {
                    let fx = CGFloat(i % 6) / 5
                    let fy = CGFloat(i / 6) / 5
                    let swirl = CGFloat(sin(t * 0.9 + Double(i) * 0.61))
                    let rect = CGRect(
                        x: fx * size.width + swirl * 18 - 20,
                        y: fy * size.height + CGFloat(cos(t + Double(i))) * 18 - 20,
                        width: 40 + abs(swirl) * 42,
                        height: 40 + abs(swirl) * 42
                    )
                    let color: Color = i % 3 == 0 ? .wlCyan : i % 3 == 1 ? .wlPurple : .wlGreen
                    context.stroke(Path(ellipseIn: rect), with: .color(color.opacity(0.36)), lineWidth: 2)
                }
            }
            .ignoresSafeArea()
        }
    }
}

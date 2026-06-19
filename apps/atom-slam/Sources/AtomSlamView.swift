import SwiftUI

public struct AtomSlamView: View {
    public init() {}

    public var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let t = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                let slam = abs(sin(t * 2.4))
                ZStack {
                    Color.wlBackground.ignoresSafeArea()

                    Circle()
                        .stroke(Color.wlPurple.opacity(0.8), lineWidth: 4)
                        .frame(width: 80 + slam * 260, height: 80 + slam * 260)
                        .position(x: proxy.size.width / 2, y: proxy.size.height / 2)
                        .shadow(color: .wlPurple, radius: 24)

                    Circle()
                        .fill(Color.wlCyan)
                        .frame(width: 18, height: 18)
                        .position(x: proxy.size.width * (0.25 + slam * 0.25), y: proxy.size.height / 2)

                    Circle()
                        .fill(Color.wlGreen)
                        .frame(width: 18, height: 18)
                        .position(x: proxy.size.width * (0.75 - slam * 0.25), y: proxy.size.height / 2)
                }
            }
        }
    }
}

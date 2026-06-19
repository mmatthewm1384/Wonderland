import SwiftUI

public struct AgitateWavesView: View {
    public init() {}

    public var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.wlBackground))

                for row in 0..<18 {
                    var path = Path()
                    let baseY = CGFloat(row) / 17 * size.height
                    for xStep in 0...120 {
                        let x = CGFloat(xStep) / 120 * size.width
                        let wave = sin(Double(xStep) * 0.18 + t * (1.0 + Double(row % 5) * 0.21))
                        let y = baseY + CGFloat(wave) * CGFloat(10 + row % 6 * 3)
                        xStep == 0 ? path.move(to: CGPoint(x: x, y: y)) : path.addLine(to: CGPoint(x: x, y: y))
                    }
                    let color: Color = row % 3 == 0 ? .wlCyan : row % 3 == 1 ? .wlPurple : .wlGreen
                    context.stroke(path, with: .color(color.opacity(0.48)), lineWidth: 1.5)
                }
            }
            .ignoresSafeArea()
        }
    }
}

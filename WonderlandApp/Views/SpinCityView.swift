import SwiftUI

struct SpinCityView: View {
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                let t = timeline.date.timeIntervalSinceReferenceDate
                SpinCityRenderer.draw(context: &context, size: size, time: t)
            }
            .background(Color.wlBackground)
            .ignoresSafeArea()
        }
    }
}

private struct SpinCityEntity {
    let seed: Double
    let orbit: Double
    let speed: Double
    let size: Double
    let depth: Double
    let mood: Int
}

private enum SpinCityRenderer {
    private static let entities: [SpinCityEntity] = (0..<90).map { i in
        SpinCityEntity(
            seed: Double(i) * 12.713,
            orbit: 40 + Double((i * 37) % 320),
            speed: 0.08 + Double((i * 17) % 77) / 100.0,
            size: 2 + Double((i * 11) % 16),
            depth: -1.0 + Double((i * 23) % 200) / 100.0,
            mood: i % 4
        )
    }

    static func draw(context: inout GraphicsContext, size: CGSize, time t: Double) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)

        drawField(&context, size: size, time: t)

        for e in entities {
            let angle = t * e.speed + e.seed
            let wobble = sin(t * 0.7 + e.seed) * 28 + sin(t * 1.9 + e.seed) * 9
            let r = e.orbit + wobble

            let p = CGPoint(
                x: center.x + cos(angle) * r * (1.0 + e.depth * 0.12),
                y: center.y + sin(angle * 0.83) * r * (0.62 + e.depth * 0.09)
            )

            drawFilaments(&context, from: center, to: p, entity: e, time: t)
            drawEntity(&context, point: p, entity: e, time: t)
        }

        drawAnomaly(&context, center: center, time: t)
    }

    private static func drawField(_ context: inout GraphicsContext, size: CGSize, time t: Double) {
        for i in 0..<22 {
            let x = size.width * CGFloat(abs(sin(Double(i) * 4.91 + t * 0.03)))
            let y = size.height * CGFloat(abs(cos(Double(i) * 3.17 + t * 0.025)))
            let rect = CGRect(x: x - 2, y: y - 2, width: 4, height: 4)

            context.fill(
                Path(ellipseIn: rect),
                with: .color(.wlPurple.opacity(0.08))
            )
        }
    }

    private static func drawEntity(
        _ context: inout GraphicsContext,
        point p: CGPoint,
        entity e: SpinCityEntity,
        time t: Double
    ) {
        let pulse = 1.0 + sin(t * 2.0 + e.seed) * 0.35
        let alpha = 0.22 + (e.depth + 1.0) * 0.22
        let radius = e.size * pulse

        let color: Color
        switch e.mood {
        case 0: color = .wlCyan
        case 1: color = .wlPurple
        case 2: color = .wlGreen
        default: color = .wlCyan.opacity(0.8)
        }

        var path = Path()
        let segments = 9

        for i in 0...segments {
            let a = Double(i) / Double(segments) * .pi * 1.45
            let distortion = sin(a * 5 + t + e.seed) * radius * 0.32
            let rr = radius + distortion

            let x = p.x + cos(a + t * e.speed) * rr
            let y = p.y + sin(a + t * e.speed * 0.7) * rr

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        context.stroke(
            path,
            with: .color(color.opacity(alpha)),
            lineWidth: max(1.2, radius * 0.14)
        )

        let core = CGRect(
            x: p.x - radius * 0.16,
            y: p.y - radius * 0.16,
            width: radius * 0.32,
            height: radius * 0.32
        )

        context.fill(
            Path(ellipseIn: core),
            with: .color(color.opacity(min(alpha + 0.18, 1.0)))
        )
    }

    private static func drawFilaments(
        _ context: inout GraphicsContext,
        from center: CGPoint,
        to p: CGPoint,
        entity e: SpinCityEntity,
        time t: Double
    ) {
        guard e.size > 10 else { return }

        var path = Path()
        path.move(to: center)

        let mid = CGPoint(
            x: (center.x + p.x) / 2 + CGFloat(sin(t + e.seed) * 80),
            y: (center.y + p.y) / 2 + CGFloat(cos(t * 0.8 + e.seed) * 50)
        )

        path.addQuadCurve(to: p, control: mid)

        context.stroke(
            path,
            with: .color(Color.wlCyan.opacity(0.045)),
            lineWidth: 1
        )
    }

    private static func drawAnomaly(
        _ context: inout GraphicsContext,
        center: CGPoint,
        time t: Double
    ) {
        let cycle = t.truncatingRemainder(dividingBy: 37)
        guard cycle > 31 && cycle < 34 else { return }

        let strength = sin((cycle - 31) / 3 * .pi)
        let radius = 90 + strength * 180

        var path = Path()

        for i in 0...80 {
            let a = Double(i) / 80.0 * .pi * 2
            let distortion = sin(a * 9 + t * 2) * 28 * strength
            let r = radius + distortion

            let x = center.x + cos(a) * r
            let y = center.y + sin(a) * r * 0.72

            if i == 0 {
                path.move(to: CGPoint(x: x, y: y))
            } else {
                path.addLine(to: CGPoint(x: x, y: y))
            }
        }

        context.stroke(
            path,
            with: .color(Color.wlPurple.opacity(0.42 * strength)),
            lineWidth: 3
        )
    }
}

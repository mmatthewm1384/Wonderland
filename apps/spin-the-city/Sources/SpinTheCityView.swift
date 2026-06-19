import SwiftUI

public struct SpinTheCityView: View {
    private let engine = WaveDriftEngine()
    private let districts: [CityDistrict] = CityDistrict.seed
    private let spires: [CitySpire] = CitySpire.seed

    public init() {}

    public var body: some View {
        TimelineView(.animation) { timeline in
            GeometryReader { proxy in
                let t = CGFloat(timeline.date.timeIntervalSinceReferenceDate)
                ZStack {
                    Color.wlBackground.ignoresSafeArea()

                    AtmosphericField(time: t)
                        .opacity(0.92)

                    ForEach(districts) { district in
                        let center = districtCenter(district, in: proxy.size, time: t)
                        DistrictOrbitView(district: district, center: center, time: t)
                    }

                    ForEach(spires) { spire in
                        CitySpireView(spire: spire, size: proxy.size, time: t)
                    }

                    CentralGravityWell(time: t)
                        .frame(width: min(proxy.size.width, proxy.size.height) * 0.38,
                               height: min(proxy.size.width, proxy.size.height) * 0.38)
                        .position(x: proxy.size.width * 0.51, y: proxy.size.height * 0.52)
                }
            }
        }
    }

    private func districtCenter(_ district: CityDistrict, in size: CGSize, time: CGFloat) -> CGPoint {
        let drift = engine.offset(time: time,
                                  speed: district.speed,
                                  phase: district.phase,
                                  amplitude: district.amplitude)
        let orbitalShear = sin(time * district.speed * 0.19 + district.phase) * district.shear
        return CGPoint(
            x: size.width * district.anchor.x + drift.width + orbitalShear,
            y: size.height * district.anchor.y + drift.height - orbitalShear * 0.37
        )
    }
}

private struct DistrictOrbitView: View {
    let district: CityDistrict
    let center: CGPoint
    let time: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<district.ringCount, id: \.self) { ring in
                let spin = time * district.speed * (ring.isMultiple(of: 2) ? 0.18 : -0.13) + district.phase
                let scale = 1.0 + sin(time * district.speed + CGFloat(ring) * 0.71) * 0.045
                UnevenRingShape(noise: spin, teeth: district.teeth + ring)
                    .stroke(district.color.opacity(0.27 + Double(ring) * 0.08),
                            style: StrokeStyle(lineWidth: district.lineWidth,
                                               lineCap: .round,
                                               lineJoin: .round))
                    .frame(width: district.radius * CGFloat(ring + 1) * 0.72 * scale,
                           height: district.radius * CGFloat(ring + 1) * 0.72 * scale)
                    .rotationEffect(.radians(Double(spin)))
                    .shadow(color: district.color.opacity(0.54), radius: 16 + CGFloat(ring) * 5)
            }

            ForEach(0..<district.nodeCount, id: \.self) { node in
                let a = time * district.speed * (0.42 + CGFloat(node % 3) * 0.07) + district.phase + CGFloat(node) * .pi * 2 / CGFloat(district.nodeCount)
                let r = district.radius * (0.42 + CGFloat(node % 4) * 0.11)
                let wobble = sin(time * 0.8 + CGFloat(node) * 1.9) * 13
                let p = CGPoint(x: center.x + cos(a) * (r + wobble),
                                y: center.y + sin(a * 1.23) * (r - wobble * 0.31))
                Circle()
                    .fill(node.isMultiple(of: 3) ? Color.wlGreen : district.color)
                    .frame(width: district.nodeSize + CGFloat(node % 4) * 1.8,
                           height: district.nodeSize + CGFloat(node % 4) * 1.8)
                    .position(p)
                    .shadow(color: district.color.opacity(0.86), radius: 10)
            }

            AttachedHookShape(wave: time * district.speed + district.phase, attachment: 0.42)
                .stroke(district.color.opacity(0.8), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .frame(width: district.radius * 0.78, height: district.radius * 1.28)
                .position(x: center.x + district.radius * 0.54, y: center.y - district.radius * 0.18)
        }
    }
}

private struct AtmosphericField: View {
    let time: CGFloat

    var body: some View {
        Canvas { context, size in
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .color(.wlBackground))

            for i in 0..<18 {
                let y = size.height * CGFloat(i) / 17
                var path = Path()
                for step in 0...80 {
                    let x = size.width * CGFloat(step) / 80
                    let wave = sin(time * (0.24 + CGFloat(i % 5) * 0.03) + CGFloat(step) * 0.18 + CGFloat(i) * 0.47)
                    let fold = cos(time * 0.19 + CGFloat(step) * 0.08) * 9
                    let p = CGPoint(x: x, y: y + wave * CGFloat(22 + i % 6 * 4) + fold)
                    step == 0 ? path.move(to: p) : path.addLine(to: p)
                }
                let color: Color = i % 3 == 0 ? .wlCyan : i % 3 == 1 ? .wlPurple : .wlGreen
                context.stroke(path, with: .color(color.opacity(0.12)), lineWidth: 1.2)
            }
        }
        .ignoresSafeArea()
    }
}

private struct CitySpireView: View {
    let spire: CitySpire
    let size: CGSize
    let time: CGFloat

    var body: some View {
        let base = CGPoint(x: size.width * spire.anchor.x, y: size.height * spire.anchor.y)
        let sway = sin(time * spire.speed + spire.phase) * spire.sway
        let height = spire.height * (1 + sin(time * spire.speed * 0.73 + spire.phase) * 0.05)

        Path { path in
            path.move(to: CGPoint(x: base.x - spire.width, y: base.y))
            path.addLine(to: CGPoint(x: base.x + sway, y: base.y - height))
            path.addLine(to: CGPoint(x: base.x + spire.width, y: base.y))
            path.closeSubpath()
        }
        .stroke(spire.color.opacity(0.52), lineWidth: 1.7)
        .shadow(color: spire.color.opacity(0.54), radius: 11)
    }
}

private struct CentralGravityWell: View {
    let time: CGFloat

    var body: some View {
        ZStack {
            ForEach(0..<5, id: \.self) { i in
                Circle()
                    .stroke(i.isMultiple(of: 2) ? Color.wlPurple.opacity(0.28) : Color.wlCyan.opacity(0.24), lineWidth: 2)
                    .scaleEffect(0.32 + CGFloat(i) * 0.16 + sin(time * 0.9 + CGFloat(i)) * 0.018)
                    .rotationEffect(.radians(Double(time * (0.1 + CGFloat(i) * 0.03))))
                    .shadow(color: .wlPurple.opacity(0.48), radius: 18)
            }
            Circle()
                .fill(Color.wlBackground.opacity(0.78))
                .scaleEffect(0.34 + sin(time * 1.7) * 0.02)
                .shadow(color: .wlCyan.opacity(0.52), radius: 22)
        }
    }
}

private struct UnevenRingShape: Shape {
    var noise: CGFloat
    var teeth: Int

    var animatableData: CGFloat {
        get { noise }
        set { noise = newValue }
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let steps = max(48, teeth * 8)
        let base = min(rect.width, rect.height) / 2

        for step in 0...steps {
            let angle = CGFloat(step) / CGFloat(steps) * .pi * 2
            let distortion = sin(angle * CGFloat(teeth) + noise) * base * 0.035
                + cos(angle * CGFloat(teeth / 2 + 3) - noise * 0.7) * base * 0.026
            let radius = base + distortion
            let point = CGPoint(x: center.x + cos(angle) * radius,
                                y: center.y + sin(angle) * radius)
            step == 0 ? path.move(to: point) : path.addLine(to: point)
        }
        path.closeSubpath()
        return path
    }
}

private struct CityDistrict: Identifiable, Hashable {
    let id = UUID()
    let anchor: CGPoint
    let radius: CGFloat
    let speed: CGFloat
    let phase: CGFloat
    let amplitude: CGFloat
    let shear: CGFloat
    let color: Color
    let ringCount: Int
    let nodeCount: Int
    let nodeSize: CGFloat
    let lineWidth: CGFloat
    let teeth: Int

    static let seed: [CityDistrict] = [
        .init(anchor: CGPoint(x: 0.28, y: 0.34), radius: 112, speed: 1.33, phase: 0.2, amplitude: 19, shear: 22, color: .wlCyan, ringCount: 3, nodeCount: 9, nodeSize: 5, lineWidth: 2.4, teeth: 9),
        .init(anchor: CGPoint(x: 0.68, y: 0.39), radius: 146, speed: 0.91, phase: 1.7, amplitude: 31, shear: -18, color: .wlPurple, ringCount: 4, nodeCount: 11, nodeSize: 4.5, lineWidth: 2.8, teeth: 12),
        .init(anchor: CGPoint(x: 0.49, y: 0.69), radius: 126, speed: 1.71, phase: 2.6, amplitude: 24, shear: 15, color: .wlGreen, ringCount: 3, nodeCount: 8, nodeSize: 5.5, lineWidth: 2.2, teeth: 10)
    ]
}

private struct CitySpire: Identifiable, Hashable {
    let id = UUID()
    let anchor: CGPoint
    let height: CGFloat
    let width: CGFloat
    let speed: CGFloat
    let phase: CGFloat
    let sway: CGFloat
    let color: Color

    static let seed: [CitySpire] = [
        .init(anchor: CGPoint(x: 0.16, y: 0.82), height: 170, width: 20, speed: 0.83, phase: 0.4, sway: 19, color: .wlCyan),
        .init(anchor: CGPoint(x: 0.36, y: 0.88), height: 220, width: 26, speed: 0.61, phase: 1.1, sway: -24, color: .wlPurple),
        .init(anchor: CGPoint(x: 0.77, y: 0.84), height: 190, width: 22, speed: 0.74, phase: 2.8, sway: 21, color: .wlGreen),
        .init(anchor: CGPoint(x: 0.91, y: 0.78), height: 140, width: 18, speed: 1.02, phase: 3.2, sway: -15, color: .wlCyan)
    ]
}

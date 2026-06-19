import SwiftUI

public struct AttachedHookShape: Shape {
    public var wave: CGFloat
    public var attachment: CGFloat

    public init(wave: CGFloat, attachment: CGFloat = 0.5) {
        self.wave = wave
        self.attachment = attachment
    }

    public func path(in rect: CGRect) -> Path {
        var path = Path()
        let start = CGPoint(x: rect.midX, y: rect.minY)
        let end = CGPoint(x: rect.midX + sin(wave) * rect.width * 0.22, y: rect.maxY)
        let c1 = CGPoint(x: rect.minX, y: rect.midY * attachment)
        let c2 = CGPoint(x: rect.maxX, y: rect.midY + cos(wave) * rect.height * 0.18)
        path.move(to: start)
        path.addCurve(to: end, control1: c1, control2: c2)
        return path
    }
}

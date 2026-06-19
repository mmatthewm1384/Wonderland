import SwiftUI

public struct VisualBody: Identifiable, Hashable {
    public let id: UUID
    public var position: CGPoint
    public var radius: CGFloat
    public var speed: CGFloat
    public var phase: CGFloat
    public var amplitude: CGFloat
    public var color: Color

    public init(
        id: UUID = UUID(),
        position: CGPoint,
        radius: CGFloat,
        speed: CGFloat,
        phase: CGFloat,
        amplitude: CGFloat,
        color: Color
    ) {
        self.id = id
        self.position = position
        self.radius = radius
        self.speed = speed
        self.phase = phase
        self.amplitude = amplitude
        self.color = color
    }
}

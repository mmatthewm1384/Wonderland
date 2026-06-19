import CoreGraphics

public struct WaveDriftEngine {
    public init() {}

    public func offset(time: CGFloat, speed: CGFloat, phase: CGFloat, amplitude: CGFloat) -> CGSize {
        let x = sin((time * speed) + phase) * amplitude
        let y = cos((time * speed * 0.73) + phase) * amplitude * 0.62
        return CGSize(width: x, height: y)
    }

    public func pulse(time: CGFloat, speed: CGFloat, phase: CGFloat, strength: CGFloat = 0.08) -> CGFloat {
        1.0 + sin((time * speed) + phase) * strength
    }
}

import AVFoundation
import Combine
import Foundation

@MainActor
public class PlaybackControlState: ObservableObject {
    @Published public var playbackRate: Float = 1.0 {
        didSet { self.player?.rate = self.playbackRate }
    }

    @Published public var subtitlesDelay: TimeInterval = 0.0
    @Published public var audioDelay: TimeInterval = 0.0

    private weak var player: AVPlayer?

    public init(player: AVPlayer? = nil) {
        self.player = player
    }

    public func setPlayer(_ player: AVPlayer) {
        self.player = player
        player.rate = self.playbackRate
    }

    public func resetAll() {
        self.playbackRate = 1.0
        self.subtitlesDelay = 0.0
        self.audioDelay = 0.0
    }
}

// AudioPlayerSwift.swift
//
// Copyright (c) 2016 Tom Baranes
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import Foundation
import AVFoundation

public enum AudioPlayerError: Error {
    case FileExtension, FileNotFound
}

public class AudioPlayer: NSObject {

    public static let SoundDidFinishPlayingNotification = Notification.Name(rawValue: "SoundDidFinishPlayingNotification")
    public typealias SoundDidFinishCompletion = (_ didFinish: Bool) -> Void

    /// Name of the used to initialize the object
    public var name: String?

    /// URL of the used to initialize the object
    public let url: URL?

    /// A callback closure that will be called when the audio finishes playing, or is stopped.
    public var completionHandler: SoundDidFinishCompletion?

    /// is it playing or not?
    public var isPlaying: Bool {
        get {
            if let nonNilsound = sound {
                return nonNilsound.isPlaying
            }
            return false
        }
    }

    /// the duration of the sound.
    public var duration: TimeInterval {
        get {
            if let nonNilsound = sound {
                return nonNilsound.duration
            }
            return 0.0
        }
    }

    /// currentTime is the offset into the sound of the current playback position.
    public var currentTime: TimeInterval {
        get {
            if let nonNilsound = sound {
                return nonNilsound.currentTime
            }
            return 0.0
        }
        set {
           sound?.currentTime = newValue
        }
    }

    /// The volume for the sound. The nominal range is from 0.0 to 1.0.
    public var volume: Float = 1.0 {
        didSet {
            volume = min(1.0, max(0.0, volume))
            targetVolume = volume
        }
    }

    /// "numberOfLoops" is the number of times that the sound will return to the beginning upon reaching the end.
    /// A value of zero means to play the sound just once.
    /// A value of one will result in playing the sound twice, and so on..
    /// Any negative number will loop indefinitely until stopped.
    public var numberOfLoops: Int = 0 {
        didSet {
            sound?.numberOfLoops = numberOfLoops
        }
    }

    /// set panning. -1.0 is left, 0.0 is center, 1.0 is right.
    public var pan: Float = 0.0 {
        didSet {
            sound?.pan = pan
        }
    }

    // MARK: Private properties

    fileprivate let sound: AVAudioPlayer?
    private var startVolume: Float = 1.0
    private var targetVolume: Float = 1.0 {
        didSet {
            sound?.volume = targetVolume
        }
    }

    private var fadeTime: TimeInterval = 0.0
    private var fadeStart: TimeInterval = 0.0
    fileprivate var timer: Timer?

    // MARK: Init

    public convenience init(fileName: String) throws {
        let fixedFileName = fileName.trimmingCharacters(in: .whitespacesAndNewlines)
        var soundFileComponents = fixedFileName.components(separatedBy: ".")
        if soundFileComponents.count == 1 {
            throw AudioPlayerError.FileExtension
        }

        guard let path = Bundle.main.path(forResource: soundFileComponents[0], ofType: soundFileComponents[1]) else {
            throw AudioPlayerError.FileNotFound
        }
        try self.init(contentsOfPath: path)
    }

    public convenience init(contentsOfPath path: String) throws {
        let fileURL = URL(fileURLWithPath: path)
        try self.init(contentsOf: fileURL)
    }

    public init(contentsOf url: URL) throws {
        self.url = url
        name = url.lastPathComponent
        sound = try AVAudioPlayer(contentsOf: url as URL)
        super.init()
        sound?.delegate = self
    }

    deinit {
        timer?.invalidate()
        sound?.delegate = nil
    }

    // MARK: Play / Stop

    public func play() {
        if isPlaying == false {
            sound?.play()
        }
    }

    public func stop() {
        if isPlaying {
            soundDidFinishPlayingSuccessfully(didFinishSuccessfully: false)
        }
    }

    // MARK: Fade

    public func fadeTo(volume: Float, duration: TimeInterval = 1.0) {
        startVolume = sound?.volume ?? 1
        targetVolume = volume
        fadeTime = duration
        fadeStart = NSDate().timeIntervalSinceReferenceDate
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.015, target: self, selector: #selector(handleFadeTo), userInfo: nil, repeats: true)
        }
    }

    public func fadeIn(duration: TimeInterval = 1.0) {
        volume = 0.0
        fadeTo(volume: 1.0, duration: duration)
    }

    public func fadeOut(duration: TimeInterval = 1.0) {
        fadeTo(volume: 0.0, duration: duration)
    }

    // MARK: Private

    @objc internal func handleFadeTo() {
        let now = NSDate().timeIntervalSinceReferenceDate
        let delta: Float = (Float(now - fadeStart) / Float(fadeTime) * (targetVolume - startVolume))
        let volume = startVolume + delta
        sound?.volume = volume
        if delta > 0.0 && volume >= targetVolume ||
            delta < 0.0 && volume <= targetVolume || delta == 0.0 {
                sound?.volume = targetVolume
                timer?.invalidate()
                timer = nil
                if sound?.volume == 0 {
                    stop()
                }
        }
    }

}

extension AudioPlayer: AVAudioPlayerDelegate {

    public func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        soundDidFinishPlayingSuccessfully(didFinishSuccessfully: flag)
    }

}

fileprivate extension AudioPlayer {

    func soundDidFinishPlayingSuccessfully(didFinishSuccessfully: Bool) {
        sound?.stop()
        timer?.invalidate()
        timer = nil

        if let nonNilCompletionHandler = completionHandler {
            nonNilCompletionHandler(didFinishSuccessfully)
        }

        NotificationCenter.default.post(name: AudioPlayer.SoundDidFinishPlayingNotification, object: self)
    }

}

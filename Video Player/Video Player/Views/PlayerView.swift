//
//  PlayerView.swift
//  Video Player
//
//  Created by Otávio Lima on 24/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import UIKit
import AVFoundation

final class PlayerView: UIView {

    struct Dimensions {
        static let margin: CGFloat = 8
        static let buttomHeight: CGFloat = 32
        static let buttomWidth: CGFloat = 32
        static let horizontalSpacing: CGFloat = 15
        static let labelMinWidth: CGFloat = 40

        static let gradientHeight: CGFloat = 80

        private init() {}
    }

    let player = AVPlayer()
    let playerLayer: AVPlayerLayer
    let gradientLayer = CAGradientLayer()
    var playerElapsedTimeObserver: Any?
    var autoHideControlsTimer: Timer?

    let seekSlider = UISlider()

    let closeButton = UIButton(type: .custom)
    let timeRemainingLabel = UILabel()
    let elapsedTimeLabel = UILabel()
    let playPauseButton = UIButton(type: .custom)
    // Just to make it easier to hide/show the controls
    let controlsContainer = UIView()

    init() {
        playerLayer = AVPlayerLayer(player: player)

        super.init(frame: .zero)

        configureUI()
        setupAutoHideTimer()

        layer.insertSublayer(playerLayer, at: 0)

        let timeInterval = CMTimeMakeWithSeconds(1.0, 10)
        playerElapsedTimeObserver = player.addPeriodicTimeObserver(forInterval: timeInterval, queue: DispatchQueue.main) { [weak self] (elapsedTime) in
            self?.handleTimeChange(elapsedTime: elapsedTime)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        playerLayer.frame = bounds
        gradientLayer.frame = CGRect(x: 0,
                                     y: bounds.maxY - Dimensions.gradientHeight,
                                     width: bounds.width,
                                     height: Dimensions.gradientHeight)
    }

    private func configureUI() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        addGestureRecognizer(tapGesture)

        controlsContainer.translatesAutoresizingMaskIntoConstraints = false

        let closeImage = UIImage(named: "close")
        closeButton.setImage(closeImage, for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        let pauseImage = UIImage(named: "pause")
        playPauseButton.setImage(pauseImage, for: .normal)
        playPauseButton.translatesAutoresizingMaskIntoConstraints = false
        playPauseButton.addTarget(self, action: #selector(togglePlayPause), for: .touchUpInside)

        let monospacedFont = UIFont.monospacedDigitSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)

        timeRemainingLabel.translatesAutoresizingMaskIntoConstraints = false
        timeRemainingLabel.numberOfLines = 0
        timeRemainingLabel.textColor = .white
        timeRemainingLabel.font = monospacedFont

        elapsedTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        elapsedTimeLabel.numberOfLines = 0
        elapsedTimeLabel.textColor = .white
        elapsedTimeLabel.font = monospacedFont

        seekSlider.translatesAutoresizingMaskIntoConstraints = false
        seekSlider.addTarget(self, action: #selector(sliderBeganTracking), for: .touchDown)
        seekSlider.addTarget(self, action: #selector(sliderEndedTracking), for: [.touchUpInside, .touchUpOutside])
        seekSlider.addTarget(self, action: #selector(sliderValueChanged), for: .valueChanged)

        // Used to enhance the visibility of the bottom items
        let black = UIColor.black
        let colours = [black.withAlphaComponent(0).cgColor, black.withAlphaComponent(0.7).cgColor]
        let locations: [NSNumber] = [0.2, 0.8]

        gradientLayer.colors = colours
        gradientLayer.locations = locations

        layer.insertSublayer(gradientLayer, above: playerLayer)
        addSubview(controlsContainer)

        controlsContainer.addSubview(closeButton)
        controlsContainer.addSubview(timeRemainingLabel)
        controlsContainer.addSubview(elapsedTimeLabel)
        controlsContainer.addSubview(seekSlider)
        controlsContainer.addSubview(playPauseButton)

        let constraints = [
            closeButton.topAnchor.constraint(equalTo: controlsContainer.topAnchor, constant: Dimensions.margin),
            closeButton.leftAnchor.constraint(equalTo: controlsContainer.leftAnchor, constant: Dimensions.margin),
            closeButton.heightAnchor.constraint(equalToConstant: Dimensions.buttomHeight),
            closeButton.widthAnchor.constraint(equalToConstant: Dimensions.buttomWidth),

            elapsedTimeLabel.leftAnchor.constraint(equalTo: controlsContainer.leftAnchor, constant: Dimensions.margin),
            elapsedTimeLabel.rightAnchor.constraint(equalTo: seekSlider.leftAnchor, constant: -Dimensions.horizontalSpacing),
            elapsedTimeLabel.centerYAnchor.constraint(equalTo: seekSlider.centerYAnchor),
            elapsedTimeLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            elapsedTimeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Dimensions.labelMinWidth),

            timeRemainingLabel.leftAnchor.constraint(equalTo: seekSlider.rightAnchor, constant: Dimensions.horizontalSpacing),
            timeRemainingLabel.rightAnchor.constraint(equalTo: controlsContainer.rightAnchor, constant: -Dimensions.margin),
            timeRemainingLabel.centerYAnchor.constraint(equalTo: seekSlider.centerYAnchor),
            timeRemainingLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),
            elapsedTimeLabel.widthAnchor.constraint(greaterThanOrEqualToConstant: Dimensions.labelMinWidth),

            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainer.centerYAnchor),
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainer.centerXAnchor),
            playPauseButton.heightAnchor.constraint(equalToConstant: Dimensions.buttomHeight),
            playPauseButton.widthAnchor.constraint(equalToConstant: Dimensions.buttomWidth),

            seekSlider.bottomAnchor.constraint(equalTo: controlsContainer.bottomAnchor, constant: -Dimensions.margin),
            seekSlider.widthAnchor.constraint(greaterThanOrEqualToConstant: 0),

            controlsContainer.topAnchor.constraint(equalTo: topAnchor),
            controlsContainer.leftAnchor.constraint(equalTo: leftAnchor),
            controlsContainer.rightAnchor.constraint(equalTo: rightAnchor),
            controlsContainer.bottomAnchor.constraint(equalTo: bottomAnchor),
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func updateTimeLabels(elapsedTime: Float64, duration: Float64) {
        let timeRemaining: Float64 = CMTimeGetSeconds(player.currentItem!.duration) - elapsedTime
        timeRemainingLabel.text = String(format: "%02d:%02d", ((lround(timeRemaining) / 60) % 60), lround(timeRemaining) % 60)
        elapsedTimeLabel.text = String(format: "%02d:%02d", ((lround(elapsedTime) / 60) % 60), lround(elapsedTime) % 60)
    }

    private func handleTimeChange(elapsedTime: CMTime) {
        let duration = CMTimeGetSeconds(player.currentItem!.duration)
        if duration.isFinite {
            let elapsedTime = CMTimeGetSeconds(elapsedTime)
            updateTimeLabels(elapsedTime: elapsedTime, duration: duration)
        }
    }

    @objc private func sliderBeganTracking(slider: UISlider) {
        player.pause()
    }

    @objc private func sliderEndedTracking(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabels(elapsedTime: elapsedTime, duration: videoDuration)

        player.seek(to: CMTimeMakeWithSeconds(elapsedTime, 100)) { (completed: Bool) -> Void in
            if completed {
                self.player.play()
            }
        }
    }

    @objc private func sliderValueChanged(slider: UISlider) {
        let videoDuration = CMTimeGetSeconds(player.currentItem!.duration)
        let elapsedTime: Float64 = videoDuration * Float64(seekSlider.value)
        updateTimeLabels(elapsedTime: elapsedTime, duration: videoDuration)
    }

    @objc private func togglePlayPause() {
        if player.rate > 0 {
            let playImage = UIImage(named: "play")
            playPauseButton.setImage(playImage, for: .normal)
            player.pause()
        } else {
            let pauseImage = UIImage(named: "pause")
            playPauseButton.setImage(pauseImage, for: .normal)
            player.play()
        }
    }

    private func setupAutoHideTimer() {
        autoHideControlsTimer?.invalidate()

        autoHideControlsTimer = Timer.scheduledTimer(timeInterval: 1.5,
                                                     target: self,
                                                     selector: #selector(handleAutoHideTimer(_:)),
                                                     userInfo: nil,
                                                     repeats: false)
    }

    @objc private func handleAutoHideTimer(_ sender: Any) {
        hideControls(animated: true)
    }

    @objc private func handleTap(_ sender: Any) {
        setupAutoHideTimer()

        showControls(animated: false)
    }

    private func hideControls(animated: Bool) {
        self.controlsContainer.alpha = 1

        let animations = {
            self.controlsContainer.alpha = 0
        }

        if animated {
            UIView.animate(withDuration: 0.5, animations: animations)
        } else {
            animations()
        }
    }

    private func showControls(animated: Bool) {
        self.controlsContainer.alpha = 0

        let animations = {
            self.controlsContainer.alpha = 1
        }

        if animated {
            UIView.animate(withDuration: 0.5, animations: animations)
        } else {
            animations()
        }
    }

    deinit {
        playerElapsedTimeObserver = nil
        autoHideControlsTimer?.invalidate()
        autoHideControlsTimer = nil
    }
}

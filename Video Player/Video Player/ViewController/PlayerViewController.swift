//
//  PlayerViewController.swift
//  Video Player
//
//  Created by Otávio Lima on 24/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

final class PlayerViewController: UIViewController {

    var videoURL: String?
    var playerView = PlayerView()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        playVideo()
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return [.landscapeLeft, .landscapeRight]
    }

    override var shouldAutorotate: Bool {
        return true
    }

    @objc func buttonWasPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    // MARK: Public API

    public func playVideo() {
        guard let videoURL = videoURL, let url = URL(string: videoURL) else {
            return
        }

        let playerItem = AVPlayerItem(url: url)
        playerView.player.replaceCurrentItem(with: playerItem)

        playerView.player.play()
    }

    // MARK: Private Methods

    private func configureUI() {
        playerView.translatesAutoresizingMaskIntoConstraints = true
        playerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        playerView.frame = view.bounds

        view.addSubview(playerView)

        playerView.closeButton.addTarget(self, action: #selector(buttonWasPressed(_:)), for: .touchUpInside)
    }

}

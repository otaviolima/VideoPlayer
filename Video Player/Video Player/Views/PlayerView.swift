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

    let player = AVPlayer()
    let playerLayer: AVPlayerLayer

    let closeButton = UIButton(type: .custom)

    init() {
        playerLayer = AVPlayerLayer(player: player)

        super.init(frame: .zero)

        configureUI()

        layer.insertSublayer(playerLayer, at: 0)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        playerLayer.frame = bounds
    }

    private func configureUI() {
        addSubview(closeButton)

        closeButton.setTitle("Close", for: .normal)
        closeButton.translatesAutoresizingMaskIntoConstraints = false

        closeButton.topAnchor.constraint(equalTo: topAnchor).isActive = true
        closeButton.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
    }

}

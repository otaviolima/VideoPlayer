//
//  ThumbnailCell.swift
//  Video Player
//
//  Created by Otávio Lima on 23/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import UIKit

struct Dimensions {
    static let thumbnailAspectRatio: CGFloat = 270 / 480
    static let margin: CGFloat = 8
    static let verticalSpacing: CGFloat = 4

    private init() {}
}

class ThumbnailCell: UITableViewCell {

    private let title = UILabel()
    private let presenterName = UILabel()
    private let time = UILabel()
    private let descriptionLabel = UILabel()
    private let thumbImageView = UIImageView()

    var model: ThumbnailModel? {
        didSet {
            configureWith(model: model)
        }
    }

    var thumbnailImage: UIImage? {
        set {
            thumbImageView.image = newValue
        }

        get {
            return thumbImageView.image
        }
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        configureUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureUI() {
        title.translatesAutoresizingMaskIntoConstraints = false
        title.numberOfLines = 0
        title.textColor = .white

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.numberOfLines = 0

        presenterName.translatesAutoresizingMaskIntoConstraints = false
        presenterName.numberOfLines = 0

        time.translatesAutoresizingMaskIntoConstraints = false
        time.numberOfLines = 0
        time.textAlignment = .right
        time.textColor = .white

        thumbImageView.translatesAutoresizingMaskIntoConstraints = false
        thumbImageView.contentMode = .scaleAspectFit

        contentView.addSubview(descriptionLabel)
        contentView.addSubview(presenterName)
        contentView.addSubview(thumbImageView)

        thumbImageView.addSubview(title)
        thumbImageView.addSubview(time)

        #if DEBUG
        thumbImageView.backgroundColor = UIColor.gray
        #endif

        let deviceWidth = min(UIScreen.main.bounds.width, UIScreen.main.bounds.height)

        let constraints = [
            thumbImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 0),
            thumbImageView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            thumbImageView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            thumbImageView.heightAnchor.constraint(equalToConstant: deviceWidth * Dimensions.thumbnailAspectRatio),

            title.topAnchor.constraint(equalTo: thumbImageView.topAnchor, constant: Dimensions.margin),
            title.leftAnchor.constraint(equalTo: thumbImageView.leftAnchor, constant: Dimensions.margin),
            title.rightAnchor.constraint(equalTo: thumbImageView.rightAnchor, constant: -Dimensions.margin),
            title.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),

            time.leftAnchor.constraint(equalTo: thumbImageView.leftAnchor, constant: Dimensions.margin),
            time.rightAnchor.constraint(equalTo: thumbImageView.rightAnchor, constant: -Dimensions.margin),
            time.bottomAnchor.constraint(equalTo: thumbImageView.bottomAnchor, constant: -Dimensions.margin),
            time.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),

            NSLayoutConstraint(item: presenterName, attribute: .top, relatedBy: .equal, toItem: thumbImageView, attribute: .bottom, multiplier: 1, constant: Dimensions.verticalSpacing),
            presenterName.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimensions.margin),
            presenterName.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimensions.margin),
            presenterName.heightAnchor.constraint(greaterThanOrEqualToConstant: 0),

            NSLayoutConstraint(item: descriptionLabel, attribute: .top, relatedBy: .equal, toItem: presenterName, attribute: .bottom, multiplier: 1, constant: Dimensions.verticalSpacing),
            descriptionLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: Dimensions.margin),
            descriptionLabel.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -Dimensions.margin),
            descriptionLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Dimensions.margin),
            descriptionLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 0)
        ]

        NSLayoutConstraint.activate(constraints)
    }

    private func configureWith(model: ThumbnailModel?) {
        title.text = model?.title
        presenterName.text = model?.presenterName
        time.text = model?.time
        descriptionLabel.text = model?.description
        // Needs to clear, otherwise when the cell is reused the old image appears for a brief time before loading the correct one
        thumbImageView.image = nil
    }
    
}

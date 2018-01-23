//
//  VideoListViewController.swift
//  Video Player
//
//  Created by Otávio Lima on 23/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import UIKit

class VideoListViewController: UIViewController {

    static let thumbnailCellID = "thumbnailCellID"

    let tableView = UITableView()
    private var dataSource = [ThumbnailModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        mockData()
    }

    private func configureUI() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.frame
        tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        tableView.register(ThumbnailCell.self, forCellReuseIdentifier: VideoListViewController.thumbnailCellID)
        tableView.tableFooterView = UIView() // Avoid empty cells in the bottom of the tableview

        view.addSubview(tableView)
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }

    override var shouldAutorotate: Bool {
        return true
    }

    private func mockData() {
        var models = [ThumbnailModel]()

        for _ in 1...10 {
            let model = ThumbnailModel(title: "G12 Standard Level English<Syntax> Trial Ver.",
                presenterName: "Masao Seki",
                time: "10:00",
                description: "G12 Standard Level English <Syntax> Tense(1) Chapter 1",
                videoURL: "http://recruit.brightcove.com.edgesuite.net/rtmp/o1/4477599122001/4477599122001_5352864362001_5352849758001.mp4?pubId=4477599122001&videoId=5352849758001",
                thumbnailURL: "https://recruit-a.akamaihd.net/pd/4477599122001/201512/23/4477599122001_4672789792001_4672787431001-vs.jpg?pubId=4477599122001")

            models.append(model)
        }

        dataSource = models
    }

}

// MARK: - TableView DataSource & Delegate

extension VideoListViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let thumbnailCell = tableView.dequeueReusableCell(withIdentifier: VideoListViewController.thumbnailCellID, for: indexPath) as! ThumbnailCell

        let model = dataSource[indexPath.row]
        thumbnailCell.model = model

        return thumbnailCell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]

        AsyncImageLoader.shared.loadImageWith(urlString: model.thumbnailURL) { (image) in
            DispatchQueue.main.async {
                guard let cell = tableView.cellForRow(at: indexPath) as? ThumbnailCell,
                    let image = image else {
                        return
                }

                cell.thumbnailImage = image
            }
        }
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]

        AsyncImageLoader.shared.cancelDownloading(urlString: model.thumbnailURL)
    }
}


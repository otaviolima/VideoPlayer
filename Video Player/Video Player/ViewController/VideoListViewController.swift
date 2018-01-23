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
    private let dataProvider = PlaylistDataProviderFactory.dataProvider()
    private var dataSource = [ThumbnailModel]()

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        reloadData()
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

    private func reloadData() {
        dataProvider.loadPlaylist { [weak self](items) in
            DispatchQueue.main.async {
                self?.dataSource = items
                self?.tableView.reloadData()
            }
        }
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

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = dataSource[indexPath.row]

        let vc = PlayerViewController()
        vc.videoURL = model.videoURL

        present(vc, animated: true, completion: nil)
        
    }
}


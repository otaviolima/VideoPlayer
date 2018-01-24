//
//  PlaylistDataProvider.swift
//  Video Player
//
//  Created by Otávio Lima on 23/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import Foundation

protocol PlaylistDataProvider {

    typealias PlaylistLoadCompletion = (_ items: [ThumbnailModel]) -> Void

    func loadPlaylist(_ completion: @escaping PlaylistLoadCompletion)

}

struct PlaylistDataProviderFactory {

    // Allow to easily mock the data or swap for a network provider
    static func dataProvider() -> PlaylistDataProvider {
        return PlaylistLocalJSONDataProvider()
    }

}

private final class PlaylistLocalJSONDataProvider: PlaylistDataProvider {

    typealias PlaylistLoadCompletion = (_ items: [ThumbnailModel]) -> Void

    func loadPlaylist(_ completion: @escaping PlaylistLoadCompletion) {
        guard let jsonURL = Bundle.main.url(forResource: "playlist", withExtension: "json") else {
            completion([])

            return
        }

        do {
            let data = try Data(contentsOf: jsonURL)

            guard let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves) as? [Dictionary<String, AnyObject>] else {
                completion([])

                return
            }

            var models = [ThumbnailModel]()

            for item in jsonResult {
                guard let title = item["title"] as? String,
                    let presenterName = item["presenter_name"] as? String,
                    let time = transformDuration(duration: item["video_duration"] as? Double),
                    let description = item["description"] as? String,
                    let videoURL = item["video_url"] as? String,
                    let thumbnailURL = item["thumbnail_url"] as? String else {
                        continue
                }

                let model = ThumbnailModel(title: title,
                                           presenterName: presenterName,
                                           time: time,
                                           description: description,
                                           videoURL: videoURL,
                                           thumbnailURL: thumbnailURL)

                models.append(model)
            }

            completion(models)
        } catch {
            completion([])
        }
    }

    private func transformDuration(duration: Double?) -> String? {
        guard var duration = duration else {
            return nil
        }

        duration = duration / 1000 // Original duration is in miliseconds
        let hours = floor(duration / 3600)
        let minutes = floor((duration - (hours * 3600)) / 60.0)
        let seconds = floor(duration - (hours * 3600) - (minutes * 60))

        if hours > 0 {
            return String(format: "%02d:%02d:%02d", Int(hours), Int(minutes), Int(seconds))
        } else {
            return String(format: "%02d:%02d", Int(minutes), Int(seconds))
        }
    }

}

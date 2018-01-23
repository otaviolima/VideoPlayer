//
//  AsyncImageLoader.swift
//  Video Player
//
//  Created by Otávio Lima on 23/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import Foundation
import UIKit

final class AsyncImageLoader {

    static let shared = AsyncImageLoader()

    // This is just a proof of concept of async loading and caching.
    // For a production ready app ideally the caching strategy should be more robust
    typealias ImageLoadCompletion = (_ image: UIImage?) -> Void
    private var tasks: [AnyHashable: URLSessionDataTask] = [:]
    private let imageCache = NSCache<AnyObject, UIImage>()

    private init() { }

    func loadImageWith(urlString: String, completion: @escaping ImageLoadCompletion) {
        guard let url = URL(string: urlString) else {
            completion(nil)

            return
        }

        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) {
            completion(cachedImage)

            return
        }

        let task = URLSession.shared.dataTask(with: url, completionHandler: { [unowned self] (data, response, error) -> Void in
            self.tasks[urlString] = nil

            guard let data = data,
                let image = UIImage(data: data)
                else {
                    completion(nil)
                    return
            }

            self.imageCache.setObject(image, forKey: urlString as AnyObject)
            completion(image)
        })
        task.resume()

        tasks[urlString] = task
    }

    func cancelDownloading(urlString: String) {
        guard let task = tasks[urlString] else {
            return
        }

        task.cancel()
    }
}



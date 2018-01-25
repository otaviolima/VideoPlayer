//
//  ThumbnailToFullScreenAnimator.swift
//  Video Player
//
//  Created by Otávio Lima on 24/01/18.
//  Copyright © 2018 Francisco Otavio Silva de Lima. All rights reserved.
//

import Foundation
import UIKit

class ThumbnailToFullScreenAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    let durationOpening = 0.60
    let durationClosing = 0.40
    var presenting = true

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if presenting {
            return durationOpening
        }
        return durationClosing
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let toView = transitionContext.view(forKey: .to), let fromView = transitionContext.view(forKey: .from) else {
            return
        }

        if presenting {
            containerView.addSubview(toView)
            var initialFrame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            initialFrame.size.height = 0
            toView.frame = initialFrame

            UIView.animate(withDuration: durationOpening,
                           delay:0.0,
                           usingSpringWithDamping: 1.0,
                           initialSpringVelocity: 0.0,
                           animations: {
                            toView.frame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            },
                           completion:{ _ in
                            transitionContext.completeTransition(true)
            }
            )
        } else {
            toView.frame = transitionContext.initialFrame(for: transitionContext.viewController(forKey: .from)!)

            UIView.animate(withDuration: durationClosing, delay:0.0, options: .curveLinear,
                           animations: {
                            fromView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
                            toView.frame = transitionContext.finalFrame(for: transitionContext.viewController(forKey: .to)!)
            },
                           completion:{ _ in
                            transitionContext.completeTransition(true)
            }
            )
        }
    }
}

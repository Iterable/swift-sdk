//
//  Copyright © 2020 Iterable. All rights reserved.
//

import Foundation

import UIKit

struct InAppCalculations {
    struct AnimationInput {
        let position: ViewPosition
        let isModal: Bool
        let shouldAnimate: Bool
        let location: IterableMessageLocation
        let safeAreaInsets: UIEdgeInsets
        let backgroundColor: UIColor?
    }
    
    struct AnimationDetail {
        let initial: AnimationParam
        let final: AnimationParam
    }
    
    struct AnimationParam {
        let position: ViewPosition
        let alpha: CGFloat
        let bgColor: UIColor
    }
    
    static func calculateAnimationDetail(animationInput input: AnimationInput) -> AnimationDetail? {
        guard input.isModal == true else {
            return nil
        }
        
        if input.shouldAnimate {
            let startPosition = calculateAnimationStartPosition(for: input.position,
                                                                location: input.location,
                                                                safeAreaInsets: input.safeAreaInsets)
            let startAlpha = calculateAnimationStartAlpha(location: input.location)
            
            let initialParam = AnimationParam(position: startPosition,
                                              alpha: startAlpha,
                                              bgColor: UIColor.clear)
            let finalBgColor = finalViewBackgroundColor(bgColor: input.backgroundColor, isModal: input.isModal)
            let finalParam = AnimationParam(position: input.position,
                                            alpha: 1.0,
                                            bgColor: finalBgColor)
            return AnimationDetail(initial: initialParam,
                                   final: finalParam)
        } else if let bgColor = input.backgroundColor {
            return AnimationDetail(initial: AnimationParam(position: input.position, alpha: 1.0, bgColor: UIColor.clear),
                                   final: AnimationParam(position: input.position, alpha: 1.0, bgColor: bgColor))
        } else {
            return nil
        }
    }
    
    static func swapAnimation(animationDetail: AnimationDetail) -> AnimationDetail {
        AnimationDetail(initial: animationDetail.final, final: animationDetail.initial)
    }

    static func calculateAnimationStartPosition(for position: ViewPosition,
                                                location: IterableMessageLocation,
                                                safeAreaInsets: UIEdgeInsets) -> ViewPosition {
        let startPosition: ViewPosition
        
        switch location {
        case .top:
            startPosition = ViewPosition(width: position.width,
                                         height: position.height,
                                         center: CGPoint(x: position.center.x,
                                                         y: position.center.y - position.height - safeAreaInsets.top))
        case .bottom:
            startPosition = ViewPosition(width: position.width,
                                         height: position.height,
                                         center: CGPoint(x: position.center.x,
                                                         y: position.center.y + position.height + safeAreaInsets.bottom))
        case .center, .full:
            startPosition = position
        }
        
        return startPosition
    }

    static func calculateAnimationStartAlpha(location: IterableMessageLocation) -> CGFloat {
        let startAlpha: CGFloat
        switch location {
        case .top, .bottom:
            startAlpha = 1.0
        case .center, .full:
            startAlpha = 0.0
        }
        
        return startAlpha
    }

    static func safeAreaInsets(for view: UIView) -> UIEdgeInsets {
            return view.safeAreaInsets
    }
    
    static func calculateWebViewPosition(safeAreaInsets: UIEdgeInsets,
                                         parentPosition: ViewPosition,
                                         paddingLeft: CGFloat,
                                         paddingRight: CGFloat,
                                         location: IterableMessageLocation,
                                         inAppHeight: CGFloat) -> ViewPosition {
        var position = ViewPosition()
        // set the height
        position.height = inAppHeight
        
        // now set the width
        let notificationWidth = 100 - (paddingLeft + paddingRight)
        position.width = parentPosition.width * notificationWidth / 100
        
        // Position webview
        position.center = parentPosition.center
        
        // set center x
        position.center.x = parentPosition.width * (paddingLeft + notificationWidth / 2) / 100
        
        // set center y
        switch location {
        case .top:
            position.height = position.height + safeAreaInsets.top
            let halfWebViewHeight = position.height / 2
            position.center.y = halfWebViewHeight
        case .bottom:
            let halfWebViewHeight = position.height / 2
            position.center.y = parentPosition.height - halfWebViewHeight - safeAreaInsets.bottom
        default: break
        }
        
        return position
    }
    
    static func createDismisser(for viewController: UIViewController, isModal: Bool, isInboxMessage: Bool) -> () -> Void {
        guard isModal else {
            return { [weak viewController] in
                viewController?.navigationController?.popViewController(animated: true)
            }
        }
        
        return { [weak viewController] in
            viewController?.dismiss(animated: isInboxMessage)
        }
    }
    
    static func initialViewBackgroundColor(isModal: Bool) -> UIColor {
        isModal ? UIColor.clear : .iterableSystemBackground
    }
    
    static func finalViewBackgroundColor(bgColor: UIColor?, isModal: Bool) -> UIColor {
        if isModal {
            return bgColor ?? UIColor.clear
        } else {
            return .iterableSystemBackground
        }
    }
}

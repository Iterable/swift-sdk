//
//  Copyright © 2022 Iterable. All rights reserved.
//

import Foundation
import WebKit

@testable import IterableSDK

class MockWebView: WebViewProtocol {
    let view: UIView = UIView()
    
    func loadHTMLString(_: String, baseURL _: URL?) -> WKNavigation? {
        nil
    }
    
    func set(position: ViewPosition) {
        self.position = position
        view.frame.size.width = position.width
        view.frame.size.height = position.height
        view.center = position.center
    }
    
    func set(navigationDelegate _: WKNavigationDelegate?) {}
    
    func layoutSubviews() {}
    
    func calculateHeight() -> Pending<CGFloat, IterableError> {
        Fulfill<CGFloat, IterableError>(value: height)
    }
    
    var position: ViewPosition = ViewPosition()
    
    private var height: CGFloat
    
    init(height: CGFloat) {
        self.height = height
    }
}

//
//  Copyright © 2019 Iterable. All rights reserved.
//

import UIKit

@IBDesignable
@objcMembers
open class IterableInboxNavigationViewController: UINavigationController {
    // MARK: Settable properties
    
    /// If you want to use a custom layout for your Inbox TableViewCell
    /// this is where you should override it.
    /// Please note that this assumes  that the nib is present in the main bundle.
    @IBInspectable public var cellNibName: String? = nil {
        didSet {
            inboxViewController?.cellNibName = cellNibName
        }
    }
    
    /// This is the title for the Inbox Navigation Bar
    @IBInspectable public var navTitle: String? = nil {
        didSet {
            if let navTitle = navTitle {
                inboxViewController?.navigationItem.title = navTitle
            }
        }
    }
    
    /// Set this to `true` to show a popup when an inbox message is selected in the list.
    /// Set this to `false`to push inbox message into navigation stack.
    @IBInspectable public var isPopup: Bool = true {
        didSet {
            inboxViewController?.isPopup = isPopup
        }
    }
    
    /// We default, we don't show any message when inbox is empty.
    /// If you want to show a message, such as, "There are no messages", you will
    /// have to set the `noMessagesTitle` and  `noMessagesText` properties below.

    /// Use this to set the title to show when there are no message in the inbox.
    @IBInspectable public var noMessagesTitle: String? = nil {
        didSet {
            inboxViewController?.noMessagesTitle = noMessagesTitle
        }
    }

    /// Use this to set the message to show when there are no message in the inbox.
    @IBInspectable public var noMessagesBody: String? = nil {
        didSet {
            inboxViewController?.noMessagesBody = noMessagesBody
        }
    }

    /// Set this property to override default inbox display behavior. You should set either this property
    /// or `viewDelegateClassName`property but not both.
    public var viewDelegate: IterableInboxViewControllerViewDelegate? {
        didSet {
            inboxViewController?.viewDelegate = viewDelegate
        }
    }
    
    /// Set this property if you want to set the view delegate class name in Storyboard
    /// and want `IterableInboxViewController` to create a view delegate class for you.
    /// The class name must include the package name as well, e.g., MyModule.CustomInboxViewDelegate
    @IBInspectable public var viewDelegateClassName: String? = nil {
        didSet {
            inboxViewController?.viewDelegateClassName = viewDelegateClassName
        }
    }
    
    /// Whether we should we show large titles for inbox.
    /// This does not have any effect below iOS 11.
    @IBInspectable public var largeTitles: Bool = false {
        didSet {
            navigationBar.prefersLargeTitles = largeTitles
        }
    }
    
    /// Whether to show different sections as grouped.
    @IBInspectable public var groupSections: Bool = false {
        didSet {
            if groupSections {
                initializeGroupedInbox()
            }
        }
    }
    
    // MARK: Initializers
    
    /// This initializer should be used when initializing from Code.
    public init() {
        ITBInfo()
        
        super.init(nibName: nil, bundle: nil)
        
        setup()
    }
    
    /// This initializer will be called when initializing from storyboard
    public required init?(coder aDecoder: NSCoder) {
        ITBInfo()
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    override open func viewDidLoad() {
        ITBDebug()
        
        super.viewDidLoad()
        
        // Add "Done" button if this view is being presented by another view controller
        // We have to do the following asynchronously because
        // self.presentingViewController is not set yet.
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self, strongSelf.viewControllers.count > 0 else {
                return
            }
            
            if let _ = strongSelf.presentingViewController {
                let viewController = strongSelf.viewControllers[0]
                if viewController.navigationItem.leftBarButtonItem == nil, viewController.navigationItem.rightBarButtonItem == nil {
                    viewController.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(strongSelf.onDoneTapped))
                }
            }
        }
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        ITBDebug()
        
        super.viewWillAppear(animated)
        
        inboxViewController?.viewModel.viewWillAppear()
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        ITBDebug()
        
        super.viewWillDisappear(animated)
        
        inboxViewController?.viewModel.viewWillDisappear()
    }
    
    /// Do not use this
    override private init(rootViewController: UIViewController) {
        ITBInfo()
        
        super.init(rootViewController: rootViewController)
        
        setup()
    }
    
    /// Do not use this
    override private init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        ITBInfo()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    private func setup() {
        let inboxViewController: IterableInboxViewController
        
        if viewControllers.count > 0 {
            // Means this view controller was initialized in code and we have set
            // the rootViewController.
            guard let viewController = viewControllers[0] as? IterableInboxViewController else {
                assertionFailure("RootViewController must be of type IterableInboxViewController")
                return
            }
            
            inboxViewController = viewController
        } else {
            inboxViewController = IterableInboxViewController(style: .plain)
            
            viewControllers.append(inboxViewController)
        }
        
        inboxViewController.cellNibName = cellNibName
    }
    
    @objc private func onDoneTapped() {
        ITBInfo()
        
        presentingViewController?.dismiss(animated: true)
    }
    
    private func initializeGroupedInbox() {
        let inboxViewController = IterableInboxViewController(style: .grouped)
        copyProperties(inboxViewController: inboxViewController)
        viewControllers = [inboxViewController]
    }
    
    private func copyProperties(inboxViewController: IterableInboxViewController) {
        inboxViewController.cellNibName = cellNibName
        if let navTitle = navTitle {
            inboxViewController.navigationItem.title = navTitle
        }
        inboxViewController.isPopup = isPopup
        inboxViewController.viewDelegate = viewDelegate
        inboxViewController.viewDelegateClassName = viewDelegateClassName
    }
    
    private var inboxViewController: IterableInboxViewController? {
        viewControllers[0] as? IterableInboxViewController
    }
}

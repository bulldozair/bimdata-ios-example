//
//  BIMDataViewController.swift
//  BIMDataViewer
//
//  Created by Armel Fardel on 12/01/2024.
//


import UIKit
import WebKit

class BIMDataViewController: UIViewController {
    private static let customListenerName = "iOSObjectSelectedListener"
    private var webViewConfiguration = WKWebViewConfiguration()
    var model: BIMDataModel?
    
    private lazy var webView: WKWebView = {
        prepareListeners()
        let webView = WKWebView(frame: .zero, configuration: webViewConfiguration)
        webView.navigationDelegate = self
        webView.isInspectable = true
        webView.scrollView.bounces = false
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.bottomAnchor.constraint(equalTo: webView.bottomAnchor).isActive = true
        view.topAnchor.constraint(equalTo: webView.topAnchor).isActive = true
        view.leftAnchor.constraint(equalTo: webView.leftAnchor).isActive = true
        view.rightAnchor.constraint(equalTo: webView.rightAnchor).isActive = true
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let action1 = UIAction(title: "Online", handler: { _ in
            Task {
                await self.loadWebView(offline: false)
            }
        })
        let action2 = UIAction(title: "Offline", handler: { _ in
            Task {
                await self.loadWebView(offline: true)
            }
        })
        let segmentedControl = UISegmentedControl(frame: .zero, actions: [action1, action2])
        segmentedControl.selectedSegmentIndex = 0
        
        navigationItem.titleView = segmentedControl
        
        Task {
            await loadWebView(offline: false)
        }
    }
    
    func loadWebView(offline: Bool) async {
        let viewerURL = Bundle.main.url(forResource: "viewer", withExtension: "html")!
        
        if offline {
            model = BIMDataModelOffline.defaultModel()
        } else {
            model = BIMDataModelOnline.defaultModel()
        }
        prepareSenders()
        webView.loadFileURL(
            viewerURL,                
            allowingReadAccessTo: viewerURL.deletingLastPathComponent()
        )
    }
    
    //Since we might change between Offline & Online, the parameters to send to the Viewer might change, though the way we inject the values are static, so we need to remove the previously added one.
    func removePreviousInjectedObjectScriptIfNeeded() {
        let scripts = webViewConfiguration.userContentController.userScripts
        let filteredScripts = scripts.filter {
            !$0.source.contains("injectedObject")
        }
        webViewConfiguration.userContentController.removeAllUserScripts()
        filteredScripts.forEach {
            webViewConfiguration.userContentController.addUserScript($0)
        }
    }
    
    /*
     Swift to JavaScript
     */
    func prepareSenders() {
        guard let model = model else {
            print("No model to inject")
            return
        }
        removePreviousInjectedObjectScriptIfNeeded()
        // We keep "getMessageFromSwift" that was taken from sample
        // It's to see that we can access correctly the inserted object for debugging purposes
        let scriptString = """
                               var injectedObject = {
                                    getViewerParams: function() {
                                        return '\(model.paramsJSONStringified())';
                                    },
                                    getMessageFromSwift: function() {
                                        return 'This is a message from the Swift code';
                                    }
                               };
                               """
        let script = WKUserScript(source: scriptString,
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: true)
        webViewConfiguration.userContentController.addUserScript(script)
    }
    
    /*
     JavaScript to Swift
     */
    func prepareListeners() {
        // Supposed to work?
        // Source https://github.com/vitejs/vite/discussions/14485 to allow type="module" and an import from a file?
        webViewConfiguration.preferences.setValue(true,
                                                  forKey: "allowFileAccessFromFileURLs")
        //Console Listeners
        webViewConfiguration.addJSListener(.log,
                                           with: "bbLogHandler",
                                           handlerDelegate: self)
        webViewConfiguration.addJSListener(.info,
                                           with: "bbInfoHandler",
                                           handlerDelegate: self)
        webViewConfiguration.addJSListener(.error,
                                           with: "bbErrorHandler",
                                           handlerDelegate: self)
        webViewConfiguration.addJSListener(.warning,
                                           with: "bbWarningHandler",
                                           handlerDelegate: self)
        webViewConfiguration.addJSListener(.debug,
                                           with: "bbDebugHandler",
                                           handlerDelegate: self)
        // Custom Listener for JSCode:
        // `window.webkit.messageHandlers.<LISTENER_NAME>.postMessage('some message')`
        // where `<LISTENER_NAME>` is the parameter name value in `userContentController.add(_:name:)` method
        webViewConfiguration.userContentController.add(self, name: Self.customListenerName)

    }
}

extension BIMDataViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController,
                               didReceive message: WKScriptMessage) {
//        print("userContentController(_:didReceive:)")
//        print("Message.name: \(message.name)")
        switch message.name {
        case  Self.customListenerName:
            print("Message from listener: \(message.body)\n")
        default:
            print("Message from Console: \(message.body)\n")
        }
    }
}

extension BIMDataViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("webView(_:didFinish:)")
    }
}

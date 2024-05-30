//
//  JSLoggerListener.swift
//  BIMDataViewer
//
//  Created by Armel Fardel on 15/03/2024.
//

import Foundation
import WebKit


enum JSLoggerListener {
    case log
    case info
    case warning
    case error
    case debug
    
    //For JS methods: console.log(), console.warn(), console.info(), console.debug(), console.error()
    var associatedPipeName: String {
        switch self {
        case .log:
            return "log"
        case .warning:
            return "warn"
        case .info:
            return "info"
        case .debug:
            return "debug"
        case .error:
            return "error"
        }
    }
    
    func associatedScriptCode(for handlerName: String) -> String {
        let methodName = "bbCapture\(associatedPipeName.capitalized)"
        let source = """
        function \(methodName)(msg) { window.webkit.messageHandlers.\(handlerName).postMessage(msg);
        }
        window.console.\(associatedPipeName) = \(methodName);
        """
        return source
    }
}

extension WKWebViewConfiguration {
    /// - Parameters:
    ///   - listener: A enum value that can listen to `console.something` JaveScript code
    ///   - handlerName: It's the value of `message.name` in `WKScriptMessageHandler` method `userContentController(_:didReceive:)`
    ///   - handlerDelegate: The delegate that will implement `userContentController(_:didReceive:)` and receive the logs
    func addJSListener(_ listener: JSLoggerListener, with handlerName: String, handlerDelegate: WKScriptMessageHandler) {
        let source = listener.associatedScriptCode(for: handlerName)
        let script = WKUserScript(source: source,
                                  injectionTime: .atDocumentStart,
                                  forMainFrameOnly: false)
        userContentController.addUserScript(script)
        userContentController.add(handlerDelegate, name: handlerName)
    }
}


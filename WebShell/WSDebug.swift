//
//  WebShellDebug.swift
//  WebShell
//
//  Created by Wesley de Groot on 31-01-16.
//  Copyright © 2016 RandyLu. All rights reserved.
//

import Foundation
import WebKit
// This is generated by swift, i dont know the reason,
// but i'm not removing it.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// @wdg Add Debug support
// Issue: None.
// This extension will handle the Debugging options.
extension ViewController {

	// @wdg Override settings via commandline
	// .... Used for popups, and debug options.
	func checkSettings() -> Void {
		// Need to overwrite settings?
		if (CommandLine.argc > 0) {
			for i in stride(from: 1, to: Int(CommandLine.argc), by: 2) {
//            for (var i = 1; i < Int(Process.argc) ; i = i + 2) {
				if ((String(CommandLine.arguments[i])) == "-NSDocumentRevisionsDebugMode") {
					if ((String(CommandLine.arguments[i + 1])) == "YES") {
						WebShellSettings["debugmode"] = true
						WebShellSettings["consoleSupport"] = true
					}
				}
                
				if ((String(describing: Process().arguments?[i])).uppercased() == "-DEBUG") {
					if ((String(describing: Process().arguments![i + 1])).uppercased() == "YES" || (String(describing: Process().arguments?[i + 1])).uppercased() == "true") {
						WebShellSettings["debugmode"] = true
						WebShellSettings["consoleSupport"] = true
					}
				}

				if ((String(CommandLine.arguments[i])) == "-dump-args") {
					self._debugDumpArguments("" as AnyObject)
				}

				if ((String(CommandLine.arguments[i])) == "-url") {
					WebShellSettings["url"] = String(CommandLine.arguments[i + 1])
				}

				if ((String(CommandLine.arguments[i])) == "-height") {
					WebShellSettings["initialWindowHeight"] = (Int(CommandLine.arguments[i + 1]) > 250) ? Int(CommandLine.arguments[i + 1]) : Int(250)
				}

				if ((String(CommandLine.arguments[i])) == "-width") {
					WebShellSettings["initialWindowWidth"] = (Int(CommandLine.arguments[i + 1]) > 250) ? Int(CommandLine.arguments[i + 1]) : Int(250)
				}
			}
		}

		initWindow()
	}

	// Edit contextmenu...
	@nonobjc func webView(_ sender: WebView!, contextMenuItemsForElement element: [NSObject: Any]!, defaultMenuItems: [Any]!) -> [Any]! {
		// @wdg Fix contextmenu (problem with the swift 2 update #50)
		// Issue: #51
		var download = false

		for i in defaultMenuItems {
			// Oh! download link available!
			if (String(describing: (i as AnyObject).title).contains("Download")) {
				download = true
			}

			// Get inspect element!
            if (String(describing: (i as AnyObject).title).contains("Element")) {
				for x in 0 ..< defaultMenuItems.count {
					if (String(describing: defaultMenuItems[x]).contains("Element")) {
						IElement = defaultMenuItems[x] as! NSMenuItem
					}
				}
			}
		}

		var NewMenu: [AnyObject] = [AnyObject]()
		let contextMenu = WebShellSettings["Contextmenu"] as! [String: Bool]

		// if can back
		if (contextMenu["BackAndForward"]!) {
			if (mainWebview.canGoBack) {
				NewMenu.append(NSMenuItem.init(title: "Back", action: #selector(ViewController._goBack(_:)), keyEquivalent: ""))
			}
			if (mainWebview.canGoForward) {
				NewMenu.append(NSMenuItem.init(title: "Forward", action: #selector(ViewController._goForward(_:)), keyEquivalent: ""))
			}
		}
		if (contextMenu["Reload"]!) {
			NewMenu.append(NSMenuItem.init(title: "Reload", action: #selector(ViewController._reloadPage(_:)), keyEquivalent: ""))
		}

		if (download) {
//			if (element["WebElementLinkURL"] != nil) {
//				lastURL = element["WebElementLinkURL"]! as! URL

//				if ((contextMenu as [String])["Download"]! || contextMenu["newWindow"]!) {
//					NewMenu.append(NSMenuItem.separator())

//					if (contextMenu["newWindow"]!) {
//						NewMenu.append(NSMenuItem.init(title: "Open Link in a new Window", action: #selector(ViewController.createNewInstance(_:)), keyEquivalent: ""))
//					}
//					if (contextMenu["Download"]!) {
//						NewMenu.append(NSMenuItem.init(title: "Download Linked File", action: #selector(ViewController.downloadFileWithURL(_:)), keyEquivalent: ""))
//					}
//				}
//			}
            //TODO: FIX THIS ALSO
		}

		NewMenu.append(NSMenuItem.separator())
		// Add debug menu. (if enabled)
		if (WebShellSettings["debugmode"] as! Bool) {
			let debugMenu = NSMenu(title: "Debug")
			debugMenu.addItem(IElement)
			debugMenu.addItem(NSMenuItem.init(title: "Open New window", action: #selector(ViewController._debugNewWindow(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Print arguments", action: #selector(ViewController._debugDumpArguments(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Open URL", action: #selector(ViewController._openURL(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Report an issue on this page", action: #selector(ViewController._reportThisPage(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Print this page", action: #selector(ViewController._printThisPage(_:)), keyEquivalent: "")) // Stupid swift 2.2 does not look in extensions.
			debugMenu.addItem(NSMenuItem.separator())
			debugMenu.addItem(NSMenuItem.init(title: "Fire some random Notifications", action: #selector(ViewController.__sendNotifications(_:)), keyEquivalent: ""))
			debugMenu.addItem(NSMenuItem.init(title: "Reset localstorage", action: #selector(ViewController.resetLocalStorage(_:)), keyEquivalent: ""))

			let item = NSMenuItem.init(title: "Debug", action: #selector(ViewController._doNothing(_:)), keyEquivalent: "")
			item.submenu = debugMenu

			NewMenu.append(item)
			NewMenu.append(NSMenuItem.separator())
		}

		NewMenu.append(NSMenuItem.init(title: "Quit", action: #selector(ViewController._quit(_:)), keyEquivalent: ""))

		return NewMenu
	}

	func _quit(_ Sender: AnyObject) -> Void {
		exit(0)
	}

	// Debug: doNothing
	func _doNothing(_ Sender: AnyObject) -> Void {
		// _doNothing
	}

	// Debug: Open new window
	func _debugNewWindow(_ Sender: AnyObject) -> Void {
		openNewWindow(url: "https://www.google.nl/search?client=safari&rls=en&q=new+window&ie=UTF-8&oe=UTF-8&gws_rd=cr&ei=_8eKVs2WFIbFPd7Sr_gN", height: "0", width: "0")
	}

	// Debug: Print arguments
	func _debugDumpArguments(_ Sender: AnyObject) -> Void {
		print(CommandLine.arguments)
	}

	// Debug: Send notifications (10)
	func __sendNotifications(_ Sender: AnyObject) -> Void {
		// Minimize app
		NSApplication.shared().keyWindow?.miniaturize(self)

		// Fire 10 Notifications
		Timer.scheduledTimer(timeInterval: TimeInterval(05), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(15), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(25), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(35), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(45), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(55), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(65), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(75), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(85), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
		Timer.scheduledTimer(timeInterval: TimeInterval(95), target: self, selector: #selector(ViewController.___sendNotifications), userInfo: nil, repeats: false)
	}

	// Debug: Send notifications (10): Real sending.
	func ___sendNotifications() -> Void {
		// Minimize app
		if (NSApplication.shared().keyWindow?.isMiniaturized == false) {
			NSApplication.shared().keyWindow?.miniaturize(self)
		}

		// Send Actual notification.
		makeNotification("Test Notification", message: "Hi!", icon: "https://camo.githubusercontent.com/ee999b2d8fa5413229fdc69e0b53144f02b7b840/687474703a2f2f376d6e6f79372e636f6d312e7a302e676c622e636c6f7564646e2e636f6d2f7765627368656c6c2f6c6f676f2e706e673f696d616765566965772f322f772f313238")
	}

	func _openURL(_ Sender: AnyObject) -> Void {
		let msg = NSAlert()
		msg.addButton(withTitle: "OK") // 1st button
		msg.addButton(withTitle: "Cancel") // 2nd button
		msg.messageText = "URL"
		msg.informativeText = "Where you need to go?"

		let txt = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
		txt.stringValue = "http://"

		msg.accessoryView = txt
		let response: NSModalResponse = msg.runModal()

		if (response == NSAlertFirstButtonReturn) {
			self.loadUrl(txt.stringValue)
		}
	}

	func _reportThisPage(_ Sender: AnyObject) -> Void {
		let currentUrl: String = (mainWebview.mainFrame.dataSource?.request.url?.absoluteString)!
		let host: String = (mainWebview.mainFrame.dataSource?.request.url?.host)!

		let issue: String = String("Problem loading \(host)").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!.replacingOccurrences(of: "&", with: "%26")
		var body: String = (String("There is a problem loading \(currentUrl)").addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)?.replacingOccurrences(of: "&", with: "%26"))!
		body.append("%0D%0AThe%20problem%20is%3A%0D%0A...")

		let url: String = "https://github.com/djyde/WebShell/issues/new?title=\(issue)&body=\(body)"

		NSWorkspace.shared().open(URL(string: (url as String))!)
	}

	// Stupid swift 2.2 & 3 does not look in extensions.
	// so we'll copy again...
	// @wdg Add Print Support
	// Issue: #39
	func _printThisPage(_ Sender: AnyObject? = nil) -> Void {
		let url = mainWebview.mainFrame.dataSource?.request?.url?.absoluteString

		let operation: NSPrintOperation = NSPrintOperation.init(view: mainWebview)
		operation.jobTitle = "Printing \(url!)"

		// If want to print landscape
		operation.printInfo.orientation = NSPaperOrientation.landscape
		operation.printInfo.scalingFactor = 0.7

		if operation.run() {
			print("Printed?")
		}
	}

	func _goBack(_ Sender: AnyObject) -> Void {
		if (mainWebview.canGoBack) {
			mainWebview.goBack(Sender)
		}
	}

	func _goForward(_ Sender: AnyObject) -> Void {
		if (mainWebview.canGoForward) {
			mainWebview.goForward(Sender)
		}
	}

	func _reloadPage(_ Sender: AnyObject) -> Void {
		mainWebview.reload(Sender)
	}

	// Debug: Open new window
	func createNewInstance(_ Sender: AnyObject) -> Void {
		openNewWindow(url: "\(lastURL)", height: "0", width: "0")
	}

	func downloadFileWithURL(_ Sender: AnyObject) -> Void {
		let wsDM = WebShelllDownloadManager.init(url: lastURL)
		wsDM.endDownloadTask()
	}
}
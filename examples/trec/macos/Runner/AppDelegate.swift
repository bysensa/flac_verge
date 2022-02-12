import Cocoa
import FlutterMacOS

@NSApplicationMain
class AppDelegate: FlutterAppDelegate {
    var statusItem: NSStatusItem?
    private var window: MainFlutterWindow?


    lazy var statusBarMenu: NSMenu = {
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open window", action: #selector(presentWindow(_:)), keyEquivalent: "o"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        return menu
    }()

    override func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        statusItem?.button?.title = "Trec"
        statusItem?.menu = statusBarMenu


        let windowSize = NSSize(width: 480, height: 480)
        let screenSize = NSScreen.main?.frame.size ?? .zero
        let rect = NSMakeRect(screenSize.width / 2 - windowSize.width / 2,
                              screenSize.height / 2 - windowSize.height / 2,
                              windowSize.width,
                              windowSize.height)

        window = MainFlutterWindow.init(contentRect: rect,
                                        styleMask: [.miniaturizable, .closable, .resizable, .titled],
                                        backing: .buffered,
                                        defer: true)
        window?.isReleasedWhenClosed = false
        window?.awakeFromNib()
        window?.makeKeyAndOrderFront(nil)
    }

    @objc func presentWindow(_ sender: Any?) {
        if let currenWindow = window {
            currenWindow.makeKeyAndOrderFront(nil)
        }
    }
}

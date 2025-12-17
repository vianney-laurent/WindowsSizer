import Cocoa

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var hotKeyManager: HotKeyManager!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Setup Status Bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            // Using a system symbol for the icon
            button.image = NSImage(systemSymbolName: "macwindow", accessibilityDescription: "Window Sizer")
        }

        setupMenu()

        // Setup Hotkeys
        hotKeyManager = HotKeyManager()
        hotKeyManager.setupConfig()
    }

    func setupMenu() {
        let menu = NSMenu()
        
        let fillItem = NSMenuItem(title: "Fill Screen", action: #selector(fillScreen), keyEquivalent: "f")
        fillItem.keyEquivalentModifierMask = [.command, .option]
        fillItem.target = self
        menu.addItem(fillItem)
        
        let leftItem = NSMenuItem(title: "Left Half", action: #selector(leftHalf), keyEquivalent: "g")
        leftItem.keyEquivalentModifierMask = [.command, .option]
        leftItem.target = self
        menu.addItem(leftItem)

        let rightItem = NSMenuItem(title: "Right Half", action: #selector(rightHalf), keyEquivalent: "d")
        rightItem.keyEquivalentModifierMask = [.command, .option]
        rightItem.target = self
        menu.addItem(rightItem)
        
        menu.addItem(NSMenuItem.separator())
        
        let quitItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
        
        statusItem.menu = menu
    }

    @objc func fillScreen() {
        WindowManager.shared.moveWindow(to: .maximize)
    }
    
    @objc func leftHalf() {
        WindowManager.shared.moveWindow(to: .leftHalf)
    }
    
    @objc func rightHalf() {
        WindowManager.shared.moveWindow(to: .rightHalf)
    }

    @objc func quit() {
        NSApplication.shared.terminate(self)
    }
}

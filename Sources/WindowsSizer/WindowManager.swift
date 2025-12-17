import Cocoa
import ApplicationServices

enum WindowPosition {
    case maximize
    case leftHalf
    case rightHalf
}

class WindowManager {
    static let shared = WindowManager()

    func moveWindow(to position: WindowPosition) {
        // Helper to check for accessibility permissions.
        let options = [kAXTrustedCheckOptionPrompt.takeUnretainedValue() as String: true]
        let accessEnabled = AXIsProcessTrustedWithOptions(options as CFDictionary)

        if !accessEnabled {
            print("Access not enabled. Please enable in System Settings.")
            return
        }

        guard let frontApp = NSWorkspace.shared.frontmostApplication else { return }
        let pid = frontApp.processIdentifier
        let axApp = AXUIElementCreateApplication(pid)

        var focusedWindow: AnyObject?
        let result = AXUIElementCopyAttributeValue(axApp, kAXFocusedWindowAttribute as CFString, &focusedWindow)

        if result == .success, let window = focusedWindow as! AXUIElement? {
            // Get the screen where the window currently is
            guard let screen = getScreen(for: window) else {
                // Fallback to main screen
                if let main = NSScreen.main {
                    apply(position: position, to: window, on: main)
                }
                return
            }
            apply(position: position, to: window, on: screen)
        }
    }
    
    private func getScreen(for window: AXUIElement) -> NSScreen? {
        var positionValue: AnyObject?
        var sizeValue: AnyObject?
        
        AXUIElementCopyAttributeValue(window, kAXPositionAttribute as CFString, &positionValue)
        AXUIElementCopyAttributeValue(window, kAXSizeAttribute as CFString, &sizeValue)
        
        var point = CGPoint.zero
        var size = CGSize.zero
        
        if let pos = positionValue as! AXValue? { AXValueGetValue(pos, .cgPoint, &point) }
        if let sz = sizeValue as! AXValue? { AXValueGetValue(sz, .cgSize, &size) }
        
        let windowFrame = CGRect(origin: point, size: size)
        
        // Find the screen that contains the center of the window
        let center = CGPoint(x: windowFrame.midX, y: windowFrame.midY)
        
        for screen in NSScreen.screens {
            if screen.frame.contains(center) {
                return screen
            }
        }
        
        // Fallback to the screen mostly overlapping the window
        var maxOverlapArea: CGFloat = 0
        var bestScreen: NSScreen?
        
        for screen in NSScreen.screens {
            let intersection = screen.frame.intersection(windowFrame)
            let area = intersection.width * intersection.height
            if area > maxOverlapArea {
                maxOverlapArea = area
                bestScreen = screen
            }
        }
        
        return bestScreen ?? NSScreen.main
    }

    private func apply(position: WindowPosition, to window: AXUIElement, on screen: NSScreen) {
        let visibleFrame = screen.visibleFrame
        
        var newFrame: CGRect
        
        switch position {
        case .maximize:
            newFrame = visibleFrame
        case .leftHalf:
            newFrame = CGRect(x: visibleFrame.minX, y: visibleFrame.minY, width: visibleFrame.width / 2, height: visibleFrame.height)
        case .rightHalf:
            newFrame = CGRect(x: visibleFrame.minX + visibleFrame.width / 2, y: visibleFrame.minY, width: visibleFrame.width / 2, height: visibleFrame.height)
        }
        
        // Convert Cocoa Coordinates (Bottom-Left origin) to AX Coordinates (Top-Left origin)
        // Global height reference is needed.
        guard let primaryScreen = NSScreen.screens.first else { return }
        let globalHeight = primaryScreen.frame.height
        
        // The Y we want in AX is the distance from the top of the primary screen to the top of our new frame.
        // In Cocoa: top of new frame = newFrame.maxY
        // Distance from top = globalHeight - newFrame.maxY
        let axY = globalHeight - newFrame.maxY
        
        var point = CGPoint(x: newFrame.origin.x, y: axY)
        
        // Set Position
        if let posValue = AXValueCreate(.cgPoint, &point) {
             AXUIElementSetAttributeValue(window, kAXPositionAttribute as CFString, posValue)
        }
        
        // Set Size
        var size = newFrame.size
        if let sizeValue = AXValueCreate(.cgSize, &size) {
            AXUIElementSetAttributeValue(window, kAXSizeAttribute as CFString, sizeValue)
        }
    }
}

import Cocoa
import Carbon

class HotKeyManager {
    // Keep references to prevent deallocation if they were objects, but hotkeys are global refs.
    
    func setupConfig() {
        // Register Event Handler
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        
        InstallEventHandler(GetApplicationEventTarget(), { (nextHandler, theEvent, userData) -> OSStatus in
            var hotKeyID = EventHotKeyID()
            
            let status = GetEventParameter(theEvent,
                                           EventParamName(kEventParamDirectObject),
                                           EventParamType(typeEventHotKeyID),
                                           nil,
                                           MemoryLayout<EventHotKeyID>.size,
                                           nil,
                                           &hotKeyID)
            
            if status == noErr {
                switch hotKeyID.id {
                case 1: WindowManager.shared.moveWindow(to: .maximize)
                case 2: WindowManager.shared.moveWindow(to: .leftHalf)
                case 3: WindowManager.shared.moveWindow(to: .rightHalf)
                default: break
                }
            }
            
            return noErr
        }, 1, &eventType, nil, nil)
        
        // Register HotKeys
        // cmd + option + f (0x03) -> 1
        register(keyCode: kVK_ANSI_F, modifiers: cmdKey | optionKey, id: 1)
        // cmd + option + g (0x05) -> 2
        register(keyCode: kVK_ANSI_G, modifiers: cmdKey | optionKey, id: 2)
        // cmd + option + d (0x02) -> 3
        register(keyCode: kVK_ANSI_D, modifiers: cmdKey | optionKey, id: 3)
    }

    private func register(keyCode: Int, modifiers: Int, id: UInt32) {
        var hotKeyID = EventHotKeyID()
        hotKeyID.signature = OSType(1111) // OSType("sizr")
        hotKeyID.id = id

        var eventHotKeyRef: EventHotKeyRef?
        RegisterEventHotKey(UInt32(keyCode), UInt32(modifiers), hotKeyID, GetApplicationEventTarget(), 0, &eventHotKeyRef)
    }
}

// Helpers for string to OSType
extension String {
    var asUInt32: UInt32 {
        var result: UInt32 = 0
        let data = self.data(using: .macOSRoman) ?? Data()
        for i in 0..<min(data.count, 4) {
            result = (result << 8) + UInt32(data[i])
        }
        return result
    }
}

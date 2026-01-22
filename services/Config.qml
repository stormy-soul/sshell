pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    property string filePath: Qt.resolvedUrl("../config.jsonc").toString().replace("file://", "")
    property bool ready: false
    
    // Parsed config data
    property var parsedConfig: ({})
    
    property FileView configFile: FileView {
        path: root.filePath

        Component.onCompleted: {
            console.log("Loading config from:", root.filePath)
            
            Qt.callLater(function() {
                if (text && text.length > 0) {
                    try {
                        let cleanJson = text.replace(/\/\*[\s\S]*?\*\/|\/\/.*/g, '')
                        root.parsedConfig = JSON.parse(cleanJson)
                        root.ready = true
                        console.log("✓ Config loaded successfully!")
                        console.log("  Accent color:", root.parsedConfig.theme?.accentColor)
                        console.log("  Bar left modules:", root.parsedConfig.bar?.left?.length || 0)
                    } catch (e) {
                        console.error("✗ Failed to parse config:", e)
                        root.ready = true
                    }
                } else {
                    console.warn("⚠ Config file is empty, using defaults")
                    root.ready = true
                }
            })
        }
        
        onTextChanged: {
            if (!text || text.length === 0 || root.ready) return

            try {
                let cleanJson = text.replace(/\/\*[\s\S]*?\*\/|\/\/.*/g, '')
                root.parsedConfig = JSON.parse(cleanJson)
                root.ready = true
                console.log("✓ Config loaded via onTextChanged!")
            } catch (e) {
                console.error("✗ Failed to parse config:", e)
            }
        }
    }
    
    // Bar configuration
    property QtObject bar: QtObject {
        property bool enabled: root.parsedConfig.bar?.enabled ?? true
        property string position: root.parsedConfig.bar?.position ?? "top"
        property int height: root.parsedConfig.bar?.height ?? 40
        property int margin: root.parsedConfig.bar?.margin ?? 10
        property int padding: root.parsedConfig.bar?.padding ?? 5
        
        property var left: root.parsedConfig.bar?.left ?? [
            { "module": "Workspaces", "enabled": true },
            { "module": "Launcher", "enabled": true }
        ]
        property var center: root.parsedConfig.bar?.center ?? [
            { "module": "Clock", "enabled": true }
        ]
        property var right: root.parsedConfig.bar?.right ?? []
    }
    
    // Control Center configuration  
    property QtObject controlCenter: QtObject {
        property bool enabled: root.parsedConfig.controlCenter?.enabled ?? true
        property int width: root.parsedConfig.controlCenter?.width ?? 400
        property string position: root.parsedConfig.controlCenter?.position ?? "right"
    }
    
    // Notifications configuration
    property QtObject notifications: QtObject {
        property bool enabled: root.parsedConfig.notifications?.enabled ?? true
        property string position: root.parsedConfig.notifications?.position ?? "top-right"
        property int maxNotifications: root.parsedConfig.notifications?.maxNotifications ?? 5
        property int timeout: root.parsedConfig.notifications?.timeout ?? 5000
    }
    
    // Launcher configuration
    property QtObject launcher: QtObject {
        property bool enabled: root.parsedConfig.launcher?.enabled ?? true
        property int width: root.parsedConfig.launcher?.width ?? 600
        property int height: root.parsedConfig.launcher?.height ?? 500
        property bool fuzzy: root.parsedConfig.launcher?.fuzzy ?? true
    }
    
    // Theme configuration
    property QtObject theme: QtObject {
        property string accentColor: root.parsedConfig.theme?.accentColor ?? "#a6e3a1"
        property int cornerRadius: root.parsedConfig.theme?.cornerRadius ?? 10
        property int animationDuration: root.parsedConfig.theme?.animationDuration ?? 200
        property bool useSystemTheme: root.parsedConfig.theme?.useSystemTheme ?? true
    }
}
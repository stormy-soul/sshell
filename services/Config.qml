pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root
    
    property alias options: configAdapter
    property alias bar: configAdapter.bar
    property alias controlCenter: configAdapter.controlCenter
    property alias notifications: configAdapter.notifications
    property alias launcher: configAdapter.launcher
    property alias theme: configAdapter.theme
    
    property string filePath: Qt.resolvedUrl("../config.jsonc").toString().replace("file://", "")
    property bool ready: false
    
    property FileView configFile: FileView {
        path: root.filePath

        onTextChanged: {
            if (!text || text.length === 0)
                return

            try {
                let cleanJson = text.replace(/\/\*[\s\S]*?\*\/|\/\/.*/g, '')
                adapter.data = JSON.parse(cleanJson)
                root.ready = true
                configAdapter.refresh()
                console.log("✓ Config file loaded from:", root.filePath)
            } catch (e) {
                console.error("✗ Failed to parse config:", e)
            }
        }

        Component.onCompleted: {
            console.log("Loading config from:", root.filePath)
        }
    }

    
    property JsonAdapter configAdapter: JsonAdapter {
        id: configAdapter
        
        // Default Values
        property JsonObject bar: JsonObject {
            property bool enabled: true
            property string position: "top"
            property int height: 40
            property int margin: 10
            property int padding: 5
            
            property var left: [
                { "module": "Workspaces", "enabled": true }
            ]
            property var center: [
                { "module": "Clock", "enabled": true }
            ]
            property var right: [
                { "module": "SystemTray", "enabled": true },
                { "module": "Battery", "enabled": true }
            ]
        }
        
        property JsonObject controlCenter: JsonObject {
            property bool enabled: true
            property int width: 400
            property string position: "right"
        }
        
        property JsonObject notifications: JsonObject {
            property bool enabled: true
            property string position: "top-right"
            property int maxNotifications: 5
            property int timeout: 5000
        }
        
        property JsonObject launcher: JsonObject {
            property bool enabled: true
            property int width: 600
            property int height: 500
            property bool fuzzy: true
        }
        
        property JsonObject theme: JsonObject {
            property string accentColor: "#a6e3a1"
            property int cornerRadius: 10
            property int animationDuration: 200
            property bool useSystemTheme: true
        }
    }
}
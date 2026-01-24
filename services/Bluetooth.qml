pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root
    
    readonly property bool enabled: Bluetooth.defaultAdapter?.enabled ?? false
    readonly property bool connected: activeDeviceCount > 0
    
    readonly property int activeDeviceCount: {
        var count = 0
        if (Bluetooth.defaultAdapter) {
            var devices = Bluetooth.defaultAdapter.devices.values
            for (var i = 0; i < devices.length; i++) {
                if (devices[i].connected) count++
            }
        }
        return count
    }
    
    readonly property string firstDeviceName: {
        if (Bluetooth.defaultAdapter) {
            var devices = Bluetooth.defaultAdapter.devices.values
            for (var i = 0; i < devices.length; i++) {
                if (devices[i].connected) return devices[i].name || devices[i].alias || "Device"
            }
        }
        return ""
    }
}

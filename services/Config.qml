pragma Singleton
import QtQuick

QtObject {
    property var bar: ({ "height": 40, "position": "top", "enabled": true })
    property var controlCenter: ({ "width": 400, "position": "right", "enabled": true })
    property var notifications: ({ "position": "top-right", "enabled": true })
    property var launcher: ({ "width": 600, "height": 500, "enabled": true })
    property var theme: ({})
    property bool loaded: false

    function loadConfig(config) {
        if (config.bar) bar = config.bar
        if (config.controlCenter) controlCenter = config.controlCenter
        if (config.notifications) notifications = config.notifications
        if (config.launcher) launcher = config.launcher
        if (config.theme) theme = config.theme
        loaded = true
    }
}
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
    property alias workspaces: configAdapter.workspaces

    property bool ready: false
    property var parsedConfig: ({})
    property string filePath: Qt.resolvedUrl("../config.jsonc")


    property FileView configFile: FileView {
        path: root.filePath

        function getFileText() {
            try {
                if (typeof text === "function") {
                    return text();
                } else {
                    return text;
                }
            } catch (e) {
                console.warn("getFileText(): failed to read text():", e)
                return null;
            }
        }

        function applyToAdapter(adapterObj, src) {
            if (!adapterObj || !src) return;
            for (var key in src) {
                if (!src.hasOwnProperty(key)) continue;
                var val = src[key];

                if (Array.isArray(val) || typeof val !== "object" || val === null) {
                    try {
                        adapterObj[key] = val
                    } catch (e) {
                        console.warn("applyToAdapter(): failed to assign", key, "=", val, ":", e)
                    }
                    continue;
                }

                try {
                    if (typeof adapterObj[key] === "undefined" || adapterObj[key] === null) {
                        adapterObj[key] = {}  
                    }
                } catch (e) {
                    console.warn("applyToAdapter(): couldn't probe/create", key, ":", e)
                }

                try {
                    applyToAdapter(adapterObj[key], val)
                } catch (e) {
                    console.warn("applyToAdapter(): recursion failed for", key, ":", e)
                    try { adapterObj[key] = val } catch(e2) { /* ignore */ }
                }
            }
        }


        function applyText(source) {
            console.log("DEBUG:", source, "filePath ->", root.filePath)
            var fileText = getFileText()

            var defaults = {
                bar: {
                    enabled: true,
                    position: "top",
                    height: 40,
                    margin: 10,
                    padding: 5,
                    left: [ { module: "Workspaces", enabled: true }, { module: "Launcher", enabled: true } ],
                    center: [ { module: "Clock", enabled: true } ],
                    right: []
                },
                controlCenter: { enabled: true, width: 400, position: "right" },
                notifications: { enabled: true, position: "top-right", maxNotifications: 5, timeout: 5000 },
                launcher: { enabled: true, width: 600, height: 500, fuzzy: true, grid: true },
                theme: { accentColor: "#a6e3a1", cornerRadius: 10, animationDuration: 200, useSystemTheme: true }
            }

            function deepMerge(target, source) {
                if (!source) return target;
                for (var key in source) {
                    if (!source.hasOwnProperty(key)) continue;
                    var s = source[key];
                    var t = target[key];

                    if (Array.isArray(s)) {
                        target[key] = s.slice();
                        continue;
                    }

                    if (s && typeof s === "object") {
                        if (!t || typeof t !== "object") target[key] = {};
                        deepMerge(target[key], s);
                        continue;
                    }

                    target[key] = s;
                }
                return target;
            }

            if (!fileText || fileText.length === 0) {
                console.warn("Config file appears empty (or couldn't be read). Applying defaults.")
                root.parsedConfig = {}
                try {
                    configAdapter.data = JSON.parse(JSON.stringify(defaults))
                } catch(e) { console.warn("Failed to set adapter to defaults:", e) }
                root.ready = true
                return
            }

            try {
                var cleanJson = fileText.replace(/\/\*[\s\S]*?\*\//g, '').replace(/\/\/.*$/gm, '')
                var user = JSON.parse(cleanJson)

                var merged = JSON.parse(JSON.stringify(defaults))
                deepMerge(merged, user)

                root.parsedConfig = merged
                try {
                    applyToAdapter(configAdapter, merged)
                } catch(e) {
                    console.warn("Failed to populate JsonAdapter via property assignment:", e)
                }

                root.ready = true
                console.log("Config parsed successfully (from " + source + ")")
            } catch (e) {
                console.error("Failed to parse config (from " + source + "):", e)
                root.parsedConfig = {}
                try { configAdapter.data = JSON.parse(JSON.stringify(defaults)) } catch(e){}
                root.ready = true
            }
        }

        onLoaded: applyText("onLoaded")
        onTextChanged: applyText("onTextChanged")

        onLoadFailed: function(error) {
            console.warn("FileView failed to load config:", error)
            root.parsedConfig = {}
            try { configAdapter.data = {} } catch(e) {}
            root.ready = true
        }

        Component.onCompleted: {
            console.log("FileView component completed; filePath ->", root.filePath)
        }
    }

    property JsonAdapter configAdapter: JsonAdapter {
        id: configAdapter

        property JsonObject bar: JsonObject {
            property bool enabled: true
            property string position: "top"
            property int height: 40
            property int margin: 10
            property int padding: 5
            property var left: [ { "module": "Workspaces", "enabled": true }, { "module": "Launcher", "enabled": true } ]
            property var center: [ { "module": "Clock", "enabled": true } ]
            property var right: []
        }

        property JsonObject workspaces: JsonObject {
            property var persistent: [1, 2, 3, 4, 5] 
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
            property bool grid: true
        }

        property JsonObject theme: JsonObject {
            property string accentColor: "#a6e3a1"
            property int cornerRadius: 10
            property int animationDuration: 200
            property bool useSystemTheme: true
        }
    }

    property QtObject barProxy: QtObject {
        property bool enabled: configAdapter.bar?.enabled ?? true
        property string position: configAdapter.bar?.position ?? "top"
        property int height: configAdapter.bar?.height ?? 40
        property int margin: configAdapter.bar?.margin ?? 10
        property int padding: configAdapter.bar?.padding ?? 5

        property var left: configAdapter.bar?.left ?? [ { module: "Workspaces", enabled: true }, { module: "Launcher", enabled: true } ]
        property var center: configAdapter.bar?.center ?? [ { module: "Clock", enabled: true } ]
        property var right: configAdapter.bar?.right ?? []
    }
}

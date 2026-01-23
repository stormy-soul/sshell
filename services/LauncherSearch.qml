pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    property string query: ""
    
    // Search prefixes
    readonly property string prefixApp: ":"
    readonly property string prefixMath: "="
    
    // Detect current search mode
    readonly property int searchMode: {
        if (query.startsWith(prefixApp)) return 1  // App search
        if (query.startsWith(prefixMath)) return 2 // Math
        return 0 // Default (show apps)
    }
    
    // Clean query (remove prefix)
    readonly property string cleanQuery: {
        if (searchMode === 1) return query.slice(prefixApp.length).trim()
        if (searchMode === 2) return query.slice(prefixMath.length).trim()
        return query.trim()
    }
    
    // Math result
    property string mathResult: ""
    
    // Results list
    property var results: {
        if (query === "") return []
        
        var resultList = []
        
        // Math results (when prefix is = or query starts with number)
        if (searchMode === 2 || /^\d/.test(query)) {
            mathTimer.restart()
            if (mathResult) {
                resultList.push({
                    type: "math",
                    name: mathResult,
                    description: "Math result",
                    icon: "calculate",
                    iconType: "material",
                    execute: function() {
                        Quickshell.clipboardText = mathResult
                    }
                })
            }
        }
        
        // App results
        if (searchMode === 0 || searchMode === 1) {
            var apps = AppSearch.fuzzyQuery(cleanQuery)
            for (var i = 0; i < apps.length; i++) {
                var app = apps[i]
                resultList.push({
                    type: "app",
                    name: app.name,
                    description: app.comment || app.genericName || "",
                    icon: app.icon,
                    iconType: "system",
                    execute: function() {
                        app.execute()
                    }
                })
            }
        }
        
        return resultList
    }
    
    // Math calculation timer (debounce)
    Timer {
        id: mathTimer
        interval: 300
        onTriggered: {
            var expr = cleanQuery
            if (expr) {
                mathProc.running = false
                mathProc.command = ["qalc", "-t", expr]
                mathProc.running = true
            }
        }
    }
    
    // Math calculation process
    Process {
        id: mathProc
        stdout: SplitParser {
            onRead: data => {
                root.mathResult = data.trim()
            }
        }
    }
}

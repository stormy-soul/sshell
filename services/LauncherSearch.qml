pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../components/bar"

Singleton {
    id: root
    
    property string query: ""
    
    readonly property string prefixApp: ":"
    readonly property string prefixMath: "="
    
    readonly property int searchMode: {
        if (query.startsWith(prefixApp)) return 1  // App search
        if (query.startsWith(prefixMath)) return 2 // Math
        if (/^[\d\s\+\-\*\/\(\)\.\^%]+$/.test(query) && /\d/.test(query)) return 2
        return 0 // Default 
    }
    
    readonly property string cleanQuery: {
        if (searchMode === 1 && query.startsWith(prefixApp)) return query.slice(prefixApp.length).trim()
        if (searchMode === 2 && query.startsWith(prefixMath)) return query.slice(prefixMath.length).trim()
        return query.trim()
    }
    
    property string mathResult: ""
    
    property var results: {
        var resultList = []
        
        if (searchMode === 2 && cleanQuery.length > 0) {
            mathTimer.restart()
            if (mathResult && mathResult.length > 0) {
                resultList.push({
                    type: "math",
                    name: mathResult,
                    description: "Math result - click to copy",
                    icon: "calculate",
                    iconType: "material",
                    execute: function() {
                        Quickshell.clipboardText = mathResult
                        console.log("Math result copied:", mathResult)
                    }
                })
            }
        }
        
        if (searchMode === 0 || searchMode === 1) {
            var apps = AppSearch.fuzzyQuery(cleanQuery)
            console.log("LauncherSearch: Got", apps.length, "apps from AppSearch")
            
            for (var i = 0; i < apps.length; i++) {
                var app = apps[i]
                
                var makeExecutor = function(appToRun) {
                    return function() {
                        console.log("Launching app:", appToRun.name, "with exec:", appToRun.exec)
                        if (appToRun && appToRun.execute) {
                            appToRun.execute()
                        }
                        ModuleLoader.launcherVisible = false
                    }
                }
                
                resultList.push({
                    type: "app",
                    name: app.name || "Unknown",
                    description: app.comment || app.description || app.genericName || "",
                    icon: app.icon || "application-x-executable",
                    iconType: "system",
                    execute: makeExecutor(app),
                    active: false
                })
            }
        }
        
        console.log("LauncherSearch: Returning", resultList.length, "total results")
        return resultList
    }
    
    Timer {
        id: mathTimer
        interval: 300
        onTriggered: {
            var expr = cleanQuery
            if (expr && expr.length > 0) {
                console.log("Math: Evaluating:", expr)
                mathProc.running = false
                mathProc.command = ["qalc", "-t", expr]
                mathProc.running = true
            }
        }
    }
    
    Process {
        id: mathProc
        
        property string outputBuffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                mathProc.outputBuffer += data
            }
        }
        
        onExited: {
            if (exitCode === 0) {
                var result = mathProc.outputBuffer.trim()
                console.log("Math: Result:", result)
                root.mathResult = result
            } else {
                console.warn("Math: qalc failed with exit code:", exitCode)
                root.mathResult = ""
            }
            mathProc.outputBuffer = ""
        }
    }
    
    onQueryChanged: {
        console.log("LauncherSearch: Query changed to:", query, "- Mode:", searchMode)
    }
}
pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.SystemTray

Singleton {
    id: root

    property var allApps: []
    
    // Internal property to track updates from DesktopEntries
    property var _sourceApps: Array.from(DesktopEntries.applications.values)
    
    on_SourceAppsChanged: updateTimer.restart()
    
    Timer {
        id: updateTimer
        interval: 100 // Debounce window
        triggeredOnStart: true
        onTriggered: {
            root.allApps = root._sourceApps
            console.log("AppSearch: Loaded/Updated", root.allApps.length, "applications")
        }
    }
    
    Component.onCompleted: {
        // Initial load handled by timer trigger
    }
    
    function fuzzyQuery(searchText) {
        console.log("AppSearch: fuzzyQuery called with:", searchText)
        
        if (!searchText || searchText.length === 0) {
            var sorted = allApps.sort(function(a, b) {
                return a.name.localeCompare(b.name)
            }).slice(0, 50) 
            console.log("AppSearch: Returning", sorted.length, "apps (all)")
            return sorted
        }
        
        var query = searchText.toLowerCase()
        var results = []
        
        for (var i = 0; i < allApps.length; i++) {
            var app = allApps[i]
            var name = app.name.toLowerCase()
            var score = 0
            
            if (name.startsWith(query)) {
                score = 1000
            }
            else if (name.includes(query)) {
                score = 500
            }
            else if (fuzzyMatch(query, name)) {
                score = 100
            }
            
            if (score > 0) {
                results.push({
                    app: app,
                    score: score
                })
            }
        }
        
        results.sort(function(a, b) {
            return b.score - a.score
        })
        
        var finalResults = results.slice(0, 20).map(function(r) {
            return r.app
        })
        console.log("AppSearch: Returning", finalResults.length, "apps for query:", searchText)
        return finalResults
    }
    
    function fuzzyMatch(query, text) {
        var queryIdx = 0
        for (var i = 0; i < text.length && queryIdx < query.length; i++) {
            if (text[i] === query[queryIdx]) {
                queryIdx++
            }
        }
        return queryIdx === query.length
    }
}
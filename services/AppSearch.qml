pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root
    
    // Get all desktop entries from Quickshell
    readonly property var allApps: {
        var apps = []
        // Ensure DesktopEntries is available
        if (typeof DesktopEntries === "undefined") return []
        
        var entries = DesktopEntries.applications
        
        // Convert map values to array
        for (var key in entries) {
            if (entries.hasOwnProperty(key)) {
                apps.push(entries[key])
            }
        }
        
        return apps
    }
    
    // Simple fuzzy search
    function fuzzyQuery(searchText) {
        if (!searchText || searchText.length === 0) {
            // Return all apps sorted by name (Safe Sort)
            return allApps.sort(function(a, b) {
                var nameA = (a.name || "").toLowerCase()
                var nameB = (b.name || "").toLowerCase()
                return nameA.localeCompare(nameB)
            }).slice(0, 50) 
        }
        
        var query = searchText.toLowerCase()
        var results = []
        
        for (var i = 0; i < allApps.length; i++) {
            var app = allApps[i]
            
            // FIX: Safely handle null properties using (val || "")
            var name = (app.name || "").toLowerCase()
            var desc = (app.description || "").toLowerCase()
            var keywords = (app.keywords || []).join(" ").toLowerCase()
            var exec = (app.exec || "").toLowerCase()
            
            var score = 0
            
            // Exact match at start = highest score
            if (name.startsWith(query)) {
                score = 1000
            }
            // Contains query in name = medium score
            else if (name.includes(query)) {
                score = 500
            }
            // Contains query in description/keywords/exec = low score
            else if (desc.includes(query) || keywords.includes(query) || exec.includes(query)) {
                score = 100
            }
            // (Optional) Fuzzy match could go here
            
            if (score > 0) {
                results.push({
                    app: app,
                    score: score
                })
            }
        }
        
        // Sort by score descending
        results.sort(function(a, b) {
            return b.score - a.score
        })
        
        // Return apps (limit to 20 results)
        return results.slice(0, 20).map(function(r) {
            return r.app
        })
    }
}
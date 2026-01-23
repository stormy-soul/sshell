pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Scope {
    id: root

    property ListModel apps: ListModel {}
    property bool loading: false
    property int loadedDirs: 0
    property int totalDirs: 2
    
    readonly property var appDirs: [
        "/usr/share/applications",
        Quickshell.env("HOME") + "/.local/share/applications"
    ]
    
    // Processes to list desktop files
    Variants {
        id: dirListers
        model: root.appDirs
        
        Process {
            id: lister
            property var modelData
            property string dirPath: modelData
            
            command: ["find", dirPath, "-maxdepth", "1", "-name", "*.desktop", "-type", "f"]
            running: false
            
            onExited: function(exitCode, exitStatus) {
                if (exitCode !== 0) {
                    console.warn("AppService: Failed to list apps in", dirPath)
                    return
                }
                
                var output = stdout().trim()
                if (output.length === 0) return
                
                var files = output.split('\n')
                for (var i = 0; i < files.length; i++) {
                    if (files[i].trim().length > 0) {
                        parseDesktopFile(files[i].trim())
                    }
                }
                
                root.loadedDirs++
                if (root.loadedDirs >= root.totalDirs) {
                    sortApps()
                    root.loading = false
                    console.log("AppService: Loaded", root.apps.count, "applications")
                }
            }
        }
    }
    
    Component.onCompleted: {
        loadApps()
    }
    
    // Reload apps (can be called when launcher opens)
    function reload() {
        loadApps()
    }
    
    function loadApps() {
        console.log("AppService: Loading desktop applications...")
        loading = true
        loadedDirs = 0
        apps.clear()
        
        // Trigger all listers
        for (var i = 0; i < dirListers.count; i++) {
            var lister = dirListers.at(i)
            if (lister) {
                lister.running = true
            }
        }
    }
    
    function parseDesktopFile(filePath) {
        var reader = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["cat", "' + filePath + '"]; running: true }',
            root,
            "reader_" + Math.random().toString(36).substr(2, 9)
        )
        
        reader.exited.connect(function(exitCode, exitStatus) {
            if (exitCode === 0) {
                var content = reader.stdout()
                var app = extractDesktopInfo(content, filePath)
                
                if (app && app.name && app.exec && !app.noDisplay && !app.hidden) {
                    apps.append(app)
                }
            }
            reader.destroy()
        })
    }
    
    function extractDesktopInfo(content, filePath) {
        var lines = content.split('\n')
        var inDesktopEntry = false
        var app = {
            name: "",
            icon: "",
            exec: "",
            description: "",
            noDisplay: false,
            hidden: false
        }
        
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            
            if (line === "[Desktop Entry]") {
                inDesktopEntry = true
                continue
            }
            
            if (line.startsWith("[") && line !== "[Desktop Entry]") {
                inDesktopEntry = false
                continue
            }
            
            if (!inDesktopEntry) continue
            
            if (line.startsWith("Name=") && !app.name) {
                app.name = line.substring(5).trim()
            } else if (line.startsWith("Icon=")) {
                var iconValue = line.substring(5).trim()
                app.icon = resolveIconPath(iconValue)
            } else if (line.startsWith("Exec=")) {
                app.exec = line.substring(5).trim()
                // Remove field codes like %F, %U, etc.
                app.exec = app.exec.replace(/%[fFuUdDnNickvm]/g, "").trim()
            } else if (line.startsWith("Comment=") && !app.description) {
                app.description = line.substring(8).trim()
            } else if (line.startsWith("NoDisplay=")) {
                app.noDisplay = line.substring(10).trim().toLowerCase() === "true"
            } else if (line.startsWith("Hidden=")) {
                app.hidden = line.substring(7).trim().toLowerCase() === "true"
            }
        }
        
        return app
    }
    
    function resolveIconPath(iconName) {
        // If already a full path, return it
        if (iconName.startsWith("/")) {
            return "file://" + iconName
        }
        
        // Common icon paths to search
        var iconPaths = [
            "/usr/share/icons/hicolor/scalable/apps/" + iconName + ".svg",
            "/usr/share/icons/hicolor/256x256/apps/" + iconName + ".png",
            "/usr/share/icons/hicolor/128x128/apps/" + iconName + ".png",
            "/usr/share/icons/hicolor/48x48/apps/" + iconName + ".png",
            "/usr/share/pixmaps/" + iconName + ".png",
            "/usr/share/pixmaps/" + iconName + ".svg",
            "/usr/share/pixmaps/" + iconName + ".xpm"
        ]
        
        // Check if icon file exists (we'll return the first common path for now)
        // In a production system, you'd want to actually check file existence
        for (var i = 0; i < iconPaths.length; i++) {
            // For now, return first SVG or PNG path
            if (iconPaths[i].endsWith(".svg") || iconPaths[i].endsWith(".png")) {
                return "file://" + iconPaths[i]
            }
        }
        
        // If not found, return the icon name (might be a theme icon)
        return iconName
    }
    
    function sortApps() {
        // Convert to array, sort, and rebuild model
        var appArray = []
        for (var i = 0; i < apps.count; i++) {
            appArray.push(apps.get(i))
        }
        
        appArray.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })
        
        apps.clear()
        for (var j = 0; j < appArray.length; j++) {
            apps.append(appArray[j])
        }
    }
}

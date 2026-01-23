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
    
    readonly property var appDirs: Directories.appDirs
    
    // Process instances will be created dynamically in loadApps()
    
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
        
        // Create and run a process for each directory
        for (var i = 0; i < appDirs.length; i++) {
            createDirLister(appDirs[i])
        }
    }
    
    function createDirLister(dirPath) {
        console.log("AppService: Scanning directory:", dirPath)
        
        var processQml = 'import QtQuick; import Quickshell.Io; Process { \
            property string dirPath: "' + dirPath + '"; \
            property string outputBuffer: ""; \
            command: ["find", "' + dirPath + '", "-maxdepth", "1", "-name", "*.desktop", "-type", "f"]; \
            running: true; \
            stdout: SplitParser { \
                onRead: data => outputBuffer += data; \
            } \
        }'
        
        var process = Qt.createQmlObject(processQml, root, "lister_" + Math.random().toString(36).substr(2, 9))
        
        process.exited.connect(function(exitCode, exitStatus) {
            if (exitCode !== 0) {
                console.warn("AppService: Failed to list apps in", process.dirPath, "- exit code:", exitCode)
                root.loadedDirs++
                checkCompletion()
                process.destroy()
                return
            }
            
            var output = process.outputBuffer.trim()
            if (!output || output.length === 0) {
                console.log("AppService: No .desktop files found in", process.dirPath)
            } else {
                var files = output.split('\n')
                console.log("AppService: Found", files.length, "desktop files in", process.dirPath)
                for (var i = 0; i < files.length; i++) {
                    if (files[i].trim().length > 0) {
                        parseDesktopFile(files[i].trim())
                    }
                }
            }
            
            root.loadedDirs++
            checkCompletion()
            process.destroy()
        })
    }
    
    function checkCompletion() {
        if (root.loadedDirs >= root.totalDirs) {
            sortApps()
            root.loading = false
            console.log("AppService: Loaded", root.apps.count, "applications")
        }
    }
    
    function parseDesktopFile(filePath) {
        var readerQml = 'import QtQuick; import Quickshell.Io; Process { \
            property string outputBuffer: ""; \
            command: ["cat", "' + filePath + '"]; \
            running: true; \
            stdout: SplitParser { \
                onRead: data => outputBuffer += data; \
            } \
        }'
        
        var reader = Qt.createQmlObject(readerQml, root, "reader_" + Math.random().toString(36).substr(2, 9))
        
        reader.exited.connect(function(exitCode, exitStatus) {
            if (exitCode === 0) {
                var content = reader.outputBuffer
                var app = extractDesktopInfo(content, filePath)
                
                console.log("AppService: Parsed", filePath, "- name:", app.name, "exec:", app.exec, "noDisplay:", app.noDisplay, "hidden:", app.hidden)
                
                if (app && app.name && app.exec && !app.noDisplay && !app.hidden) {
                    apps.append(app)
                    console.log("AppService: Added app:", app.name)
                } else {
                    console.log("AppService: Skipped app:", filePath, "reasons - noName:", !app.name, "noExec:", !app.exec, "noDisplay:", app.noDisplay, "hidden:", app.hidden)
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
        
        // Search in system icon directories from Directories service
        var extensions = [".svg", ".png", ".xpm"]
        
        for (var i = 0; i < Directories.systemIconDirs.length; i++) {
            var dirPath = Directories.systemIconDirs[i]
            for (var j = 0; j < extensions.length; j++) {
                var fullPath = dirPath + iconName + extensions[j]
                // Note: We can't check file existence in QML, so we return the path
                // and let the Icon component handle fallback
                if (extensions[j] === ".svg" || extensions[j] === ".png") {
                    return "file://" + fullPath
                }
            }
        }
        
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

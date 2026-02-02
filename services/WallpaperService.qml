pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../settings"

Singleton {
    id: root

    property ListModel wallpapers: ListModel {}
    property string currentWallpaper: ""
    property bool backgroundVisible: true
    property bool isLoading: false
    
    readonly property string cacheDir: Directories.cacheDir
    readonly property string thumbDir: Directories.thumbDir
    readonly property string configFile: Directories.configFile
    
    signal error(string message)

    function init() {
        Quickshell.execDetached(["mkdir", "-p", thumbDir])
        restore()
        refresh()
    }

    Component.onCompleted: init()

    function refresh() {
        if (root.isLoading) return
        root.isLoading = true
        root.wallpapers.clear()

        const paths = Config.background?.wallpaperPaths || []
        if (paths.length === 0) {
            root.isLoading = false
            return
        }

        const expandedPaths = paths.map(p => p.replace("~", Quickshell.env("HOME")))

        
        let cmd = ["find"]
        cmd = cmd.concat(expandedPaths)
        cmd = cmd.concat(["-type", "f", "\\(", "-iname", "*.jpg", "-o", "-iname", "*.png", "-o", "-iname", "*.jpeg", "-o", "-iname", "*.webp", "\\)"])
        
        var proc = Quickshell.execDetached(cmd)
        
        scanProcess.paths = expandedPaths
        scanProcess.running = true
    }

    Process {
        id: scanProcess
        property var paths: []
        
        command: ["bash", "-c", "find " + paths.map(p => `"${p}"`).join(" ") + " -type f \\( -iname '*.jpg' -o -iname '*.png' -o -iname '*.jpeg' -o -iname '*.webp' \\) 2>/dev/null"]
        
        stdout: SplitParser {
            onRead: data => {
                const lines = data.split("\n")
                for (let i = 0; i < lines.length; i++) {
                    const path = lines[i].trim()
                    if (path.length > 0) {
                        addWallpaper(path)
                    }
                }
            }
        }
        
        onExited: {
            root.isLoading = false
            startThumbnailGeneration()
        }
    }

    function addWallpaper(path) {
        const name = path.split("/").pop()
        
        root.wallpapers.append({
            "path": path,
            "name": name,
            "thumb": "" 
        })
    }

    property int thumbIndex: 0
    Process {
        id: thumbGenProcess
        command: ["bash", "-c", ""]
        
        stdout: StdioCollector {
            onStreamFinished: output => {
                 if (!output) return
                 const thumbPath = output.trim()
                 if (thumbPath) {
                    root.wallpapers.setProperty(root.thumbIndex, "thumb", thumbPath)
                 }
            }
        }
        
        onExited: {
            root.thumbIndex++
            if (root.thumbIndex < root.wallpapers.count) {
                processNextThumb()
            }
        }
    }

    function startThumbnailGeneration() {
        root.thumbIndex = 0
        processNextThumb()
    }

    function processNextThumb() {
        if (root.thumbIndex >= root.wallpapers.count) return
        
        const item = root.wallpapers.get(root.thumbIndex)
        const path = item.path
        
        const script = `
            HASH=$(echo -n "${path}" | md5sum | cut -d' ' -f1)
            THUMB="${root.thumbDir}/$HASH.jpg"
            if [ ! -f "$THUMB" ]; then
                convert "${path}" -resize 400x400^ -gravity center -extent 400x400 "$THUMB"
            fi
            echo "$THUMB"
        `
        
        thumbGenProcess.command = ["bash", "-c", script]
        thumbGenProcess.running = true
    }

    FileView {
        id: configFileView
        path: root.configFile
        
        adapter: JsonAdapter {
            property string currentWallpaper: ""
            property bool backgroundVisible: true
        }
        
        onLoaded: {
            if (configFileView.adapter.currentWallpaper !== "") {
                let exists = false
                try {
                    exists = Quickshell.io ? Quickshell.io.fileExists(configFileView.adapter.currentWallpaper) : true
                } catch(e) {
                    exists = true
                }

                if (exists) {
                    root.currentWallpaper = configFileView.adapter.currentWallpaper
                }
            }
            
            if (configFileView.adapter.backgroundVisible !== undefined) {
                root.backgroundVisible = configFileView.adapter.backgroundVisible
            }
        }
    }
    
    function updateAdapter() {
        configFileView.adapter.currentWallpaper = root.currentWallpaper
        configFileView.adapter.backgroundVisible = root.backgroundVisible
        saveTimer.restart()
    }
    
    Timer {
        id: saveTimer
        interval: 500
        repeat: false
        onTriggered: configFileView.writeAdapter()
    }
    
    onCurrentWallpaperChanged: updateAdapter()
    onBackgroundVisibleChanged: updateAdapter()

    function setWallpaper(path) {
        root.currentWallpaper = path
    }
    
    function toggleVisible() {
        root.backgroundVisible = !root.backgroundVisible
    }

    function readFile(path) {
        const xhr = new XMLHttpRequest()
        xhr.open("GET", "file://" + path, false)
        xhr.send()
        return xhr.responseText
    }

    function restore() {
        try {
            const content = readFile(root.configFile)
            if (!content) return

            const data = JSON.parse(content)
            
            if (data.currentWallpaper) {
                root.currentWallpaper = data.currentWallpaper
                console.log("[WallpaperService] Synchronously restored:", root.currentWallpaper)
            }
            
            if (data.backgroundVisible !== undefined) {
                root.backgroundVisible = data.backgroundVisible
            }
        } catch (e) {
            console.warn("[WallpaperService] Sync restore failed:", e)
        }
    }
}

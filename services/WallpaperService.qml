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
    
    property var extensions: []
    
    readonly property string cacheDir: Directories.cacheDir
    readonly property string thumbDir: Directories.thumbDir
    readonly property string configFile: Directories.configFile
    
    signal error(string message)
    signal captureBackground(string destPath)
    signal timelapseRequested()
    property bool timelapseActive: false

    function init() {
        Quickshell.execDetached(["mkdir", "-p", thumbDir])
        restore()
        refresh()
    }


    Connections {
        target: Config
        function onReadyChanged() {
            if (Config.ready) {
                 refresh()
            }
        }
    }

    Connections {
        target: Config.background
        function onWallpaperPathsChanged() {
            refresh()
        }
    }

    Component.onCompleted: init()

    function refresh() {
        if (root.isLoading) return
        root.isLoading = true
        root.wallpapers.clear()
        root.extensions = []

        const paths = Config.background?.wallpaperPaths || []
        
        if (paths.length === 0) {
            console.warn("WallpaperService: No wallpaper paths configured")
            root.isLoading = false
            return
        }

        const expandedPaths = paths.map(p => p.replace("~", Quickshell.env("HOME")))
        const findCmd = expandedPaths.map(p => `find "${p}" -type f \\( -iname "*.jpg" -o -iname "*.png" -o -iname "*.jpeg" -o -iname "*.webp" -o -iname "*.gif" \\) 2>/dev/null`).join("; ")
        
        scanProcess.command = ["bash", "-c", findCmd]
        scanProcess.running = true
    }

    Process {
        id: scanProcess
        
        property string outputBuffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                scanProcess.outputBuffer += data + "\n"
            }
        }
        
        onExited: (exitCode) => {
            if (exitCode === 0) {
                const lines = scanProcess.outputBuffer.split("\n")
                
                var extSet = new Set()
                
                for (let i = 0; i < lines.length; i++) {
                    const path = lines[i].trim()
                    if (path.length > 0) {
                        addWallpaper(path)
                        
                        const ext = path.split(".").pop().toLowerCase()
                        extSet.add(ext)
                    }
                }
                
                root.extensions = Array.from(extSet).sort()
                root.extensions = Array.from(extSet).sort()
            } else {
                console.error("WallpaperService: Scan failed with exit code:", exitCode)
            }
            
            scanProcess.outputBuffer = ""
            root.isLoading = false
            startThumbnailGeneration()
        }
    }

    function addWallpaper(path) {
        const name = path.split("/").pop()
        const ext = path.split(".").pop().toLowerCase()
        
        root.wallpapers.append({
            "path": path,
            "name": name,
            "extension": ext,
            "thumb": "" 
        })
    }

    property int thumbIndex: 0
    Process {
        id: thumbGenProcess
        
        property string outputBuffer: ""
        
        stdout: SplitParser {
            onRead: data => {
                thumbGenProcess.outputBuffer += data + "\n"
            }
        }

        onExited: (exitCode) => {
            const thumbPath = thumbGenProcess.outputBuffer.trim()
            
            const lines = thumbPath.split("\n")
            const lastLine = lines[lines.length - 1].trim()
            
            if (lastLine && lastLine.startsWith("/")) {
                 root.wallpapers.setProperty(root.thumbIndex, "thumb", lastLine)
            }
            
            thumbGenProcess.outputBuffer = ""
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
        const ext = item.extension
        
        const script = `
            HASH=$(echo -n "${path}" | md5sum | cut -d' ' -f1)
            HASH=$(echo -n "${path}" | md5sum | cut -d' ' -f1)
            THUMB="${root.thumbDir}/$HASH.jpg"
            if [ ! -f "$THUMB" ]; then
                if [ "${ext}" = "gif" ]; then
                    convert "${path}[0]" -resize 400x400^ -gravity center -extent 400x400 "$THUMB" 2>/dev/null || echo ""
                else
                    convert "${path}" -resize 400x400^ -gravity center -extent 400x400 "$THUMB" 2>/dev/null || echo ""
                fi
            fi
            [ -f "$THUMB" ] && echo "$THUMB"
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
                root.currentWallpaper = configFileView.adapter.currentWallpaper
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
    
    onCurrentWallpaperChanged: {
        updateAdapter()
        if (root.currentWallpaper !== "") {
            generateColors(root.currentWallpaper)
            if (Config.background.copyAfter) persistWallpaper(root.currentWallpaper)
        }
    }
    onBackgroundVisibleChanged: updateAdapter()

    function persistWallpaper(path) {
        if (Config.background.wallpaperMode === "shader") {
            var destDir = (Config.background.copyAfterTo || "").replace("~", Quickshell.env("HOME"))
            var destFile = destDir + (Config.background.copyAfterAs || "default.png")
            Quickshell.execDetached(["bash", "-c", `mkdir -p "${destDir}"`])
            root.captureBackground(destFile)
            return
        }
        var absPath = path.replace("~", Quickshell.env("HOME"))
        var destDir2 = (Config.background.copyAfterTo || "").replace("~", Quickshell.env("HOME"))
        var destFile2 = destDir2 + (Config.background.copyAfterAs || "default.png")
        
        var cmd = `mkdir -p "${destDir2}" && cp -f "${absPath}" "${destFile2}"`
        Quickshell.execDetached(["bash", "-c", cmd])
    }

    function generateColors(path) {
        const absPath = path.replace("~", Quickshell.env("HOME"))
        
        const scriptPath = Directories.scriptsDir + "/generate_colors.sh"
        const cmd = `bash "${scriptPath}" "${absPath}" "${Directories.generatedMaterialThemePath}"`
        
        console.log("WallpaperService: Generating colors from: " + absPath + " into: " + Directories.generatedMaterialThemePath)
        console.log("WallpaperService: Using script:", scriptPath)
        matugenProcess.command = ["bash", "-c", cmd]
        matugenProcess.running = true
    }

    Process {
        id: matugenProcess
        
        property string errorBuffer: ""
        
        stderr: SplitParser {
            onRead: data => {
                 matugenProcess.errorBuffer += data + "\n"
                 console.error("WallpaperService: Matugen stderr:", data)
            }
        }

        onExited: (code) => {
            if (code !== 0) {
                console.error("WallpaperService: Matugen failed with code", code)
                console.error("WallpaperService: Matugen error output:\n", matugenProcess.errorBuffer)
            } else {
                console.log("WallpaperService: Colors generated successfully.")
            }
            matugenProcess.errorBuffer = ""
        }
    }

    function setWallpaper(path) {
        if (Config.background.wallpaperMode === "shader") {
            Config.background.wallpaperMode = "image"
        }
        root.currentWallpaper = path
    }
    
    function toggleVisible() {
        root.backgroundVisible = !root.backgroundVisible
    }
    
    function randomWallpaper() {
        if (root.wallpapers.count === 0) return
        var idx = Math.floor(Math.random() * root.wallpapers.count)
        if (root.wallpapers.count > 1) {
            var current = root.currentWallpaper
            var attempts = 0
            while (root.wallpapers.get(idx).path === current && attempts < 10) {
                idx = Math.floor(Math.random() * root.wallpapers.count)
                attempts++
            }
        }
        setWallpaper(root.wallpapers.get(idx).path)
    }

    function restore() {
    }
}
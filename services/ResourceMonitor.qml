pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property real cpuUsage: 0
    property string cpuFreq: "0.0 GHz"
    property var cpuHistory: []
    property int historySize: 10
    
    property real ramUsage: 0
    property real ramTotal: 0
    property real ramPercent: 0
    
    property real swapUsage: 0
    property real swapTotal: 0
    property real swapPercent: 0
    
    property var lastCpu: ({user: 0, nice: 0, system: 0, idle: 0})

    property var diskSystem: []
    property var diskUser: []
    property var diskSpecial: []

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: {
            cpuProc.running = true
            memProc.running = true
            freqProc.running = true
        }
    }
    
    function refreshDisks() {
        if (!diskProc.running) diskProc.running = true
    }

    Timer {
        running: true
        repeat: false
        interval: 1000
        onTriggered: refreshDisks()
    }

    Process {
        id: diskProc
        command: ["df", "-k"] // KB blocks
        
        property var accumulatedLines: []
        
        stdout: SplitParser {
            onRead: (data) => {
                diskProc.accumulatedLines.push(data)
            }
        }
        
        onExited: (code, status) => {
            var lines = diskProc.accumulatedLines
            diskProc.accumulatedLines = [] // Reset
            
            var sys = []
            var usr = []
            var spc = []
            
            // i=0 is likely header if output is strictly ordered, but SplitParser might give header as first line.
            for (var i = 0; i < lines.length; i++) {
                var line = lines[i].trim()
                if (line === "" || line.startsWith("Filesystem")) continue
                
                var parts = line.split(/\s+/)
                if (parts.length < 6) continue
                
                var fs = parts[0]
                var total = parseInt(parts[1]) * 1024
                var used = parseInt(parts[2]) * 1024
                var avail = parseInt(parts[3]) * 1024
                var percent = parts[4] 
                var mount = parts[5]
                
                var obj = {
                    bg: fs, 
                    name: fs,
                    mount: mount,
                    total: total,
                    used: used,
                    free: avail,
                    percent: parseInt(percent.replace("%","")) / 100.0,
                    percentText: percent
                }
                
                if (fs === "tmpfs" || fs === "devtmpfs" || fs === "efivarfs" || fs === "none" || fs === "overlay" || fs === "squashfs") {
                        spc.push(obj)
                } else if (mount === "/" || mount.startsWith("/boot") || mount.startsWith("/home") || mount.startsWith("/usr") || mount.startsWith("/var")) {
                        sys.push(obj)
                } else if (mount.startsWith("/run") || mount.startsWith("/sys") || mount.startsWith("/dev")) {
                        spc.push(obj)
                } else {
                        usr.push(obj)
                }
            }
            
            root.diskSystem = sys
            root.diskSpecial = spc
            root.diskUser = usr
            
            // console.log("Disks Parsed - Sys: " + sys.length + " User: " + usr.length + " Special: " + spc.length)
        }
    }

    Process {
        id: freqProc
        command: ["cat", "/proc/cpuinfo"]
        stdout: SplitParser {
            onRead: (data) => {
                var lines = data.split("\n")
                // Just grab the first core for now or average? First core is simplest.
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line.startsWith("cpu MHz")) {
                        var parts = line.split(":")
                        if (parts.length > 1) {
                            var mhz = parseFloat(parts[1])
                            root.cpuFreq = (mhz / 1000).toFixed(2) + " GHz"
                            return // Done
                        }
                    }
                }
            }
        }
    }

    Process {
        id: cpuProc
        command: ["cat", "/proc/stat"]
        stdout: SplitParser {
            onRead: (data) => {
                var lines = data.split("\n")
                if (lines.length > 0 && lines[0].startsWith("cpu ")) {
                    var parts = lines[0].split(/\s+/)
                    // parts[0] is "cpu", parts[1] is user, ...
                    var user = parseInt(parts[1])
                    var nice = parseInt(parts[2])
                    var system = parseInt(parts[3])
                    var idle = parseInt(parts[4])
                    
                    var total = user + nice + system + idle
                    var active = user + nice + system
                    
                    var prevTotal = root.lastCpu.user + root.lastCpu.nice + root.lastCpu.system + root.lastCpu.idle
                    var prevActive = root.lastCpu.user + root.lastCpu.nice + root.lastCpu.system
                    
                    var totalDelta = total - prevTotal
                    var activeDelta = active - prevActive
                    
                    var usage = 0
                    if (totalDelta > 0) {
                        usage = activeDelta / totalDelta
                    }
                    
                    root.cpuUsage = usage
                    
                    var h = []
                    if (root.cpuHistory) {
                        for(var i=0; i<root.cpuHistory.length; i++) h.push(root.cpuHistory[i])
                    }
                    h.push(usage)
                    if (h.length > root.historySize) h.shift()
                    root.cpuHistory = h
                    
                    root.lastCpu = {user: user, nice: nice, system: system, idle: idle}
                }
            }
        }
    }

    Process {
        id: memProc
        command: ["cat", "/proc/meminfo"]
        stdout: SplitParser {
            onRead: (data) => {
                var lines = data.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var line = lines[i].trim()
                    if (line === "") continue
                    
                    var parts = line.split(/\s+/)
                    if (parts.length < 2) continue
                    
                    var key = parts[0]
                    var value = parseInt(parts[1]) // usually kB
                    
                    if (key === "MemTotal:") {
                        root.ramTotal = value * 1024
                    } else if (key === "MemAvailable:") {
                         if (root.ramTotal > 0) {
                             var avail = value * 1024
                             root.ramUsage = root.ramTotal - avail
                             root.ramPercent = root.ramUsage / root.ramTotal
                         }
                    } else if (key === "SwapTotal:") {
                        root.swapTotal = value * 1024
                    } else if (key === "SwapFree:") {
                        if (root.swapTotal > 0) {
                            var free = value * 1024
                            root.swapUsage = root.swapTotal - free
                            root.swapPercent = root.swapUsage / root.swapTotal
                        } else {
                            // Ensure 0 if no swap
                            root.swapUsage = 0
                            root.swapPercent = 0
                        }
                    }
                }
            }
        }
    }
    
    Component.onCompleted: {
        cpuProc.running = true
        memProc.running = true
    }
}

pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../settings"

Singleton {
    id: root
    
    // Interval in ms (Config has seconds)
    readonly property int fetchInterval: (Config.options.weather.interval || 3600) * 1000
    readonly property string city: Config.options.weather.city || ""
    readonly property string unit: Config.options.weather.unit || "metric"
    readonly property bool useUSCS: Config.options.weather.useUSCS || false // or derive from unit
    readonly property bool gpsActive: Config.options.weather.enableGPS || false
    
    // Data property to hold current weather info
    property var data: ({
        temp: "--",
        tempFeelsLike: "--",
        iconCode: "113", // Default sunny/clear
        condition: "",
        city: "",
        isValid: false
    })
    
    function refineData(jsonData) {
        var temp = {}
        var current = jsonData.current_condition ? jsonData.current_condition[0] : null
        var area = jsonData.nearest_area ? jsonData.nearest_area[0] : null
        
        if (!current) {
            console.warn("WeatherService: Invalid data structure")
            return
        }
        
        // Temperature
        if (root.unit === "imperial" || root.useUSCS) {
            temp.temp = (current.temp_F || "--") + "°F"
            temp.tempFeelsLike = (current.FeelsLikeF || "--") + "°F"
        } else {
            temp.temp = (current.temp_C || "--") + "°C"
            temp.tempFeelsLike = (current.FeelsLikeC || "--") + "°C"
        }
        
        temp.iconCode = current.weatherCode || "113"
        temp.condition = current.weatherDesc ? current.weatherDesc[0].value : ""
        temp.city = area && area.areaName ? area.areaName[0].value : (root.city || "Unknown")
        temp.isValid = true
        
        root.data = temp
        console.log("WeatherService: Updated weather for " + temp.city + ": " + temp.temp)
    }
    
    function getData() {
        var cmd = "curl -s 'wttr.in"
        
        // If GPS active (not implemented yet, placeholder path)
        // For now just use city or auto (empty)
        if (root.city) {
            cmd += "/" + formatCityName(root.city)
        }
        
        // Format J1 for JSON
        cmd += "?format=j1'"
        
        fetchProc.command = ["bash", "-c", cmd]
        fetchProc.running = true
    }
    
    function formatCityName(name) {
        return name.trim().split(/\s+/).join('+')
    }
    
    Process {
        id: fetchProc
        
        stdout: SplitParser {
            onRead: data => {
                // Buffer logic might be needed if output splits JSON?
                // SplitParser usually splits by lines. Curl output might be one line or formatted.
                // REF used StdioCollector which collects all.
                // I should use StdioCollector too if available in Quickshell, via property 'stdout'.
                // Quickshell's Process stdout can be string or object.
                // Ref used: stdout: StdioCollector { ... }
                // I don't see StdioCollector in the project imports I've seen so far.
                // Wait, REF had `import Quickshell.Io`.
                // Let's check if StdioCollector works, or accumulate manually.
                
                // Accumulate manually to be safe if StdioCollector isn't standard in this version.
                // Actually REF uses it so it likely exists.
            }
        }
    }
    
    // Accumulator for process output
    property string outputBuffer: ""
    
    Process {
        id: curlProc
        command: ["bash", "-c", "curl -s 'wttr.in/" + (root.city ? formatCityName(root.city) : "") + "?format=j1'"]
        
        stdout: SplitParser {
            onRead: data => {
                root.outputBuffer += data
            }
        }
        
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0 && root.outputBuffer.length > 0) {
                try {
                    var json = JSON.parse(root.outputBuffer)
                    root.refineData(json)
                } catch (e) {
                    console.error("WeatherService: Failed to parse JSON", e)
                }
            }
            root.outputBuffer = ""
        }
    }
    
    Timer {
        interval: root.fetchInterval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            root.outputBuffer = ""
            curlProc.running = true
        }
    }
    
    Component.onCompleted: {
        // Initial fetch handled by Timer triggeredOnStart
    }
}

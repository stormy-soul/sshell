pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import "../settings"

Singleton {
    id: root
    
    readonly property int fetchInterval: (Config.options.weather.interval || 3600) * 1000
    readonly property string city: Config.options.weather.city || ""
    readonly property string unit: Config.options.weather.unit || "metric"
    readonly property bool useUSCS: Config.options.weather.useUSCS || false
    readonly property bool gpsActive: Config.options.weather.enableGPS || false
    
    property var data: ({
        temp: "--",
        tempFeelsLike: "--",
        iconCode: "113",
        condition: "",
        city: "",
        location: "",
        humidity: 0,
        precipitation: 0,
        windSpeed: "--",
        windDir: "",
        sunrise: "--:--",
        sunset: "--:--",
        forecast: [],
        isValid: false
    })
    
    function refineData(jsonData) {
        var temp = {}
        var current = jsonData.current_condition ? jsonData.current_condition[0] : null
        var area = jsonData.nearest_area ? jsonData.nearest_area[0] : null
        var weather = jsonData.weather || []
        
        if (!current) {
            console.warn("WeatherService: Invalid data structure")
            return
        }
        
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
        
        var region = area && area.region ? area.region[0].value : ""
        temp.location = region ? (temp.city + ", " + region) : temp.city
        
        temp.humidity = parseInt(current.humidity) || 0
        temp.precipitation = parseFloat(current.precipMM) || 0
        
        if (root.unit === "imperial" || root.useUSCS) {
            temp.windSpeed = (current.windspeedMiles || "--") + " mph"
        } else {
            temp.windSpeed = (current.windspeedKmph || "--") + " km/h"
        }
        temp.windDir = current.winddir16Point || ""
        
        if (weather.length > 0 && weather[0].astronomy && weather[0].astronomy.length > 0) {
            var astro = weather[0].astronomy[0]
            temp.sunrise = astro.sunrise || "--:--"
            temp.sunset = astro.sunset || "--:--"
        } else {
            temp.sunrise = "--:--"
            temp.sunset = "--:--"
        }
        
        temp.forecast = []
        var days = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        for (var i = 0; i < Math.min(weather.length, 3); i++) {
            var day = weather[i]
            var dateObj = new Date(day.date)
            var dayName = days[dateObj.getDay()]
            
            var high, low
            if (root.unit === "imperial" || root.useUSCS) {
                high = day.maxtempF + "°"
                low = day.mintempF + "°"
            } else {
                high = day.maxtempC + "°"
                low = day.mintempC + "°"
            }
            
            var iconCode = "113"
            if (day.hourly && day.hourly.length > 0) {
                var noonHour = day.hourly.find(h => h.time === "1200") || day.hourly[Math.floor(day.hourly.length / 2)]
                iconCode = noonHour.weatherCode || "113"
            }
            
            temp.forecast.push({
                date: day.date,
                day: dayName,
                high: high,
                low: low,
                iconCode: iconCode,
                isToday: i === 0
            })
        }
        
        temp.isValid = true
        root.data = temp
        console.log("WeatherService: Updated weather for " + temp.city + ": " + temp.temp)
    }
    
    function getData() {
        if (updateProc.running) return
        
        root.outputBuffer = ""
        var cmd = "curl -m 10 -s 'wttr.in/" + (root.city ? formatCityName(root.city) : "") + "?format=j1'"
        updateProc.command = ["bash", "-c", cmd]
        updateProc.running = true
        console.log("WeatherService: Fetching data...")
    }
    
    function formatCityName(name) {
        return name.trim().split(/\s+/).join('+')
    }
    
    property string outputBuffer: ""
    
    Process {
        id: updateProc
        
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
                    console.error("Buffer was:", root.outputBuffer)
                }
            } else {
                 console.error("WeatherService: Fetch failed with code", exitCode)
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
            root.getData()
        }
    }
}

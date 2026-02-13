import QtQuick
import Quickshell
import Quickshell.Io
import "../../services"
import "../../settings"

Rectangle {
    id: root
    anchors.fill: parent

    property real debugTimeOverride: -1.0
    property string debugWeatherOverride: ""  // "clear", "cloudy", "fog", "rain", "snow", "storm"

    property real timeNormalized: 0.0
    property string currentPeriod: ""

    readonly property string weatherCondition: {
        if (debugWeatherOverride !== "") return debugWeatherOverride
        var c = String(Weather.data.iconCode || "113")
        if (c === "113") return "clear"
        if (c === "116" || c === "119" || c === "122") return "cloudy"
        if (c === "143" || c === "248" || c === "260") return "fog"
        if (["227","230","323","326","329","332","335","338","368","371","395"].includes(c)) return "snow"
        if (["200","386","389","392"].includes(c)) return "storm"
        if (["176","263","266","293","296","299","302","305","308","311","314","317","320","350","353","356","359","362","365","374","377"].includes(c)) return "rain"
        return "clear"
    }

    readonly property real weatherCloudDensity: {
        switch (weatherCondition) {
            case "clear": return 0.25
            case "cloudy": return 2.0
            case "fog": return 2.5
            case "rain": return 2.5
            case "snow": return 2.0
            case "storm": return 3.0
            default: return 1.0
        }
    }

    readonly property real celestialDimming: {
        switch (weatherCondition) {
            case "cloudy": return 0.5
            case "fog": return 0.2
            case "rain": return 0.3
            case "snow": return 0.4
            case "storm": return 0.1
            default: return 1.0
        }
    }

    visible: Config.background.wallpaperMode === "shader" && !HyprlandService.isFullscreen

    Timer {
        id: timeUpdater
        interval: 300000 // 5 minutes
        running: root.visible && !root.paused
        repeat: true
        triggeredOnStart: true
        onTriggered: root.updateTime()
    }

    // Parse "06:30 AM" or "18:30" to normalized 0-1 day fraction
    function parseTimeToNormalized(tStr) {
        if (!tStr || tStr === "--:--") return -1
        var parts = tStr.match(/(\d+):(\d+)\s*(AM|PM)?/i)
        if (!parts) return -1
        var h = parseInt(parts[1])
        var m = parseInt(parts[2])
        if (parts[3]) {
            if (parts[3].toUpperCase() === "PM" && h !== 12) h += 12
            if (parts[3].toUpperCase() === "AM" && h === 12) h = 0
        }
        return (h * 60 + m) / 1440.0
    }

    readonly property real sunRiseNorm: {
        var v = parseTimeToNormalized(Weather.data.sunrise)
        return v >= 0 ? v : 0.25 // or 06:00
    }
    readonly property real sunSetNorm: {
        var v = parseTimeToNormalized(Weather.data.sunset)
        return v >= 0 ? v : 0.792 // or 19:00
    }

    readonly property real dawnStart: Math.max(0, sunRiseNorm - 1.0/24.0)
    readonly property real morningStart: sunRiseNorm + 1.0/24.0
    readonly property real eveningStart: sunSetNorm - 2.0/24.0
    readonly property real nightStart: sunSetNorm + 1.0/24.0

    function updateTime() {
        if (debugTimeOverride >= 0.0) {
            timeNormalized = debugTimeOverride
        } else {
            var d = Clock.now
            var mins = d.getHours() * 60 + d.getMinutes()
            timeNormalized = mins / 1440.0
        }
    }

    function getPeriodName(t) {
        if (t < dawnStart) return "night"
        if (t < morningStart) return "dawn"
        if (t < 0.500) return "morning"
        if (t < eveningStart) return "afternoon"
        if (t < nightStart) return "evening"
        return "night"
    }

    onTimeNormalizedChanged: {
        var newPeriod = getPeriodName(timeNormalized)
        if (newPeriod !== currentPeriod) {
            currentPeriod = newPeriod
        }
    }

    onCurrentPeriodChanged: {
        if (currentPeriod !== "" && visible) {
            generateSkyColors()
        }
    }

    onVisibleChanged: {
        if (visible && currentPeriod !== "") {
            generateSkyColors()
        }
    }

    function colorToHex(c) {
        function toHex(v) {
            var h = Math.round(v * 255).toString(16)
            return h.length < 2 ? "0" + h : h
        }
        return "#" + toHex(c.r) + toHex(c.g) + toHex(c.b)
    }

    function generateSkyColors() {
        var zenith = getZenithColor()
        var horizon = getHorizonColor()
        var zenithHex = colorToHex(zenith)
        var horizonHex = colorToHex(horizon)

        var outPath = Directories.cacheDir + "/shader_bg.png"

        var cmd = 'mkdir -p "' + Directories.cacheDir + '" && convert -size 100x200 gradient:"' + zenithHex + '"-"' + horizonHex + '" "' + outPath + '"'

        if (Config.background.copyAfter && Config.background.copyAfterTo && Config.background.copyAfterAs) {
            var destDir = String(Config.background.copyAfterTo).replace("~", Quickshell.env("HOME"))
            var destFile = destDir + Config.background.copyAfterAs
            cmd += ' && mkdir -p "' + destDir + '" && cp -f "' + outPath + '" "' + destFile + '"'
        }

        colorGenProcess.outputPath = outPath
        colorGenProcess.command = ["bash", "-c", cmd]
        colorGenProcess.running = true
    }

    Process {
        id: colorGenProcess

        property string outputPath: ""

        onExited: (exitCode) => {
            if (exitCode === 0 && outputPath !== "") {
                WallpaperService.generateColors(outputPath)
            } else {
                console.warn("ProceduralSky: Failed to generate gradient image, exit code:", exitCode)
            }
        }
    }

    // -1 = midnight, 0 = horizon (sunrise/sunset), 1 = solar noon
    readonly property real sunElevation: {
        var t = timeNormalized
        var dayLen = sunSetNorm - sunRiseNorm
        if (dayLen <= 0) return -1

        if (t >= sunRiseNorm && t <= sunSetNorm) {
            var dayProgress = (t - sunRiseNorm) / dayLen
            return Math.sin(dayProgress * Math.PI)
        } else {
            var nightLen = 1.0 - dayLen
            var nightProgress
            if (t > sunSetNorm)
                nightProgress = (t - sunSetNorm) / nightLen
            else
                nightProgress = (t + 1.0 - sunSetNorm) / nightLen
            return -Math.sin(nightProgress * Math.PI)
        }
    }

    readonly property bool isRising: timeNormalized < (sunRiseNorm + sunSetNorm) / 2

    // Color key points
    readonly property var nightZenith:     Qt.rgba(0.043, 0.063, 0.149, 1) // #0B1026
    readonly property var nightHorizon:    Qt.rgba(0.106, 0.141, 0.220, 1) // #1B2438

    readonly property var twilightZenith:  Qt.rgba(0.188, 0.235, 0.463, 1) // #303C76
    readonly property var dawnHorizon:     Qt.rgba(0.918, 0.557, 0.333, 1) // warm orange
    readonly property var duskHorizon:     Qt.rgba(0.918, 0.412, 0.216, 1) // deeper orange

    readonly property var dayZenith:       Qt.rgba(0.290, 0.565, 0.886, 1) // #4A90E2
    readonly property var dayHorizon:      Qt.rgba(0.541, 0.765, 0.949, 1) // #8AC3F2

    function smoothStep(f) {
        return f * f * (3.0 - 2.0 * f)
    }

    function lerpColor(a, b, f) {
        return Qt.rgba(
            a.r + (b.r - a.r) * f,
            a.g + (b.g - a.g) * f,
            a.b + (b.b - a.b) * f,
            1.0
        )
    }

    function getZenithColor() {
        var elev = sunElevation

        if (elev <= -0.3) {
            return nightZenith
        } else if (elev <= 0.0) {
            var f = smoothStep((elev + 0.3) / 0.3)
            return lerpColor(nightZenith, twilightZenith, f)
        } else if (elev <= 0.7) {
            var f = smoothStep(elev / 0.7)
            return lerpColor(twilightZenith, dayZenith, f)
        } else {
            return dayZenith
        }
    }

    function getHorizonColor() {
        var elev = sunElevation
        var warmHorizon = isRising ? dawnHorizon : duskHorizon

        if (elev <= -0.3) {
            return nightHorizon
        } else if (elev <= 0.0) {
            var f = smoothStep((elev + 0.3) / 0.3)
            return lerpColor(nightHorizon, warmHorizon, f)
        } else if (elev <= 0.5) {
            var f = smoothStep(elev / 0.5)
            return lerpColor(warmHorizon, dayHorizon, f)
        } else {
            return dayHorizon
        }
    }

    gradient: Gradient {
        GradientStop {
            position: 0.0
            color: root.getZenithColor()
            Behavior on color { ColorAnimation { duration: 2000 } }
        }
        GradientStop {
            position: 0.4
            color: {
                var z = root.getZenithColor()
                var h = root.getHorizonColor()
                return root.lerpColor(z, h, 0.3)
            }
            Behavior on color { ColorAnimation { duration: 2000 } }
        }
        GradientStop {
            position: 0.75
            color: {
                var z = root.getZenithColor()
                var h = root.getHorizonColor()
                return root.lerpColor(z, h, 0.7)
            }
            Behavior on color { ColorAnimation { duration: 2000 } }
        }
        GradientStop {
            position: 1.0
            color: root.getHorizonColor()
            Behavior on color { ColorAnimation { duration: 2000 } }
        }
    }

    Rectangle {
        id: weatherTint
        anchors.fill: parent
        visible: opacity > 0

        gradient: Gradient {
            GradientStop {
                position: 0.0
                color: {
                    switch (root.weatherCondition) {
                        case "rain":   return "#3A4555"  // dark blue-gray
                        case "snow":   return "#5A6570"  // cool gray
                        case "storm":  return "#1E2530"  // very dark
                        case "fog":    return "#6B6B6B"  // warm gray
                        case "cloudy": return "#55606B"  // light gray-blue
                        default:       return "#000000"
                    }
                }
                Behavior on color { ColorAnimation { duration: 3000 } }
            }
            GradientStop {
                position: 1.0
                color: {
                    switch (root.weatherCondition) {
                        case "rain":   return "#4A5565"
                        case "snow":   return "#7A8590"
                        case "storm":  return "#2A3540"
                        case "fog":    return "#8B8B8B"
                        case "cloudy": return "#6A757F"
                        default:       return "#000000"
                    }
                }
                Behavior on color { ColorAnimation { duration: 3000 } }
            }
        }

        opacity: {
            switch (root.weatherCondition) {
                case "rain":   return 0.45
                case "snow":   return 0.35
                case "storm":  return 0.60
                case "fog":    return 0.40
                case "cloudy": return 0.20
                default:       return 0.0
            }
        }
        Behavior on opacity { NumberAnimation { duration: 3000 } }
    }

    StarField {
        anchors.fill: parent
        timeOfDay: "night"
        condition: root.weatherCondition
        visible: opacity > 0.01
        opacity: {
            // Stars visible when sun is below horizon, fade during twilight
            var elev = root.sunElevation
            var starOp = 0.0
            if (elev <= -0.2) starOp = 1.0
            else if (elev >= 0.05) starOp = 0.0
            else starOp = 1.0 - (elev + 0.2) / 0.25
            return starOp * root.celestialDimming
        }
        Behavior on opacity { NumberAnimation { duration: 2000 } }
    }

    SunArc {
        anchors.fill: parent
        timeNormalized: root.timeNormalized
        opacity: root.celestialDimming
        Behavior on opacity { NumberAnimation { duration: 2000 } }
    }

    CloudLayers {
        anchors.fill: parent
        horizonColor: root.getHorizonColor()
        zenithColor: root.getZenithColor()
        cloudDensity: root.weatherCloudDensity
        windBoost: parseFloat(Weather.data.windSpeed) / 50 || 0
    }

    StormClouds {
        id: stormClouds
        anchors.fill: parent
        horizonColor: root.getHorizonColor()
        condition: root.weatherCondition
        windBoost: parseFloat(Weather.data.windSpeed) / 50 || 0
    }

    MountainLayers {
        anchors.fill: parent
        horizonColor: root.getHorizonColor()
        zenithColor: root.getZenithColor()
    }

    PrecipitationLayer {
        anchors.fill: parent
        condition: root.weatherCondition
        weatherCode: String(Weather.data.iconCode || "113")
    }

    WeatherAtmosphere {
        anchors.fill: parent
        condition: root.weatherCondition
    }

    Rectangle {
        anchors.fill: parent
        color: "#30FFFFCC"
        opacity: stormClouds.boltOpacity * 0.3
        visible: root.weatherCondition === "storm"
    }
}

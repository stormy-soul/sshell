import QtQuick
import QtQuick.Effects
import "../../services"
import "../../settings"

Item {
    id: root
    anchors.fill: parent

    property real timeNormalized: 0.0  // 0..1 full day

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

    readonly property real sunRise: {
        var v = parseTimeToNormalized(Weather.data.sunrise)
        return v >= 0 ? v : 0.25 // or 06:00
    }
    readonly property real sunSet: {
        var v = parseTimeToNormalized(Weather.data.sunset)
        return v >= 0 ? v : 0.792 // or 19:00
    }

    readonly property bool isSunPhase: timeNormalized >= sunRise && timeNormalized <= sunSet
    readonly property bool isMoonPhase: !isSunPhase

    readonly property real arcProgress: {
        if (isSunPhase) {
            return (timeNormalized - sunRise) / (sunSet - sunRise)
        } else {
            // Moon: 19:00→05:00 mapped to 0→1
            // Night spans 0.792→1.0 and 0.0→0.208 (total = 0.416)
            var nightDuration = 1.0 - sunSet + sunRise // 0.416
            var nightTime = timeNormalized >= sunSet
                ? timeNormalized - sunSet
                : timeNormalized + (1.0 - sunSet)
            return nightTime / nightDuration
        }
    }

    readonly property real arcAngle: Math.PI * (1.0 - arcProgress)
    readonly property real arcRadiusX: width * 0.48
    readonly property real arcRadiusY: height * 0.45
    readonly property real arcCenterX: width * 0.5
    readonly property real arcCenterY: height * 0.85

    readonly property real bodyX: arcCenterX + arcRadiusX * Math.cos(arcAngle) - body.width / 2
    readonly property real bodyY: arcCenterY - arcRadiusY * Math.sin(arcAngle) - body.height / 2

    function getBodyColor() {
        if (isMoonPhase) return "#E0E0E0"           // moon silver
        if (arcProgress < 0.15) return "#FF8C42"    // sunrise orange
        if (arcProgress < 0.3)  return "#FFB84D"    // morning warm
        if (arcProgress < 0.7)  return "#FFE082"    // midday bright
        if (arcProgress < 0.85) return "#FFB84D"    // afternoon warm
        return "#FF8C42"                            // sunset orange
    }

    function getBodyOpacity() {
        var op = isMoonPhase ? 0.7 : 0.9
        if (arcProgress < 0.1) return arcProgress / 0.1 * op
        if (arcProgress > 0.9) return (1.0 - arcProgress) / 0.1 * op
        return op
    }

    function getBodySize() {
        var base = isMoonPhase ? 60 : 80
        var extra = isMoonPhase ? 20 : 40
        // Slightly larger near horizon for atmospheric effect y'know
        var distFromCenter = Math.abs(arcProgress - 0.5) * 2
        return base + distFromCenter * extra
    }

    function getBlurAmount() {
        return isMoonPhase ? 0.4 : 0.6
    }

    Rectangle {
        id: body
        width: root.getBodySize()
        height: width
        radius: width / 2
        color: root.getBodyColor()
        opacity: root.getBodyOpacity()

        x: root.bodyX
        y: root.bodyY

        Behavior on x {
            enabled: !phaseTracker.phaseJustChanged
            NumberAnimation { duration: 1000 }
        }
        Behavior on y {
            enabled: !phaseTracker.phaseJustChanged
            NumberAnimation { duration: 1000 }
        }
        Behavior on color { ColorAnimation { duration: 2000 } }
        Behavior on opacity { NumberAnimation { duration: 1000 } }

        layer.enabled: true
        layer.effect: MultiEffect {
            blurEnabled: true
            blurMax: 32
            blur: root.getBlurAmount()
        }
    }

    // Disable position animation briefly on phase change to prevent reverse travel
    QtObject {
        id: phaseTracker
        property bool phaseJustChanged: false
        property bool lastPhase: root.isSunPhase
    }

    onIsSunPhaseChanged: {
        phaseTracker.phaseJustChanged = true
        phaseResetTimer.restart()
    }

    Timer {
        id: phaseResetTimer
        interval: 50
        onTriggered: phaseTracker.phaseJustChanged = false
    }
}

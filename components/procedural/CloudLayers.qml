import QtQuick
import "../../settings"

Canvas {
    id: root
    anchors.fill: parent

    property color horizonColor: "#8AC3F2"
    property color zenithColor: "#4A90E2"
    property real seed: 42.0
    property real cloudDensity: 1.0
    property real windSpeed: 0.3
    property real windBoost: 0.0
    property bool paused: false

    property real xOffset: 0.0
    property real _pendingDensity: cloudDensity

    onHorizonColorChanged: requestPaint()
    onZenithColorChanged: requestPaint()
    onWidthChanged: { generateClouds(); requestPaint() }
    onHeightChanged: { generateClouds(); requestPaint() }
    onCloudDensityChanged: {
        if (cloudData.length > 0) {
            _pendingDensity = cloudDensity
            fadeOut.start()
        } else {
            generateClouds()
            requestPaint()
        }
    }

    Behavior on opacity { NumberAnimation { id: fadeAnim; duration: 800 } }

    SequentialAnimation {
        id: fadeOut
        NumberAnimation { target: root; property: "opacity"; to: 0; duration: 800 }
        ScriptAction { script: { root.generateClouds(); root.requestPaint() } }
        NumberAnimation { target: root; property: "opacity"; to: 1; duration: 800 }
    }

    Timer {
        id: driftTimer
        interval: 80
        running: root.visible && root.width > 0 && !root.paused
        repeat: true
        onTriggered: {
            root.xOffset += (root.windSpeed + root.windBoost)
            root.requestPaint()
        }
    }

    function seededRandom(s) {
        var x = Math.sin(s * 127.1 + 311.7) * 43758.5453
        return x - Math.floor(x)
    }

    property var cloudData: []

    function generateCloudProfile(s, cloudW, cloudH, bumpCount) {
        var halfW = cloudW / 2
        var step = 8
        var points = []

        var h1Freq = bumpCount * Math.PI / cloudW
        var h1Phase = seededRandom(s + 10.0) * 6.28
        var h1Amp = 0.6 + seededRandom(s + 11.0) * 0.4

        var h2Freq = h1Freq * (1.8 + seededRandom(s + 12.0) * 0.8)
        var h2Phase = seededRandom(s + 13.0) * 6.28
        var h2Amp = 0.15 + seededRandom(s + 14.0) * 0.15

        var h3Freq = h1Freq * (3.0 + seededRandom(s + 15.0) * 1.5)
        var h3Phase = seededRandom(s + 16.0) * 6.28
        var h3Amp = 0.05 + seededRandom(s + 17.0) * 0.08

        for (var px = -halfW; px <= halfW; px += step) {
            var t = px / halfW  // -1 to 1

            var bodyEnv = Math.cos(t * Math.PI / 2)
            bodyEnv = Math.max(0, Math.sqrt(bodyEnv))

            var bumpEnv = 1.0 - t * t
            bumpEnv = Math.max(0, bumpEnv * bumpEnv)

            var wave = h1Amp * Math.abs(Math.sin(h1Freq * px + h1Phase))
                     + h2Amp * Math.sin(h2Freq * px + h2Phase)
                     + h3Amp * Math.sin(h3Freq * px + h3Phase)

            var profileY = cloudH * 0.6 * bodyEnv + wave * cloudH * 0.4 * bumpEnv

            points.push({ px: px, py: profileY })
        }

        return points
    }

    function generateClouds() {
        var w = root.width
        var h = root.height
        if (w <= 0 || h <= 0) return

        var clouds = []
        var count = Math.round(8 * cloudDensity)

        for (var i = 0; i < count; i++) {
            var s = seed + i * 73.37

            var depth = seededRandom(s + 0.1)

            var cx = seededRandom(s + 1.0) * w * 1.5
            var cy = (0.10 + depth * 0.55) * h

            var cloudW = 80 + depth * 120 + seededRandom(s + 5.0) * 60
            var cloudH = 35 + depth * 30

            var bumps = 1 + Math.floor(seededRandom(s + 6.0) * 3)

            var speed = 0.3 + depth * 0.7
            var opacity = 0.15 + depth * 0.30

            var profile = generateCloudProfile(s, cloudW, cloudH, bumps)

            clouds.push({
                cx: cx,
                cy: cy,
                cloudW: cloudW,
                speed: speed,
                opacity: opacity,
                depth: depth,
                profile: profile
            })
        }

        clouds.sort(function(a, b) { return a.depth - b.depth })
        cloudData = clouds
    }

    Component.onCompleted: generateClouds()

    function lerpCol(a, b, f) {
        return Qt.rgba(
            a.r + (b.r - a.r) * f,
            a.g + (b.g - a.g) * f,
            a.b + (b.b - a.b) * f,
            1.0
        )
    }

    function colorToRgba(c, alpha) {
        return "rgba(" + Math.round(c.r * 255) + "," + Math.round(c.g * 255) + "," + Math.round(c.b * 255) + "," + alpha.toFixed(3) + ")"
    }

    onPaint: {
        var ctx = getContext("2d")
        if (!ctx) return

        var w = root.width
        var h = root.height
        if (w <= 0 || h <= 0) return

        ctx.clearRect(0, 0, w, h)

        for (var i = 0; i < cloudData.length; i++) {
            var cloud = cloudData[i]

            var drift = xOffset * cloud.speed
            var wrapW = w + 400

            var cloudWhite = Qt.rgba(1, 1, 1, 1)
            var cloudColor = lerpCol(cloudWhite, horizonColor, cloud.depth * 0.3)

            ctx.fillStyle = colorToRgba(cloudColor, cloud.opacity)
            ctx.beginPath()

            var halfW = cloud.cloudW / 2
            var baseX = ((cloud.cx + drift) % wrapW) - 200
            var baseY = cloud.cy

            ctx.moveTo(baseX - halfW, baseY)

            var pts = cloud.profile
            for (var j = 0; j < pts.length; j++) {
                ctx.lineTo(baseX + pts[j].px, baseY - pts[j].py)
            }

            ctx.lineTo(baseX + halfW, baseY)
            ctx.closePath()
            ctx.fill()
        }
    }
}

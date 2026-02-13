import QtQuick
import "../../settings"

Canvas {
    id: root
    anchors.fill: parent

    property color horizonColor: "#8AC3F2"
    property string condition: "clear"
    property real seed: 77.0
    property real windSpeed: 0.3
    property real windBoost: 0.0

    property real xOffset: 0.0

    visible: condition === "rain" || condition === "storm"

    onHorizonColorChanged: requestPaint()
    onConditionChanged: { generateClouds(); requestPaint() }
    onWidthChanged: { generateClouds(); requestPaint() }
    onHeightChanged: { generateClouds(); requestPaint() }

    Timer {
        id: driftTimer
        interval: 80
        running: root.visible && root.width > 0
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

    // Lightning state
    property var activeBolt: null
    property real boltProgress: 0.0
    property real boltOpacity: 0.0
    property real flashOpacity: 0.0

    onBoltProgressChanged: requestPaint()
    onBoltOpacityChanged: requestPaint()

    function generateCloudProfile(s, cloudW, cloudH, bumpCount) {
        var halfW = cloudW / 2
        var step = 8
        var points = []

        var h1Freq = bumpCount * Math.PI / cloudW
        var h1Phase = seededRandom(s + 10.0) * 6.28
        var h1Amp = 0.5 + seededRandom(s + 11.0) * 0.3

        var h2Freq = h1Freq * (1.5 + seededRandom(s + 12.0) * 0.6)
        var h2Phase = seededRandom(s + 13.0) * 6.28
        var h2Amp = 0.1 + seededRandom(s + 14.0) * 0.1

        for (var px = -halfW; px <= halfW; px += step) {
            var t = px / halfW

            var bodyEnv = Math.cos(t * Math.PI / 2)
            bodyEnv = Math.max(0, Math.sqrt(bodyEnv))

            var bumpEnv = 1.0 - t * t
            bumpEnv = Math.max(0, bumpEnv * bumpEnv)

            var wave = h1Amp * Math.abs(Math.sin(h1Freq * px + h1Phase))
                     + h2Amp * Math.sin(h2Freq * px + h2Phase)

            var profileY = cloudH * 0.7 * bodyEnv + wave * cloudH * 0.3 * bumpEnv

            points.push({ px: px, py: profileY })
        }

        return points
    }

    function generateClouds() {
        var w = root.width
        var h = root.height
        if (w <= 0 || h <= 0) return

        var clouds = []
        var count = condition === "storm" ? 4 : 2

        for (var i = 0; i < count; i++) {
            var s = seed + i * 91.13

            // Spread evenly across the screen
            var segment = w / count
            var cx = segment * i + seededRandom(s + 1.0) * segment

            var cy = (0.40 + seededRandom(s + 2.0) * 0.25) * h

            var cloudW = 200 + seededRandom(s + 3.0) * 180
            var cloudH = 50 + seededRandom(s + 4.0) * 40

            var bumps = 2 + Math.floor(seededRandom(s + 5.0) * 2)
            var speed = 0.15 + seededRandom(s + 6.0) * 0.2

            var profile = generateCloudProfile(s, cloudW, cloudH, bumps)

            clouds.push({
                cx: cx,
                cy: cy,
                cloudW: cloudW,
                cloudH: cloudH,
                speed: speed,
                profile: profile
            })
        }

        cloudData = clouds
    }

    Component.onCompleted: generateClouds()

    function generateBolt(cloud, drift) {
        var w = root.width
        var h = root.height
        var wrapW = w + 500

        var baseX = ((cloud.cx + drift) % wrapW) - 250
        var baseY = cloud.cy + 5

        var points = []
        points.push({ x: baseX, y: baseY })

        var segments = 6 + Math.floor(Math.random() * 5)
        var targetY = h * 0.95
        var yStep = (targetY - baseY) / segments

        var currentX = baseX
        var currentY = baseY

        for (var i = 0; i < segments; i++) {
            var jitterRange = 50 * (1.0 - i / segments)
            currentX += (Math.random() - 0.5) * jitterRange
            currentY += yStep * (0.6 + Math.random() * 0.8)

            points.push({ x: currentX, y: Math.min(currentY, targetY) })

            if (i < segments - 2 && Math.random() < 0.2) {
                var branchLen = 2 + Math.floor(Math.random() * 2)
                var bx = currentX
                var by = currentY
                var branchPoints = []
                for (var b = 0; b < branchLen; b++) {
                    bx += (Math.random() - 0.5) * 30
                    by += yStep * 0.4
                    branchPoints.push({ x: bx, y: by })
                }
                points[points.length - 1].branch = branchPoints
            }
        }

        return points
    }

    function triggerLightning() {
        if (cloudData.length === 0) return
        if (boltAnim.running) return

        var idx = Math.floor(Math.random() * cloudData.length)
        var cloud = cloudData[idx]
        var drift = xOffset * cloud.speed

        activeBolt = generateBolt(cloud, drift)
        boltOpacity = 0.7
        boltProgress = 0.0
        flashOpacity = 0.0

        // Randomize the flash pattern
        var r = Math.random()
        var flashCount = 1
        if (r > 0.4) flashCount = 2
        if (r > 0.8) flashCount = 3
        flashIterator.flashesRemaining = flashCount

        boltAnim.start()
    }

    SequentialAnimation {
        id: boltAnim
        NumberAnimation { target: root; property: "boltProgress"; from: 0; to: 1; duration: 120; easing.type: Easing.OutQuad }
        ScriptAction { script: flashIterator.start() }
        PauseAnimation { duration: 100 }
        NumberAnimation { target: root; property: "boltOpacity"; to: 0; duration: 300; easing.type: Easing.InQuad }
        ScriptAction { script: root.activeBolt = null }
    }

    Timer {
        id: flashIterator
        property int flashesRemaining: 0
        repeat: false

        onTriggered: {
            singleFlash.stop()
            singleFlash.start()

            flashesRemaining--
            if (flashesRemaining > 0) {
                interval = Math.random() * 200 + 40
                start()
            }
        }
    }

    SequentialAnimation {
        id: singleFlash
        NumberAnimation { target: root; property: "flashOpacity"; to: 0.15; duration: 30 }
        NumberAnimation { target: root; property: "flashOpacity"; to: 0.0; duration: 100; easing.type: Easing.InQuad }
    }

    Timer {
        id: lightningTimer
        interval: 4000
        running: root.visible && root.condition === "storm" && !root.paused
        repeat: true
        onTriggered: {
            interval = Math.random() * 10000 + 4000
            if (Math.random() > 0.35) root.triggerLightning()
        }
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
        ctx.shadowBlur = 0
        ctx.shadowColor = "transparent"

        var wrapW = w + 500

        for (var i = 0; i < cloudData.length; i++) {
            var cloud = cloudData[i]
            var drift = xOffset * cloud.speed
            var halfW = cloud.cloudW / 2
            var baseX = ((cloud.cx + drift) % wrapW) - 250
            var baseY = cloud.cy

            var cloudColor = colorToRgba(Qt.darker(horizonColor, 2.5), 0.65)

            ctx.fillStyle = cloudColor
            ctx.beginPath()
            ctx.moveTo(baseX - halfW, baseY)

            var pts = cloud.profile
            for (var j = 0; j < pts.length; j++) {
                ctx.lineTo(baseX + pts[j].px, baseY - pts[j].py)
            }

            ctx.lineTo(baseX + halfW, baseY)
            ctx.closePath()
            ctx.fill()
        }

        if (activeBolt && boltOpacity > 0) {
            var bolt = activeBolt
            var visibleCount = Math.floor(bolt.length * boltProgress)

            if (visibleCount < 2) return

            ctx.strokeStyle = "rgba(230,230,200," + (boltOpacity * 0.7).toFixed(2) + ")"
            ctx.lineWidth = 1.5
            ctx.shadowColor = "rgba(200,200,150," + (boltOpacity * 0.3).toFixed(2) + ")"
            ctx.shadowBlur = 6
            ctx.beginPath()
            ctx.moveTo(bolt[0].x, bolt[0].y)
            for (var k = 1; k < visibleCount; k++) {
                ctx.lineTo(bolt[k].x, bolt[k].y)
            }
            ctx.stroke()

            ctx.lineWidth = 0.8
            ctx.shadowBlur = 3
            ctx.strokeStyle = "rgba(220,220,180," + (boltOpacity * 0.4).toFixed(2) + ")"
            for (var m = 0; m < visibleCount; m++) {
                if (bolt[m].branch) {
                    ctx.beginPath()
                    ctx.moveTo(bolt[m].x, bolt[m].y)
                    var br = bolt[m].branch
                    for (var n = 0; n < br.length; n++) {
                        ctx.lineTo(br[n].x, br[n].y)
                    }
                    ctx.stroke()
                }
            }

            ctx.shadowBlur = 0
            ctx.shadowColor = "transparent"
        }
    }
}

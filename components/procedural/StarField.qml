import QtQuick

Item {
    id: root
    anchors.fill: parent
    
    property string timeOfDay: "night"
    property string condition: "clear"
    property real shootingStarChance: 0.15  // chance per check (0-1)
    
    visible: timeOfDay === "night" && (condition === "clear" || condition === "cloudy")
    opacity: condition === "cloudy" ? 0.3 : 1.0

    Repeater {
        model: 60
        Rectangle {
            property real size: Math.random() * 2 + 1
            width: size
            height: size
            radius: size / 2
            color: "#FFFFFF"
            x: Math.random() * root.width
            y: Math.random() * root.height * 0.7 
            opacity: Math.random() * 0.7 + 0.3
            
            SequentialAnimation on opacity {
                loops: Animation.Infinite
                running: true
                NumberAnimation { to: 0.2; duration: Math.random() * 2000 + 1000 }
                NumberAnimation { to: 1.0; duration: Math.random() * 2000 + 1000 }
            }
        }
    }

    Canvas {
        id: shootingCanvas
        anchors.fill: parent
        visible: shootingStar.active

        onPaint: {
            var ctx = getContext("2d")
            if (!ctx) return
            ctx.clearRect(0, 0, width, height)

            if (!shootingStar.active) return

            var progress = shootingStar.progress
            var sx = shootingStar.startX
            var sy = shootingStar.startY
            var ex = shootingStar.endX
            var ey = shootingStar.endY

            var headX = sx + (ex - sx) * progress
            var headY = sy + (ey - sy) * progress

            var tailLen = Math.sin(progress * Math.PI) * shootingStar.maxTailLen

            var dx = ex - sx
            var dy = ey - sy
            var dist = Math.sqrt(dx * dx + dy * dy)
            if (dist < 1) return
            var nx = dx / dist
            var ny = dy / dist

            var tailX = headX - nx * tailLen
            var tailY = headY - ny * tailLen

            var alpha = 1.0
            if (progress < 0.1) alpha = progress / 0.1
            if (progress > 0.7) alpha = (1.0 - progress) / 0.3

            var grad = ctx.createLinearGradient(tailX, tailY, headX, headY)
            grad.addColorStop(0, "rgba(255,255,255,0)")
            grad.addColorStop(0.7, "rgba(255,255,255," + (alpha * 0.4).toFixed(2) + ")")
            grad.addColorStop(1, "rgba(255,255,255," + (alpha * 0.9).toFixed(2) + ")")

            ctx.beginPath()
            ctx.moveTo(tailX, tailY)
            ctx.lineTo(headX, headY)
            ctx.strokeStyle = grad
            ctx.lineWidth = 1.5
            ctx.stroke()

            // Draw bright head
            ctx.beginPath()
            ctx.arc(headX, headY, 2, 0, 2 * Math.PI)
            ctx.fillStyle = "rgba(255,255,255," + (alpha * 0.95).toFixed(2) + ")"
            ctx.fill()
        }
    }

    QtObject {
        id: shootingStar
        property bool active: false
        property real progress: 0.0
        property real startX: 0
        property real startY: 0
        property real endX: 0
        property real endY: 0
        property real maxTailLen: 80

        onProgressChanged: shootingCanvas.requestPaint()
    }

    NumberAnimation {
        id: shootingAnim
        target: shootingStar
        property: "progress"
        from: 0.0
        to: 1.0
        duration: 800 + Math.random() * 600
        easing.type: Easing.OutQuad
        onRunningChanged: {
            if (!running) {
                shootingStar.active = false
                shootingCanvas.requestPaint()
            }
        }
    }

    Timer {
        id: shootingTimer
        interval: 3000
        running: root.visible && root.opacity > 0 && !root.paused
        repeat: true
        onTriggered: {
            if (shootingStar.active) return
            if (Math.random() > root.shootingStarChance) return

            launchShootingStar()
        }
    }

    function launchShootingStar() {
        var w = root.width
        var h = root.height * 0.6 // keep in upper sky

        shootingStar.startX = Math.random() * w * 0.8 + w * 0.1
        shootingStar.startY = Math.random() * h * 0.5 + h * 0.05

        var angle = Math.PI * 0.15 + Math.random() * Math.PI * 0.2 // 27°-63° downward
        var travelDist = 150 + Math.random() * 200
        shootingStar.endX = shootingStar.startX + Math.cos(angle) * travelDist
        shootingStar.endY = shootingStar.startY + Math.sin(angle) * travelDist

        shootingStar.maxTailLen = travelDist * 0.4
        shootingStar.progress = 0
        shootingStar.active = true

        shootingAnim.duration = 600 + Math.random() * 800
        shootingAnim.start()
    }
}

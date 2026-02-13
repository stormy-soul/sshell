import QtQuick
import "../../settings"

Canvas {
    id: root
    anchors.fill: parent

    property color horizonColor: "#8AC3F2"
    property color zenithColor: "#4A90E2"

    property real seed: 42.0
    property real peakDensity: 1.5
    property real ruggedness: 0.07 // 0.0 = smooth, 1.0 = very jagged

    onHorizonColorChanged: requestPaint()
    onZenithColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPeakDensityChanged: requestPaint()
    onRuggednessChanged: requestPaint()

    function seededRandom(s) {
        var x = Math.sin(s * 127.1 + 311.7) * 43758.5453
        return x - Math.floor(x)
    }

    function mountainProfile(x, layerSeed, f1, f2, f3) {
        var p1 = seededRandom(layerSeed + 1.0) * 6.28
        var p2 = seededRandom(layerSeed + 2.0) * 6.28
        var p3 = seededRandom(layerSeed + 3.0) * 6.28
        var p4 = seededRandom(layerSeed + 4.0) * 6.28
        var p5 = seededRandom(layerSeed + 5.0) * 6.28

        // Base shape
        var y = 0.60 * Math.sin(f1 * x + p1)
        
        // Mid-freq: blend between smooth sin and ridged abs(sin)
        var smooth2 = Math.sin(f2 * x + p2)
        var rigid2 = 1.0 - 2.0 * Math.abs(Math.sin(f2 * x + p2))
        y += 0.25 * (smooth2 * (1.0 - ruggedness) + rigid2 * ruggedness)
        
        // High-freq rocky noise: amplitude scales with ruggedness + blends smooth/ridged
        var noiseAmp = 0.05 + 0.10 * ruggedness
        
        var smooth3 = Math.sin(f3 * x + p3)
        var rigid3 = 1.0 - 2.0 * Math.abs(Math.sin(f3 * 2.5 * x + p4))
        
        y += noiseAmp * (smooth3 * (1.0 - ruggedness) + rigid3 * ruggedness)

        // Extra rocky detail only if ruggedness > 0.0
        if (ruggedness > 0.0) {
             y += 0.05 * ruggedness * Math.sin(f3 * 6.0 * x + p5)
        }

        return y
    }

    // Lerp between two colors
    function lerpCol(a, b, f) {
        return Qt.rgba(
            a.r + (b.r - a.r) * f,
            a.g + (b.g - a.g) * f,
            a.b + (b.b - a.b) * f,
            1.0
        )
    }

    function colorToStr(c) {
        function h(v) {
            var s = Math.round(v * 255).toString(16)
            return s.length < 2 ? "0" + s : s
        }
        return "#" + h(c.r) + h(c.g) + h(c.b)
    }

    // Layer definitions: [fogAmount, baseY, amplitude, freq1, freq2, freq3]
    // fogAmount: 0 = pure black, 1 = full horizon color
    // baseY: vertical position (0 = top, 1 = bottom)
    // amplitude: height of peaks relative to canvas height
    readonly property var layers: [
        { fog: 0.85, baseY: 0.65, amp: 0.05, f1: 0.002, f2: 0.005, f3: 0.012, seedOffset: -100.0 },
        { fog: 0.65, baseY: 0.70, amp: 0.08, f1: 0.003, f2: 0.007, f3: 0.015, seedOffset: 0.0 },
        { fog: 0.45, baseY: 0.76, amp: 0.12, f1: 0.002, f2: 0.005, f3: 0.012, seedOffset: 100.0 },
        { fog: 0.25, baseY: 0.84, amp: 0.16, f1: 0.0015, f2: 0.004, f3: 0.010, seedOffset: 200.0 },
    ]

    onPaint: {
        var ctx = getContext("2d")
        if (!ctx) return

        var w = root.width
        var h = root.height
        if (w <= 0 || h <= 0) return

        ctx.clearRect(0, 0, w, h)

        for (var i = 0; i < layers.length; i++) {
            var layer = layers[i]
            var layerSeed = seed + layer.seedOffset

            var mountainBase = Qt.rgba(0, 0, 0, 1)
            var foggedColor = lerpCol(mountainBase, horizonColor, layer.fog)

            ctx.beginPath()

            ctx.moveTo(0, h)

            var step = 3
            for (var x = 0; x <= w; x += step) {
                var profile = mountainProfile(x, layerSeed, layer.f1 * peakDensity, layer.f2 * peakDensity, layer.f3 * peakDensity)
                var y = (layer.baseY - layer.amp * profile) * h
                if (x === 0) {
                    ctx.lineTo(0, y)
                } else {
                    ctx.lineTo(x, y)
                }
            }
            ctx.lineTo(w, (layer.baseY - layer.amp * mountainProfile(w, layerSeed, layer.f1 * peakDensity, layer.f2 * peakDensity, layer.f3 * peakDensity)) * h)

            ctx.lineTo(w, h)
            ctx.closePath()

            ctx.fillStyle = colorToStr(foggedColor)
            ctx.fill()
        }
    }
}

import QtQuick
import QtQuick.Shapes
import "../../settings"

Item {
    id: root
    property var values: []
    property color color: Appearance.colors.accent
    property color fillColor: Qt.rgba(color.r, color.g, color.b, 0.2)
    
    Shape {
        anchors.fill: parent
        antialiasing: true
        layer.enabled: true
        
        ShapePath {
            id: graphPath
            strokeWidth: 2
            strokeColor: root.color
            fillColor: root.fillColor
            startX: 0
            startY: root.height
            
            PathLine { x: 0; y: root.height }
        }
    }
    
    Canvas {
        id: canvas
        anchors.fill: parent
        
        property var values: root.values
        property color lineColor: root.color
        property color fillColor: root.fillColor
        
        onValuesChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        
        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            
            if (!values || values.length < 2) return
            
            var w = width
            var h = height
            var step = w / (values.length - 1)
            
            var grad = ctx.createLinearGradient(0, 0, 0, h)
            grad.addColorStop(0, root.fillColor)
            grad.addColorStop(1, Qt.rgba(root.fillColor.r, root.fillColor.g, root.fillColor.b, 0.1))
            
            function drawCurve(ctx, vs, width, height) {
                 var step = width / (vs.length - 1)
                 
                 ctx.beginPath()
                 ctx.moveTo(0, height)
                 
                 var firstVal = Math.max(0, Math.min(1, vs[0]))
                 var startY = height - (firstVal * height)
                 ctx.lineTo(0, startY)
                 
                 for (var i = 0; i < vs.length - 1; i++) {
                    var x1 = i * step
                    var val1 = Math.max(0, Math.min(1, vs[i]))
                    var y1 = height - (val1 * height)
                    
                    var x2 = (i + 1) * step
                    var val2 = Math.max(0, Math.min(1, vs[i+1]))
                    var y2 = height - (val2 * height)
                    
                    var mx = (x1 + x2) / 2
                    var my = (y1 + y2) / 2
                    var xc = (x1 + x2) / 2
                    var yc = (y1 + y2) / 2
                    ctx.quadraticCurveTo(x1, y1, xc, yc)
                 }
                 
                 var lastI = vs.length - 1
                 var lastVal = Math.max(0, Math.min(1, vs[lastI]))
                 var lastY = height - (lastVal * height)
                 ctx.lineTo(width, lastY)
                 
                 ctx.lineTo(width, height)
                 ctx.closePath()
            }
            
            drawCurve(ctx, values, w, h)
            ctx.fillStyle = grad
            ctx.fill()
            
            ctx.beginPath()
            
            var val0 = Math.max(0, Math.min(1, values[0]))
            ctx.moveTo(0, h - (val0 * h))
            
            for (var i = 0; i < values.length - 1; i++) {
                var x1 = i * step
                var val1 = Math.max(0, Math.min(1, values[i]))
                var y1 = h - (val1 * h)
                
                var x2 = (i + 1) * step
                var val2 = Math.max(0, Math.min(1, values[i+1]))
                var y2 = h - (val2 * h)
                
                var xc = (x1 + x2) / 2
                var yc = (y1 + y2) / 2
                ctx.quadraticCurveTo(x1, y1, xc, yc)
            }
            var lastVal2 = Math.max(0, Math.min(1, values[values.length-1]))
            ctx.lineTo(w, h - (lastVal2 * h))
            
            ctx.lineWidth = 2
            
            var c = root.color
            if (c) {
                 ctx.strokeStyle = c.toString()
            } else {
                 ctx.strokeStyle = "white"
            }
            ctx.stroke()
        }
    }
}

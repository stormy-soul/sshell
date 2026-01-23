import QtQuick
import "../../assets/shapes/shapes/morph.js" as Morph
import "../../assets/shapes/material-shapes.js" as MaterialShapes

Canvas {
    id: root
    
    enum Shape {
        Circle,
        Square,
        Slanted,
        Arch,
        Fan,
        Arrow,
        SemiCircle,
        Oval,
        Pill,
        Triangle,
        Diamond,
        ClamShell,
        Pentagon,
        Gem,
        Sunny,
        VerySunny,
        Cookie4Sided,
        Cookie6Sided,
        Cookie7Sided,
        Cookie9Sided,
        Cookie12Sided,
        Ghostish,
        Clover4Leaf,
        Clover8Leaf,
        Burst,
        SoftBurst,
        Boom,
        SoftBoom,
        Flower,
        Puffy,
        PuffyDiamond,
        PixelCircle,
        PixelTriangle,
        Bun,
        Heart
    }
    
    property color color: "#685496"
    property int shape: MaterialShape.Shape.Circle
    property double implicitSize: 40
    
    implicitWidth: implicitSize
    implicitHeight: implicitSize
    
    property var roundedPolygon: {
        switch (root.shape) {
            case MaterialShape.Shape.Circle: return MaterialShapes.getCircle();
            case MaterialShape.Shape.Square: return MaterialShapes.getSquare();
            case MaterialShape.Shape.Slanted: return MaterialShapes.getSlanted();
            case MaterialShape.Shape.Arch: return MaterialShapes.getArch();
            case MaterialShape.Shape.Fan: return MaterialShapes.getFan();
            case MaterialShape.Shape.Arrow: return MaterialShapes.getArrow();
            case MaterialShape.Shape.SemiCircle: return MaterialShapes.getSemiCircle();
            case MaterialShape.Shape.Oval: return MaterialShapes.getOval();
            case MaterialShape.Shape.Pill: return MaterialShapes.getPill();
            case MaterialShape.Shape.Triangle: return MaterialShapes.getTriangle();
            case MaterialShape.Shape.Diamond: return MaterialShapes.getDiamond();
            case MaterialShape.Shape.ClamShell: return MaterialShapes.getClamShell();
            case MaterialShape.Shape.Pentagon: return MaterialShapes.getPentagon();
            case MaterialShape.Shape.Gem: return MaterialShapes.getGem();
            case MaterialShape.Shape.Sunny: return MaterialShapes.getSunny();
            case MaterialShape.Shape.VerySunny: return MaterialShapes.getVerySunny();
            case MaterialShape.Shape.Cookie4Sided: return MaterialShapes.getCookie4Sided();
            case MaterialShape.Shape.Cookie6Sided: return MaterialShapes.getCookie6Sided();
            case MaterialShape.Shape.Cookie7Sided: return MaterialShapes.getCookie7Sided();
            case MaterialShape.Shape.Cookie9Sided: return MaterialShapes.getCookie9Sided();
            case MaterialShape.Shape.Cookie12Sided: return MaterialShapes.getCookie12Sided();
            case MaterialShape.Shape.Ghostish: return MaterialShapes.getGhostish();
            case MaterialShape.Shape.Clover4Leaf: return MaterialShapes.getClover4Leaf();
            case MaterialShape.Shape.Clover8Leaf: return MaterialShapes.getClover8Leaf();
            case MaterialShape.Shape.Burst: return MaterialShapes.getBurst();
            case MaterialShape.Shape.SoftBurst: return MaterialShapes.getSoftBurst();
            case MaterialShape.Shape.Boom: return MaterialShapes.getBoom();
            case MaterialShape.Shape.SoftBoom: return MaterialShapes.getSoftBoom();
            case MaterialShape.Shape.Flower: return MaterialShapes.getFlower();
            case MaterialShape.Shape.Puffy: return MaterialShapes.getPuffy();
            case MaterialShape.Shape.PuffyDiamond: return MaterialShapes.getPuffyDiamond();
            case MaterialShape.Shape.PixelCircle: return MaterialShapes.getPixelCircle();
            case MaterialShape.Shape.PixelTriangle: return MaterialShapes.getPixelTriangle();
            case MaterialShape.Shape.Bun: return MaterialShapes.getBun();
            case MaterialShape.Shape.Heart: return MaterialShapes.getHeart();
            default: return MaterialShapes.getCircle();
        }
    }
    
    // Animation support
    property var prevRoundedPolygon: null
    property double progress: 1
    property var morph: roundedPolygon ? new Morph.Morph(roundedPolygon, roundedPolygon) : null
    
    onRoundedPolygonChanged: {
        if (!roundedPolygon) return
        if (root.morph) delete root.morph
        root.morph = new Morph.Morph(root.prevRoundedPolygon ?? root.roundedPolygon, root.roundedPolygon)
        morphBehavior.enabled = false
        root.progress = 0
        morphBehavior.enabled = true
        root.progress = 1
        root.prevRoundedPolygon = root.roundedPolygon
    }
    
    Behavior on progress {
        id: morphBehavior
        NumberAnimation {
            duration: 350
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.42, 1.67, 0.21, 0.90, 1, 1]
        }
    }
    
    onProgressChanged: requestPaint()
    onColorChanged: requestPaint()
    
    onPaint: {
        var ctx = getContext("2d")
        ctx.fillStyle = root.color
        ctx.clearRect(0, 0, width, height)
        if (!root.morph) return
        const cubics = root.morph.asCubics(root.progress)
        if (cubics.length === 0) return

        const size = Math.min(root.width, root.height)
        const offsetX = root.width / 2 - size / 2
        const offsetY = root.height / 2 - size / 2

        ctx.save()
        ctx.translate(offsetX, offsetY)
        ctx.scale(size, size)

        ctx.beginPath()
        ctx.moveTo(cubics[0].anchor0X, cubics[0].anchor0Y)
        for (const cubic of cubics) {
            ctx.bezierCurveTo(
                cubic.control0X, cubic.control0Y,
                cubic.control1X, cubic.control1Y,
                cubic.anchor1X, cubic.anchor1Y
            )
        }
        ctx.closePath()
        ctx.fill()
        ctx.restore()
    }
}

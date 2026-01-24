import QtQuick
import "../../settings"

Item {
    id: root
    
    property alias text: symbol.text
    property alias iconSize: symbol.size
    property alias iconColor: symbol.color
    property int shape: MaterialShape.Shape.Cookie7Sided
    property color shapeColor: Appearance.colors.iconShapeBg
    property real padding: 6
    
    implicitWidth: shape_.implicitSize
    implicitHeight: shape_.implicitSize
    width: implicitWidth
    height: implicitHeight
    
    MaterialShape {
        id: shape_
        anchors.centerIn: parent
        color: root.shapeColor
        shape: root.shape
        // Safeguard against NaN which can happen during font/text transitions
        implicitSize: (Math.max(symbol.implicitWidth, symbol.implicitHeight) || 0) + root.padding * 2
        width: implicitWidth
        height: implicitHeight
    }
    
    MaterialSymbol {
        id: symbol
        anchors.centerIn: parent
        color: root.iconColor ?? Appearance.colors.iconShapeFg
        size: Appearance.font.pixelSize.huge
    }
}

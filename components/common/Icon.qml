import QtQuick
import QtQuick.Effects
import "../../theme"

Item {
    id: root
    
    property string source: ""
    property int size: 24
    property color color: Theme.text
    property bool tint: false
    
    implicitWidth: size
    implicitHeight: size
    
    readonly property bool isImage: source.includes("/") || source.includes(".")
    
    // Text icon (NerdFont)
    Text {
        id: textIcon
        visible: !root.isImage
        anchors.centerIn: parent
        text: root.source
        font.family: Theme.fontFamily
        font.pixelSize: root.size
        color: root.tint ? root.color : root.color
    }
    
    // Image icon
    Image {
        id: imageIcon
        visible: root.isImage
        anchors.fill: parent
        source: root.isImage ? root.source : ""
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        smooth: true
        asynchronous: true
        cache: true
        
        // Fallback when image fails to load
        onStatusChanged: {
            if (status === Image.Error) {
                visible = false
                fallbackIcon.visible = true
            }
        }
    }
    
    // Grayscale + Color tint effect for images
    MultiEffect {
        visible: root.isImage && root.tint && imageIcon.status === Image.Ready
        anchors.fill: imageIcon
        source: imageIcon
        
        // Grayscale
        saturation: -1.0
        
        // Color overlay
        colorizationColor: root.color
        colorization: 1.0
    }
    
    // Fallback icon (when image fails to load)
    Text {
        id: fallbackIcon
        visible: false
        anchors.centerIn: parent
        text: "󰀻"  // Default app icon
        font.family: Theme.fontFamily
        font.pixelSize: root.size
        color: root.color
    }
}

import QtQuick
import QtQuick.Effects
import "../../theme"
import "../../services"

Item {
    id: root
    
    property string source: ""
    property int size: 24
    property color color: Theme.text
    property bool tint: false
    
    implicitWidth: size
    implicitHeight: size
    
    // Check what type of icon this is
    readonly property bool isImage: source.includes("/") || source.includes(".")
    readonly property bool isMaterialDesign: !isImage && source.length > 0 && !isNerdFont(source)
    readonly property string resolvedSource: isMaterialDesign ? resolveMaterialDesignIcon(source) : source
    
    // Check if source is a NerdFont character (typically Unicode characters)
    function isNerdFont(str) {
        if (str.length === 0) return false
        // NerdFont icons are typically single Unicode characters or very short strings
        if (str.length > 10) return false
        // Check if it contains typical icon hex codes or special characters
        var code = str.charCodeAt(0)
        return code > 0xE000 || str.includes("󰀀") || str.includes("") || str.includes("")
    }
    
    function resolveMaterialDesignIcon(iconName) {
        if (!iconName || iconName.length === 0) return ""
        
        var iconType = "filled"
        if (typeof Config !== 'undefined' && Config.theme && Config.theme.icons) {
            iconType = Config.theme.icons
        }
        
        // Use Directories service for consistent path resolution
        if (typeof Directories !== 'undefined') {
            return Directories.getMaterialIconUrl(iconName, iconType)
        }
        
        // Fallback if Directories service not available
        console.warn("Icon: Directories service not available, using fallback path resolution")
        return ""
    }
    
    // Text icon (NerdFont)
    Text {
        id: textIcon
        visible: !root.isImage && !root.isMaterialDesign
        anchors.centerIn: parent
        text: root.source
        font.family: Theme.fontFamily
        font.pixelSize: root.size
        color: root.tint ? root.color : root.color
    }
    
    // Image icon (file paths and Material Design icons)
    Image {
        id: imageIcon
        visible: root.isImage || root.isMaterialDesign
        anchors.fill: parent
        source: root.isImage ? root.source : root.resolvedSource
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        smooth: true
        asynchronous: true
        cache: true
        
        // Fallback when image fails to load
        onStatusChanged: {
            if (status === Image.Error) {
                console.warn("Icon: Failed to load image:", source)
                visible = false
                fallbackIcon.visible = true
            }
        }
    }
    
    // Grayscale + Color tint effect for images
    MultiEffect {
        visible: (root.isImage || root.isMaterialDesign) && root.tint && imageIcon.status === Image.Ready
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

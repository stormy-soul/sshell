import QtQuick
import Quickshell
import QtQuick.Effects
import "../../settings"
import "../../services"

Item {
    id: root
    
    property string source: ""
    property int size: 24
    property color color: Appearance.colors.text
    property bool tint: false
    
    implicitWidth: size
    implicitHeight: size
    
    readonly property bool isFilePath: source.startsWith("/") || source.startsWith("file://")
    readonly property bool isMaterialDesign: !isFilePath && source.length > 0 && !isNerdFont(source) && isMaterialIconName(source)
    
    readonly property string resolvedSource: {
        if (isFilePath) return source
        if (isMaterialDesign) return resolveMaterialDesignIcon(source)
        var systemPath = Quickshell.iconPath(source)
        if (systemPath && systemPath.length > 0) return systemPath
        return ""
    }
    
    function isNerdFont(str) {
        if (str.length === 0) return false
        if (str.length > 10) return false
        var code = str.charCodeAt(0)
        return code > 0xE000 || str.includes("󰀀") || str.includes("") || str.includes("")
    }
    
    function isMaterialIconName(str) {
        if (str.length > 20) return false
        if (str.includes(".") || str.includes("-")) return false
        if (!/^[a-z_0-9]+$/.test(str)) return false
        var knownIcons = ["search", "apps", "calculate", "close", "menu", "settings", "home", "add", "remove", "edit", "delete", "check", "error", "warning", "info"]
        if (knownIcons.indexOf(str) !== -1) return true
        return str.length <= 12 && !str.includes("_")
    }
    
    function resolveMaterialDesignIcon(iconName) {
        if (!iconName || iconName.length === 0) return ""
        
        var iconType = "filled"
        if (typeof Config !== 'undefined' && Config.theme && Config.theme.icons) {
            iconType = Config.theme.icons
        }
        
        if (typeof Directories !== 'undefined') {
            return Directories.getMaterialIconUrl(iconName, iconType)
        }
        
        console.warn("Icon: Directories service not available")
        return ""
    }
    
    Text {
        id: textIcon
        visible: !root.isFilePath && !root.isMaterialDesign && root.isNerdFont(root.source) && root.resolvedSource.length === 0
        anchors.centerIn: parent
        text: root.source
        font.family: Appearance.font.family.nerd
        font.pixelSize: root.size
        color: root.tint ? root.color : root.color
    }
    
    Image {
        id: imageIcon
        visible: root.resolvedSource.length > 0
        anchors.fill: parent
        source: root.resolvedSource
        fillMode: Image.PreserveAspectFit
        sourceSize: Qt.size(root.size * 2, root.size * 2)
        smooth: true
        asynchronous: true
        cache: true
        
        onStatusChanged: {
            if (status === Image.Error) {
                console.warn("Icon: Failed to load image:", source)
                visible = false
                fallbackIcon.visible = true
            }
        }
    }
    
    MultiEffect {
        visible: (root.isFilePath || root.isMaterialDesign) && root.tint && imageIcon.status === Image.Ready
        anchors.fill: imageIcon
        source: imageIcon
        saturation: -1.0
        colorizationColor: root.color
        colorization: 1.0
    }
    
    Text {
        id: fallbackIcon
        visible: false
        anchors.centerIn: parent
        text: "󰀻"  
        font.family: Appearance.font.family.nerd
        font.pixelSize: root.size
        color: root.color
    }
}

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../common"
import "../../settings"
import Qt5Compat.GraphicalEffects

Rectangle {
    id: root
    
    property string icon: ""
    property string title: ""
    property string valueText: ""
    property string secondaryText: ""
    property real usagePercent: 0
    property var graphData: [] 
    
    implicitWidth: 200
    implicitHeight: 240
    
    radius: Appearance.sizes.cornerRadiusLarge
    color: Appearance.colors.overlayBackground
    clip: true
    
    layer.enabled: true
    layer.effect: OpacityMask {
        maskSource: Rectangle {
            width: root.width
            height: root.height
            radius: root.radius
        }
    }
    
    Loader {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: parent.height * 0.5
        active: root.graphData && root.graphData.length > 0
        sourceComponent: ResourceGraph {
            values: root.graphData
            color: Appearance.colors.accent
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.sizes.paddingLarge
        spacing: 10
        
        Rectangle {
            Layout.alignment: Qt.AlignLeft
            width: 48
            height: 48
            radius: Appearance.sizes.cornerRadius
            color: Appearance.colors.surfaceVariant
            
            MaterialIcon {
                anchors.centerIn: parent
                icon: root.icon
                width: 32
                height: 32
                color: Appearance.colors.accent
            }
        }
        
        Item { Layout.fillHeight: true } 
        
        Text {
            text: Math.round(root.usagePercent * 100) + "%"
            font.family: Appearance.font.family.main
            font.pixelSize: 36 // Big number
            font.weight: Font.Bold
            color: Appearance.colors.text
        }
        
        Text {
            text: root.title
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.large
            font.weight: Font.DemiBold
            color: Appearance.colors.text
        }
        
        Text {
            visible: root.secondaryText !== ""
            text: root.secondaryText
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.small
            color: Appearance.colors.textSecondary
        }
    }
}

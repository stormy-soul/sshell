import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../settings"
import "../common"

ColumnLayout {
    id: root
    property string title: ""
    property string tooltip: ""
    default property alias data: sectionContent.data

    Layout.fillWidth: true
    Layout.topMargin: Appearance.sizes.paddingSmall

    spacing: 2

    RowLayout {
        visible: root.title !== ""
        
        Text {
            text: root.title
            color: Appearance.colors.text
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
        }
        
        MaterialIcon {
            visible: root.tooltip !== ""
            icon: "info"
            width: Appearance.font.pixelSize.normal
            height: Appearance.font.pixelSize.normal
            color: Appearance.colors.textSecondary
            
            ToolTip.visible: ma.containsMouse
            ToolTip.text: root.tooltip
            ToolTip.delay: 500
            
            MouseArea {
                id: ma
                anchors.fill: parent
                hoverEnabled: true
            }
        }
        
        Item { Layout.fillWidth: true }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        spacing: 2
    }
}

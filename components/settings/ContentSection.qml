import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../settings"
import "../common"

ColumnLayout {
    id: root
    property string title
    property string icon: ""
    property int space: 0
    default property alias data: sectionContent.data

    Layout.fillWidth: true
    Layout.topMargin: root.space
    spacing: Appearance.sizes.paddingSmall

    RowLayout {
        spacing: Appearance.sizes.paddingSmall
        visible: root.title !== ""
        
        MaterialIcon {
            visible: root.icon !== ""
            icon: root.icon
            width: Appearance.font.pixelSize.extraLarge
            height: Appearance.font.pixelSize.extraLarge
            color: Appearance.colors.text
        }
        
        Text {
            text: root.title
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.extraLarge
            font.weight: Font.DemiBold
            color: Appearance.colors.text
        }
    }

    ColumnLayout {
        id: sectionContent
        Layout.fillWidth: true
        spacing: Appearance.sizes.paddingSmall
        
    }
}

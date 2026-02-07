import QtQuick
import QtQuick.Layouts
import "../../settings"
import "../common"

RippleButton {
    id: root
    property string icon: ""
    property string text: ""
    property bool iconFill: true
    
    implicitHeight: 40
    buttonRadius: Appearance.sizes.cornerRadius
    colBackground: Appearance.colors.surfaceVariant
    
    contentItem: RowLayout {
        spacing: 10
        anchors.centerIn: parent
        width: parent.width - (root.horizontalPadding * 2)
        
        MaterialIcon {
            visible: root.icon !== ""
            icon: root.icon
            width: Appearance.font.pixelSize.large
            height: Appearance.font.pixelSize.large
            color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
        }
        
        Text {
            text: root.text
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
            Layout.fillWidth: true
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }
    }
}

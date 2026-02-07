import QtQuick
import QtQuick.Layouts
import "../../settings"
import "../common"

RippleButton {
    id: root
    property string buttonIcon: ""
    property string buttonText: ""
    
    property bool leftmost: false
    property bool rightmost: false
    
    buttonRadius: Appearance.sizes.cornerRadius
    
    colBackground: Appearance.colors.surfaceVariant
    colBackgroundHover: Appearance.colors.surfaceHover
    colBackgroundToggled: Appearance.colors.primary

    contentItem: RowLayout {
        spacing: 6
        anchors.centerIn: parent
        
        MaterialIcon {
            visible: root.buttonIcon !== ""
            icon: root.buttonIcon
            width: Appearance.font.pixelSize.large
            height: Appearance.font.pixelSize.large
            color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
        }
        
        Text {
            visible: root.buttonText !== ""
            text: root.buttonText
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
        }
    }
}

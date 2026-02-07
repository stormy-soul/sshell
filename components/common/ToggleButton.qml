import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../settings"

RippleButton {
    id: root
    property string buttonIcon
    property bool hasIcon: true
    property alias iconSize: iconWidget.width
    property string title
    property string subtitle: ""
    
    checkable: true
    
    colBackground: "transparent"
    colBackgroundHover: "transparent"
    colBackgroundToggled: "transparent"
    rippleColor: Appearance.colors.surfaceHover
    
    Layout.fillWidth: true
    implicitHeight: Math.max(40, contentItem.implicitHeight + 4 * 2) // Reduced height padding
    
    contentItem: RowLayout {
        spacing: 12
        anchors.fill: parent
        anchors.margins: 0
        
        MaterialIcon {
            id: iconWidget
            icon: root.buttonIcon
            opacity: root.enabled ? 1 : 0.4
            width: Appearance.font.pixelSize.large
            height: Appearance.font.pixelSize.large
            color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
            visible: root.hasIcon
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            
            Text {
                id: labelWidget
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Appearance.font.pixelSize.normal
                font.family: Appearance.font.family.main
                color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
                opacity: root.enabled ? 1 : 0.4
            }
            
            Text {
                visible: root.subtitle !== ""
                Layout.fillWidth: true
                text: root.subtitle
                font.pixelSize: Appearance.font.pixelSize.small
                font.family: Appearance.font.family.main
                color: root.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.textSecondary
                opacity: root.enabled ? 0.8 : 0.4
            }
        }
        
        StyledSwitch {
            id: switchWidget
            down: root.down
            Layout.fillWidth: false
            checked: root.checked
            onClicked: root.clicked()
        }
    }
}

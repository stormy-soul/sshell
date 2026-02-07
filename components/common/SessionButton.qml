import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../common"
import "../../settings"

RippleButton {
    id: root

    property string label
    property string ic
    property bool isFocused: false

    implicitWidth: 160
    implicitHeight: 160

    buttonRadius: (root.focus || root.down || root.hovered) ? width / 4 : Appearance.sizes.cornerRadius
    
    colBackground: root.focus ? Appearance.colors.primary : Appearance.colors.overlayBackground
    colBackgroundHover: Appearance.colors.primary
    colRipple: Appearance.colors.onPrimary

    property color colIcon: (root.activeFocus || root.down || root.hovered) ? Appearance.m3Surface : Appearance.colors.text

    Behavior on buttonRadius { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }

    contentItem: ColumnLayout {
        anchors.centerIn: parent
        spacing: 0

        MaterialIcon {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 20
            icon: root.ic
            Layout.preferredWidth: Appearance.font.pixelSize.jupiter
            Layout.preferredHeight: Appearance.font.pixelSize.jupiter
            color: root.colIcon
            
            scale: (root.activeFocus || root.down || root.hovered) ? 1.2 : 1.0
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            Layout.bottomMargin: 20
            text: root.label
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.huge
            font.weight: Font.DemiBold
            color: root.colIcon
        }
    }
    
    Keys.onPressed: (event) => {
        if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter || event.key === Qt.Key_Space) {
            root.clicked()
            event.accepted = true
        }
    }
}

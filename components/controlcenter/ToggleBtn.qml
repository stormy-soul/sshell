import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../settings"
import "../common"

Rectangle {
    id: root

    property string icon
    property string title
    property string subtitle
    property bool active
    property bool expanded: true

    signal clicked()
    property alias mouseArea: internalMouseArea

    radius: Appearance.sizes.cornerRadiusLarge
    color: Appearance.colors.overlayBackground

    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.margins: 10
        spacing: 12

        Rectangle {
            Layout.preferredWidth: 40
            Layout.preferredHeight: 40
            Layout.alignment: Qt.AlignVCenter
            radius: Appearance.sizes.cornerRadiusLarge
            color: root.active ? Appearance.colors.accent : Appearance.colors.surfaceVariant

            MaterialIcon {
                anchors.centerIn: parent
                icon: root.icon
                width: 20
                height: 20
                color: root.active ? Appearance.colors.colOnPrimary : Appearance.colors.text
            }
        }

        ColumnLayout {
            visible: root.expanded
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignVCenter
            spacing: 0

            Text {
                text: root.title
                Layout.fillWidth: true
                elide: Text.ElideRight
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                font.weight: Font.Bold
                font.pixelSize: Appearance.font.pixelSize.normal
            }

            Text {
                text: root.subtitle
                Layout.fillWidth: true
                elide: Text.ElideRight
                color: Appearance.colors.textSecondary
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.small
            }
        }
    }

    MouseArea {
        id: internalMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

import QtQuick
import QtQuick.Layouts
import Quickshell
import "../../settings"

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

    Item {
        anchors.fill: parent
        anchors.margins: 10
        
        RowLayout {
            id: contentRow
            spacing: 12
            
            states: [
                State {
                    name: "expanded"
                    when: root.expanded
                    AnchorChanges {
                        target: contentRow
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                    }
                },
                State {
                    name: "collapsed"
                    when: !root.expanded
                    AnchorChanges {
                        target: contentRow
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            ]
            
            transitions: Transition {
                AnchorAnimation { duration: Appearance.animation.duration; easing.type: Easing.OutCubic }
            }

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
    }

    MouseArea {
        id: internalMouseArea
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

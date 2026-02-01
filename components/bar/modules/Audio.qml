import QtQuick
import "../../../settings"
import "../../../services" as Services
import "../../common"

Rectangle {
    id: root
    implicitHeight: 30
    implicitWidth: row.implicitWidth
    color: "transparent"

    Row {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.sizes.padding
        
        MaterialIcon {
            icon: Services.Audio.muted ? "volume_off" : "volume_up"
            width: Appearance.font.pixelSize.large
            height: Appearance.font.pixelSize.large
            color: Appearance.colors.text
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            text: Services.Audio.muted ? "Muted" : Math.round(Services.Audio.volume * 100) + "%"
            color: Appearance.colors.text
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            anchors.verticalCenter: parent.verticalCenter
        }
    }
    
    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            Services.Audio.toggleMute()
        }
        onWheel: (wheel) => {
            if (wheel.angleDelta.y > 0) {
                Services.Audio.volume = Math.min(1, Services.Audio.volume + 0.05)
            } else {
                Services.Audio.volume = Math.max(0, Services.Audio.volume - 0.05)
            }
        }
    }
}

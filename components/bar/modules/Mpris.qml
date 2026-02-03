import QtQuick
import "../../../settings"
import "../../../services"
import "../../common"
import "../modules/popups"

Rectangle {
    id: root
    
    visible: MprisController.isPlaying && MprisController.activeTrack.title && MprisController.activeTrack.title !== "Unknown Title"
    
    implicitWidth: Math.min(250, contentRow.implicitWidth + Appearance.sizes.padding * 2)
    implicitHeight: 30
    color: "transparent"
    clip: true
    
    property bool hovered: mouseArea.containsMouse
    property bool shouldShowPopup: root.hovered || popup.popupHovered
    
    Timer {
        id: closeDelayTimer
        interval: 150
        onTriggered: {
            if (!root.shouldShowPopup) {
                popup.shown = false
            }
        }
    }
    
    onShouldShowPopupChanged: {
        if (shouldShowPopup) {
            closeDelayTimer.stop()
            popup.shown = true
        } else {
            closeDelayTimer.restart()
        }
    }
    
    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        anchors.left: parent.left
        anchors.leftMargin: Appearance.sizes.padding
        spacing: Appearance.sizes.paddingSmall
        width: parent.width - Appearance.sizes.padding * 2
        
        MaterialIcon {
            icon: "audiotrack"
            width: Appearance.font.pixelSize.large
            height: Appearance.font.pixelSize.large
            color: Appearance.colors.accent
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: !Config.mpris.showArtist && Config.mpris.barVisualizer ? MprisController.activeTrack.title + " " : MprisController.activeTrack.title || "Unknown" 
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.text
            elide: Text.ElideRight
            maximumLineCount: 1
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            visible: !!MprisController.activeTrack.artist && Config.mpris.showArtist
            text: "• " + MprisController.activeTrack.artist
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.textSecondary
            width: Math.min(implicitWidth, 80)
            elide: Text.ElideRight
            maximumLineCount: 1
        }

        AudioVisualizer {
            visible: Config.mpris.barVisualizer
            id: visualizer
            onBar: true
            maxBarHeight: 20
            minBarHeight: 4
            barWidth: 3
            barGap: 2
            animationDuration: 35
            source: MprisController.activeTrack.artUrl || ""
        }
    }
    
    MouseArea {
        id: mouseArea
        z: 1
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
    
    MprisPopup {
        id: popup
        sourceItem: root
    }
}

import QtQuick
import Qt5Compat.GraphicalEffects
import "../../../settings"
import "../../../services"
import "../../common"
import "../modules/popups"

Rectangle {
    id: root
    
    visible: MprisController.isPlaying && MprisController.activeTrack.title && MprisController.activeTrack.title !== "Unknown Title"
    
    implicitWidth: contentRow.implicitWidth + Appearance.sizes.padding * 2
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
        anchors.centerIn: parent
        spacing: Appearance.sizes.paddingSmall
        
        MaterialIcon {
            visible: !Config.mpris.barVisualizer
            icon: "music_note"
            width: Appearance.font.pixelSize.huge
            height: Appearance.font.pixelSize.huge
            color: Appearance.colors.accent
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Rectangle {
            id: coverContainer
            visible: Config.mpris.barVisualizer

            width: Appearance.font.pixelSize.massive
            height: Appearance.font.pixelSize.massive
            radius: Appearance.sizes.cornerRadiusSmall
            color: Appearance.colors.surfaceVariant
            
            layer.enabled: true
            layer.effect: OpacityMask {
                maskSource: Rectangle {
                    width: coverContainer.width
                    height: coverContainer.height
                    radius: coverContainer.radius
                }
            }
            
            Image {
                id: coverArt
                anchors.fill: parent
                source: MprisController.activeTrack.artUrl || ""
                fillMode: Image.PreserveAspectCrop
                visible: false
            }
            
            FastBlur {
                anchors.fill: coverArt
                source: coverArt
                radius: 8
                visible: true
            }

            Rectangle {
                anchors.fill: parent
                color: "black"
                opacity: 0.2
            }
            
            Rectangle {
                anchors.fill: parent
                color: "transparent"
                radius: Appearance.sizes.cornerRadiusSmall
                border.width: 1
                border.color: Qt.rgba(1, 1, 1, 0.1)
            }

            Loader {
                id: visualizerLoader
                anchors.centerIn: parent
                active: Config.mpris.barVisualizer
                sourceComponent: Component {
                    AudioVisualizer {
                        onBar: true
                        maxBarHeight: 10
                        minBarHeight: 2
                        barWidth: 2
                        barGap: 1
                        animationDuration: 35
                        source: MprisController.activeTrack.artUrl || ""
                    }
                }
            }
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

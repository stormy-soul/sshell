import QtQuick
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects
import "../../../settings"
import "../../../services"
import "../../common"
import "../modules/popups"

Rectangle {
    id: root
    
    visible: MprisController.isPlaying && MprisController.activeTrack.title && MprisController.activeTrack.title !== "Unknown Title"
    
    implicitWidth: MprisController.isPlaying ? (Math.min(contentRow.implicitWidth, (Config.mpris.maxWidthOnBar || 750))) : 0 // oooo spooky
    implicitHeight: Config.bar.height
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
    
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        width: Math.min(implicitWidth, parent.width)
        spacing: Appearance.sizes.paddingSmall
        
        MaterialIcon {
            visible: !Config.mpris.barVisualizer
            icon: "music_note"
            width: Appearance.font.pixelSize.huge
            height: Appearance.font.pixelSize.huge
            color: Appearance.colors.accent
            Layout.alignment: Qt.AlignVCenter
        }
        
        Rectangle {
            id: coverContainer
            visible: Config.mpris.barVisualizer
            Layout.alignment: Qt.AlignVCenter

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
            Layout.alignment: Qt.AlignVCenter
            text: !Config.mpris.showArtist && Config.mpris.barVisualizer ? MprisController.activeTrack.title + " " : MprisController.activeTrack.title || "Unknown" 
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.text
            elide: Text.ElideRight
            maximumLineCount: 1
            Layout.fillWidth: true
            Layout.minimumWidth: 50
            Layout.maximumWidth: root.implicitWidth
        }
        
        Text {
            Layout.alignment: Qt.AlignVCenter
            visible: !!MprisController.activeTrack.artist && Config.mpris.showArtist
            text: "• " + MprisController.activeTrack.artist
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.textSecondary
            Layout.maximumWidth: 80
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

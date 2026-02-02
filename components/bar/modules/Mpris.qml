import QtQuick
import "../../../settings"
import "../../../services"
import "../../common"

Rectangle {
    id: root
    
    visible: !!MprisController.activePlayer
    
    implicitWidth: contentRow.implicitWidth + Appearance.sizes.padding * 2
    implicitHeight: (Config.bar.height || 40) - Appearance.sizes.paddingSmall // Fallback 40 if Config null?
    color: "transparent"
    
    Row {
        id: contentRow
        anchors.verticalCenter: parent.verticalCenter
        spacing: Appearance.sizes.paddingSmall
        
        MaterialIcon {
            icon: "audiotrack"
            width: Appearance.font.pixelSize.large
            height: Appearance.font.pixelSize.large
            color: Appearance.colors.accent
            anchors.verticalCenter: parent.verticalCenter
        }
        
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: MprisController.activeTrack.title || "Unknown"
            font.family: Appearance.font.family.main
            font.pixelSize: Appearance.font.pixelSize.normal
            color: Appearance.colors.text
            
            // Limit width if too long?
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
            
            elide: Text.ElideRight
            maximumLineCount: 1
        }
    }
}

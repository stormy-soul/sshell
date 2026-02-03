import QtQuick
import QtQuick.Layouts
import "../../settings"
import "../common"

Rectangle {
    id: popup
    
    property Item anchor: null
    property bool show: false
    property int popupMargin: 12
    
    visible: opacity > 0
    opacity: show ? 1 : 0
    
    Behavior on opacity { NumberAnimation { duration: Appearance.animation.duration } }
    
    color: Appearance.colors.overlayBackground
    radius: Appearance.sizes.cornerRadiusLarge
    border.width: 1
    border.color: Appearance.colors.surfaceVariant
    
    layer.enabled: true
    layer.effect: null
    
    implicitWidth: contentColumn.implicitWidth + popupMargin * 2
    implicitHeight: contentColumn.implicitHeight + popupMargin * 2
    
    x: anchor ? (anchor.width / 2 - width / 2) : 0
    y: anchor ? (anchor.height + 8) : 0
    
    default property alias content: contentColumn.data
    
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: popup.popupMargin
        spacing: 6
    }
}

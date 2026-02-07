import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../settings"

Flickable {
    id: root
    property real baseWidth: 750
    property bool forceWidth: false
    property real bottomContentPadding: 50

    default property alias data: contentColumn.data

    clip: true
    contentHeight: contentColumn.implicitHeight + root.bottomContentPadding

    ScrollBar.vertical: ScrollBar {
        policy: ScrollBar.AsNeeded
        width: 10
        active: root.moving || root.flicking
    }
    
    boundsBehavior: Flickable.DragOverBounds

    ColumnLayout {
        id: contentColumn
        
        width: Math.min(root.baseWidth, root.width - (Appearance.sizes.paddingLarge * 2))
        
        anchors {
            top: parent.top
            horizontalCenter: parent.horizontalCenter
            topMargin: Appearance.sizes.paddingLarge
        }
        spacing: Appearance.sizes.paddingLarge
    }
}

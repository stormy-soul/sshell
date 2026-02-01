import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import "../../settings"
import "../common"

Rectangle {
    id: root
    
    default property alias content: contentLayout.data
    property string title: ""
    property alias headerRightItem: headerRightLoader.sourceComponent
    
    signal backRequested()
    
    color: Appearance.colors.surface
    radius: Appearance.sizes.cornerRadiusLarge
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Appearance.sizes.paddingHellaLarge
        spacing: 10
        
        // Header
        RowLayout {
            Layout.fillWidth: true
            
            MaterialIcon {
                icon: "arrow_back"
                width: 20
                height: 20
                color: Appearance.colors.text
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.backRequested()
                }
            }
            
            Text {
                text: root.title
                color: Appearance.colors.text
                font.family: Appearance.font.family.main
                font.pixelSize: Appearance.font.pixelSize.large
                font.bold: true
                Layout.fillWidth: true
                Layout.leftMargin: 10
            }
            
            Loader {
                id: headerRightLoader
                Layout.alignment: Qt.AlignRight
            }
        }
        
        // Main Content
        ColumnLayout {
            id: contentLayout
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}

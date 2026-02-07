import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import "../components/common" as Common
import "."

PanelWindow {
    id: root
    
    property bool shown: false
    visible: shown
    
    color: "transparent"
    
    WlrLayershell.namespace: "sshell:settings"
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive
    exclusionMode: ExclusionMode.Ignore
    
    implicitWidth: 1000
    implicitHeight: 650
    
    mask: Region { item: background }
    
    property string currentTab: "Quick"
    
    property var tabs: [
        { name: "Quick", icon: "bolt", component: "pages/Quick.qml" },
        { name: "General", icon: "settings", component: "pages/General.qml" },
        { name: "Bar", icon: "dock", component: "pages/Bar.qml" },
        { name: "Modules", icon: "view_module", component: "pages/Modules.qml" },
        { name: "System", icon: "monitor", component: "pages/System.qml" }
    ]
    
    HyprlandFocusGrab {
        id: grab
        windows: [root]
        active: root.visible
        onCleared: {
            if (!active) root.shown = false
        }
    }
    
    Rectangle {
        id: background
        anchors.fill: parent
        color: Appearance.colors.overlayBackground
        radius: Appearance.sizes.cornerRadiusLarge
        border.width: 1
        border.color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
        clip: true
        focus: true
        
        RowLayout {
            anchors.fill: parent
            spacing: 0
            
            Rectangle {
                Layout.preferredWidth: parent.width * 0.2
                Layout.fillHeight: true
                color: "transparent"
                
                border.width: 0 
                border.color: "transparent"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.padding
                    spacing: Appearance.sizes.paddingSmall
                    
                    Text {
                        text: "Settings"
                        color: Appearance.colors.text
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.huge
                        font.weight: Font.DemiBold
                        Layout.alignment: Qt.AlignHCenter
                        Layout.bottomMargin: Appearance.sizes.padding
                        Layout.topMargin: Appearance.sizes.padding
                    }

                    ListView {
                        id: sidebarList
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        model: root.tabs
                        spacing: Appearance.sizes.paddingSmall
                        
                        delegate: Common.RippleButton {
                            id: tabItem
                            required property var modelData
                            
                            width: sidebarList.width
                            height: 40
                            buttonRadius: Appearance.sizes.cornerRadiusSmall
                            
                            toggled: root.currentTab === modelData.name
                            
                            contentItem: RowLayout {
                                anchors.fill: parent
                                anchors.margins: Appearance.sizes.paddingSmall
                                spacing: Appearance.sizes.padding
                                
                                Common.MaterialIcon {
                                    icon: tabItem.modelData.icon
                                    color: tabItem.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
                                    width: 20
                                    height: 20
                                }
                                
                                Text {
                                    text: tabItem.modelData.name
                                    color: tabItem.toggled ? Appearance.colors.colOnPrimary : Appearance.colors.text
                                    font.family: Appearance.font.family.main
                                    font.pixelSize: Appearance.font.pixelSize.normal
                                    font.weight: Font.Medium
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                    verticalAlignment: Text.AlignVCenter
                                }
                            }
                            
                            onClicked: root.currentTab = modelData.name
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.preferredWidth: 1
                Layout.fillHeight: true
                color: Qt.rgba(Appearance.colors.border.r, Appearance.colors.border.g, Appearance.colors.border.b, 0.1)
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: "transparent"
                
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: Appearance.sizes.paddingLarge
                    spacing: Appearance.sizes.padding
                    
                    Text {
                        text: root.currentTab
                        color: Appearance.colors.text
                        font.family: Appearance.font.family.main
                        font.pixelSize: Appearance.font.pixelSize.huge
                        Layout.topMargin: Appearance.sizes.paddingSmall
                        font.weight: Font.DemiBold
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: Appearance.colors.overlayBackground
                        radius: Appearance.sizes.cornerRadius
                        clip: true
                        
                        Loader {
                            id: pageLoader
                            anchors.fill: parent
                            anchors.margins: Appearance.sizes.padding
                            
                            source: {
                                var tab = root.tabs.find(t => t.name === root.currentTab);
                                return tab ? tab.component : "";
                            }
                            
                            NumberAnimation on opacity {
                                from: 0; to: 1; duration: 200
                                running: pageLoader.status === Loader.Ready
                            }
                        }
                    }
                }
            }
        }
        
        Keys.onPressed: (event) => {
            if (event.key === Qt.Key_Escape) {
                root.shown = false
            }
        }
    }
}

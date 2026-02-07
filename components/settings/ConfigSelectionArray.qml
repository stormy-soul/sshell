import QtQuick
import QtQuick.Layouts
import "../../settings"
import "../common"

Flow {
    id: root
    Layout.fillWidth: true
    spacing: 2
    
    property var options: [] 
    // options format: [{ displayName: "Name", icon: "icon", value: "value" }, ...]
    
    property var currentValue: null
    
    signal selected(var newValue)
    
    Repeater {
        model: root.options
        delegate: SelectionGroupButton {
            id: slButton
            required property var modelData
            required property int index
            
            buttonText: modelData.displayName !== undefined ? modelData.displayName : modelData
            buttonIcon: modelData.icon || ""
            
            property var val: modelData.value !== undefined ? modelData.value : modelData
            
            toggled: root.currentValue === val
            
            Layout.fillWidth: true
            
            onClicked: {
                root.selected(val)
            }
        }
    }
}

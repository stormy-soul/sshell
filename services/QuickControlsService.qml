pragma Singleton
import QtQuick
import Quickshell
import "../settings"

Singleton {
    id: root

    property var availableControls: [
        { id: "wifi", icon: "wifi", title: "Wi-Fi" },
        { id: "bluetooth", icon: "bluetooth", title: "Bluetooth" },
        { id: "audio", icon: "volume_up", title: "Audio" },
        { id: "airplane", icon: "flight", title: "Airplane Mode" },
        { id: "nightlight", icon: "nights_stay", title: "Night Light" },
        { id: "dnd", icon: "notifications_off", title: "Do Not Disturb" },
        { id: "darkmode", icon: "dark_mode", title: "Dark Mode" },
        { id: "recorder", icon: "radio_button_checked", title: "Screen Record" },
        { id: "screenshot", icon: "photo_camera", title: "Screenshot" }
    ]

    property var activeControls: []

    function findIndex(id) {
        for (var i = 0; i < activeControls.length; i++) {
            if (activeControls[i].id === id) return i;
        }
        return -1;
    }

    function getDefinition(id) {
        for (var i = 0; i < availableControls.length; i++) {
            if (availableControls[i].id === id) return availableControls[i];
        }
        return null; // Should not happen
    }

    function load() {
        console.log("QuickControlsService: Loading. Persist count: " + (Persistent.states.quickSettings && Persistent.states.quickSettings.controls ? Persistent.states.quickSettings.controls.length : "null"))
        if (Persistent.states.quickSettings && Persistent.states.quickSettings.controls) {
            var loaded = []
            var pers = Persistent.states.quickSettings.controls
            for (var i = 0; i < pers.length; i++) {
                loaded.push(JSON.parse(JSON.stringify(pers[i])))
                console.log("QuickControlsService: Loaded: " + JSON.stringify(pers[i]))
            }
            root.activeControls = loaded
        } else {
            root.resetDefaults()
        }
    }
    
    function save() {
        Persistent.states.quickSettings.controls = root.activeControls
    }

    function add(id) {
        console.log("QuickControlsService: Adding " + id)
        if (findIndex(id) !== -1) return; 
        
        var currentCol = 0
        var maxCols = 4
        for (var i = 0; i < root.activeControls.length; i++) {
            var item = root.activeControls[i]
            var span = item.expanded ? 2 : 1
            
            if (currentCol + span > maxCols) {
                currentCol = 0
            }
            currentCol += span
        }
        
        var remaining = maxCols - currentCol
        var isExpanded = remaining >= 2
        
        var newControls = root.activeControls.slice() // Copy
        newControls.push({ "id": id, "expanded": isExpanded })
        root.activeControls = newControls
        save()
    }

    function remove(index) {
        if (index < 0 || index >= root.activeControls.length) return;
        var newControls = root.activeControls.slice()
        newControls.splice(index, 1)
        root.activeControls = newControls
        save()
    }

    function move(fromIndex, toIndex) {
        if (fromIndex < 0 || fromIndex >= root.activeControls.length) return;
        if (toIndex < 0 || toIndex >= root.activeControls.length) return;
        if (fromIndex === toIndex) return;

        var newControls = root.activeControls.slice()
        var item = newControls[fromIndex]
        newControls.splice(fromIndex, 1)
        newControls.splice(toIndex, 0, item)
        root.activeControls = newControls
        save()
    }

    function toggleSize(index) {
         if (index < 0 || index >= root.activeControls.length) return;
         var newControls = root.activeControls.slice()
         var oldItem = newControls[index]
         newControls[index] = { "id": oldItem.id, "expanded": !oldItem.expanded }
         root.activeControls = newControls
         save()
    }

    function getControl(index) {
        if (index < 0 || index >= activeControls.length) return null;
        return activeControls[index];
    }

    function resetDefaults() {
        root.activeControls = [
            { "id": "wifi", "expanded": true },
            { "id": "bluetooth", "expanded": true },
            { "id": "audio", "expanded": true },
            { "id": "airplane", "expanded": true }
        ]
        save()
    }

    Component.onCompleted: {
        if (Persistent.ready) {
            load()
        } else {
            Persistent.readyChanged.connect(load)
        }
    }
}

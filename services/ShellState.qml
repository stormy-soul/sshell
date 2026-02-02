pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    property bool masterVisible: true

    function toggle() {
        root.masterVisible = !root.masterVisible
    }
    
    function show() {
        root.masterVisible = true
    }
    
    function hide() {
        root.masterVisible = false
    }
    onMasterVisibleChanged: {
        if (!root.masterVisible) {
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} opacity 0 lock"])
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} no_blur on lock"])
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} no_anim on lock"])
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} no_shadow on lock"])


        } else {
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} opacity 1 lock"])
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} no_blur off lock"])
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} no_anim off lock"])
            Quickshell.execDetached(["bash", "-c", "hyprctl clients -j | jq -r '.[].address' | xargs -I {} hyprctl dispatch setprop address:{} no_shadow off lock"])
    }
    }
}

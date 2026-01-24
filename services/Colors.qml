pragma Singleton
import QtQuick
import Quickshell

Singleton {
    id: root

    function getLightness(color) {
        return 0.299 * color.r + 0.587 * color.g + 0.114 * color.b
    }

    function isDark(color) {
        return getLightness(color) < 0.5
    }

    function contrastingTextColor(backgroundColor) {
        return isDark(backgroundColor) ? "#ffffff" : "#000000"
    }
}

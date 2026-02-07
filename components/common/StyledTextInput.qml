import QtQuick
import QtQuick.Controls
import "../../settings"


TextInput {
    color: Appearance.colors.text
    renderType: Text.NativeRendering
    selectedTextColor: Appearance.colors.colOnSecondaryContainer
    selectionColor: Appearance.colors.colSecondaryContainer
    verticalAlignment: TextInput.AlignVCenter
    horizontalAlignment: TextInput.AlignHCenter
    
    font {
        family: Appearance.font.family.main
        pixelSize: Appearance.font.pixelSize.normal
        hintingPreference: Font.PreferFullHinting
    }
}

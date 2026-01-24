import QtQuick
import Quickshell
import Quickshell.Io
import "../../settings"

Image {
    id: root
    
    property string entryId
    property string entryContent
    
    property string imageDecodePath: Directories.cliphistDecode
    property string imageDecodeFileName: entryId + ".png"
    property string imageDecodeFilePath: imageDecodePath + "/" + imageDecodeFileName
    
    source: "file://" + imageDecodeFilePath
    fillMode: Image.PreserveAspectFit
    asynchronous: true
    cache: false // Don't cache as IDs might be reused or file might change? Probably safe to cache if ID is unique.

    Component.onCompleted: {
        decodeProc.running = true
    }
    
    Component.onDestruction: {
        // Cleanup? Reference does cleanup.
        cleanupProc.running = true
    }
    
    horizontalAlignment: Image.AlignLeft
    
    Process {
        id: decodeProc
        command: ["bash", "-c", "printf \"%s\\t%s\\n\" \"" + root.entryId + "\" \"" + root.entryContent + "\" | cliphist decode > " + root.imageDecodeFilePath]
        onExited: (exitCode, exitStatus) => {
            if (exitCode === 0) {
                var src = root.source
                root.source = ""
                root.source = src
            } else {
                console.warn("CliphistImage: Failed to decode", root.entryId)
            }
        }
    }
    
    Process {
        id: cleanupProc
        command: ["rm", "-f", root.imageDecodeFilePath]
    }
}

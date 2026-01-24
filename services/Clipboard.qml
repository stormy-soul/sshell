pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    property var entries: []
    
    function isImage(content) {
        return !!(/^\[\[ binary data.*\]\]$/.test(content))
    }
    
    function search(query) {
        proc.query = query
        proc.running = false
        proc.running = true
    }
    
    function copy(id) {
        copyProc.command = [Quickshell.shellPath("services/helpers/copy_clipboard_id.sh"), id]
        copyProc.running = true
    }
    
    Process {
        id: proc
        property string query: ""
        property var tempEntries: []
        
        command: [Quickshell.shellPath("services/helpers/get_clipboard.sh"), query]
        
        stdout: SplitParser {
            onRead: data => {
                var line = data
                if (!line) return
                
                var tabIndex = line.indexOf('\t')
                if (tabIndex === -1) return
                
                var id = line.substring(0, tabIndex)
                var content = line.substring(tabIndex + 1)
                
                proc.tempEntries.push({
                    type: "clipboard",
                    id: id,
                    content: content,
                    icon: "content_copy"
                })
            }
        }
        
        onExited: {
            console.log("Clipboard: Parsed " + proc.tempEntries.length + " entries")
            root.entries = proc.tempEntries
            proc.tempEntries = [] 
        }
    }
    
    Process {
        id: copyProc
    }
}

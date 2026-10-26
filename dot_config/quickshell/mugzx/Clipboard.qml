pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// Clipboard history (SUPER+C) from cliphist; mugzx-startup runs
// `wl-paste --watch cliphist store` for text and images.
Singleton {
    id: root

    property bool open: false
    property string screen: ""
    property var items: []                // { id, text, image }
    property bool available: true
    property int thumbsVersion: 0
    readonly property string thumbDir: Quickshell.env("XDG_RUNTIME_DIR") + "/mugzx-clip"

    function show() {
        Panels.close();
        Launcher.close();
        screen = Panels.focusedScreen();
        open = true;
        refresh();
    }

    function close() {
        open = false;
    }

    function toggle() {
        if (open)
            close();
        else
            show();
    }

    Connections {
        target: Panels
        function onCurrentChanged() {
            if (Panels.current !== "")
                root.close();
        }
    }

    function refresh() {
        if (!lister.running)
            lister.running = true;
    }

    Process {
        id: lister
        command: ["sh", "-c", "command -v cliphist >/dev/null || exit 127; exec cliphist list"]
        stdout: StdioCollector {
            onStreamFinished: root.parse(text)
        }
        onExited: (code) => root.available = code !== 127
    }

    function parse(text) {
        const out = [];
        for (const line of text.split("\n")) {
            const tab = line.indexOf("\t");
            if (tab <= 0)
                continue;
            const preview = line.slice(tab + 1);
            const bin = preview.match(/^\[\[ binary data (.+?) \]\]$/);
            out.push({
                id: line.slice(0, tab),
                text: bin ? bin[1] : preview,
                image: !!bin && /png|jpe?g|webp|gif|bmp/i.test(bin[1])
            });
            if (out.length >= 300)
                break;
        }
        items = out;
        decodeThumbs();
    }

    // Decode image entries once into $XDG_RUNTIME_DIR so the list can show them.
    Process {
        id: thumbs
        onExited: root.thumbsVersion++
    }

    function decodeThumbs() {
        const ids = items.filter(i => i.image).slice(0, 40).map(i => i.id);
        if (ids.length === 0 || thumbs.running)
            return;
        thumbs.command = ["sh", "-c",
            'dir=$1; shift; mkdir -p "$dir"; for id; do [ -s "$dir/$id" ] || cliphist decode "$id" > "$dir/$id"; done',
            "sh", thumbDir].concat(ids);
        thumbs.running = true;
    }

    function thumb(item) {
        return "file://" + thumbDir + "/" + item.id + "?v=" + thumbsVersion;
    }

    function filter(query) {
        const q = query.trim().toLowerCase();
        return q === "" ? items : items.filter(i => i.text.toLowerCase().includes(q));
    }

    function copy(item) {
        Quickshell.execDetached(["sh", "-c", 'cliphist decode "$1" | wl-copy', "sh", item.id]);
        close();
    }

    function remove(item) {
        Quickshell.execDetached(["sh", "-c", 'printf "%s\\t\\n" "$1" | cliphist delete', "sh", item.id]);
        items = items.filter(i => i.id !== item.id);
    }

    function wipe() {
        Quickshell.execDetached(["cliphist", "wipe"]);
        items = [];
    }
}

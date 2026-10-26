pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io

// App launcher (SUPER+D): opens on the focused screen, ranks matches by how
// well the name fits and by how often the app was started from here.
Singleton {
    id: root

    property bool open: false
    property string screen: ""

    function show() {
        Panels.close();
        Clipboard.close();
        screen = Panels.focusedScreen();
        open = true;
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

    // ---- launch counts
    FileView {
        id: historyFile
        path: Quickshell.env("HOME") + "/.local/state/mugzx/launcher-history.json"
        printErrors: false
    }

    readonly property var counts: {
        try {
            return JSON.parse(historyFile.text() || "{}");
        } catch (e) {
            return {};
        }
    }

    function run(entry) {
        if (!entry)
            return;
        const c = Object.assign({}, counts);
        c[entry.id] = (c[entry.id] || 0) + 1;
        historyFile.setText(JSON.stringify(c));
        Apps.launch(entry);
        close();
    }

    // ---- search
    readonly property var apps: DesktopEntries.applications.values.filter(e => !e.noDisplay)

    function subsequence(text, q) {
        let i = 0;
        for (const ch of text) {
            if (ch === q[i])
                i++;
            if (i === q.length)
                return true;
        }
        return false;
    }

    function score(e, q) {
        const name = (e.name || "").toLowerCase();
        if (name === q)
            return 100;
        if (name.startsWith(q))
            return 80;
        if (name.split(/[\s\-_.]+/).some(w => w.startsWith(q)))
            return 65;
        if (name.includes(q))
            return 50;
        const command = e.command && e.command.length > 0 ? e.command[0] : "";
        const extra = [e.genericName, e.id, command].concat(Array.from(e.keywords || [])).join(" ").toLowerCase();
        if (extra.includes(q))
            return 35;
        if (subsequence(name, q))
            return 20;
        return 0;
    }

    function search(query) {
        const q = query.trim().toLowerCase();
        const c = counts;
        if (q === "")
            return apps.slice().sort((a, b) => (c[b.id] || 0) - (c[a.id] || 0) || a.name.localeCompare(b.name));
        const hits = [];
        for (const e of apps) {
            const s = score(e, q);
            if (s > 0)
                hits.push({ e: e, s: s + Math.min(c[e.id] || 0, 15) * 2 });
        }
        hits.sort((a, b) => b.s - a.s || a.e.name.localeCompare(b.e.name));
        return hits.map(h => h.e);
    }
}

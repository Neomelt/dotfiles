import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland

// Bottom dock for one screen. Pinned apps and open windows are merged into one
// icon per app, matched through their .desktop entries; dots under an icon count
// its windows. Left click focuses (cycling through several windows) or launches,
// middle click opens a new window, right click opens DockMenu.
PanelWindow {
    id: dock

    required property var shellScreen

    readonly property int pad: 16           // shadow room left and right
    readonly property int tipRoom: 40       // see-through space above the card for tooltips
    readonly property int bottomGap: 6
    readonly property int cardHeight: 60
    readonly property int slot: 54
    readonly property int iconSize: 40
    readonly property int sidePad: 6

    // ---- pinned apps: one .desktop id per line, editable by hand
    FileView {
        id: pinnedFile
        path: Quickshell.env("HOME") + "/.config/mugzx/dock-pinned"
        watchChanges: true
        printErrors: false
        onFileChanged: reload()
    }

    readonly property var pinnedKeys: {
        DesktopEntries.applications.values;  // re-evaluate once .desktop files are scanned
        const out = [];
        for (const line of pinnedFile.text().split("\n")) {
            const id = line.trim();
            const e = id.length > 0 ? Apps.entryFor(id) : null;
            if (e && !out.includes(e.id))
                out.push(e.id);
        }
        return out;
    }

    // ---- windows, grouped by .desktop id (or the bare app id when there is none)
    readonly property var windows: Hyprland.toplevels.values

    function appIdOf(w) {
        return (w.wayland && w.wayland.appId) || (w.lastIpcObject && w.lastIpcObject["class"]) || "";
    }

    readonly property var windowKeys: {
        DesktopEntries.applications.values;
        return windows.map(w => {
            const id = appIdOf(w);
            const e = id ? DesktopEntries.heuristicLookup(id) : null;
            return e ? e.id : id;
        });
    }

    readonly property var keys: {
        const out = pinnedKeys.slice();
        for (const k of windowKeys)
            if (k && !out.includes(k))
                out.push(k);
        return out;
    }

    function windowsFor(key) {
        const out = [];
        for (let i = 0; i < windows.length; i++)
            if (windowKeys[i] === key)
                out.push(windows[i]);
        return out;
    }

    // The window to raise when an app that isn't focused is clicked.
    property var lastFocused: ({})
    Connections {
        target: Hyprland
        function onActiveToplevelChanged() {
            const i = dock.windows.indexOf(Hyprland.activeToplevel);
            if (i >= 0)
                dock.lastFocused[dock.windowKeys[i]] = Hyprland.activeToplevel;
        }
    }

    // ---- actions
    function focusWindow(w) {
        Hyprland.dispatch('hl.dsp.focus({ window = "address:0x' + w.address + '" })');
    }

    function closeWindow(w) {
        if (w.wayland)
            w.wayland.close();
    }

    function moveWindows(wins, ws) {
        for (const w of wins)
            Hyprland.dispatch('hl.dsp.window.move({ workspace = ' + ws + ', window = "address:0x' + w.address + '", follow = false })');
    }

    function launch(key) {
        Apps.launch(DesktopEntries.byId(key));
    }

    function activate(key) {
        const wins = windowsFor(key);
        if (wins.length === 0) {
            launch(key);
            return;
        }
        const cur = wins.indexOf(Hyprland.activeToplevel);
        const last = lastFocused[key];
        focusWindow(cur >= 0 ? wins[(cur + 1) % wins.length]
                  : wins.includes(last) ? last : wins[0]);
    }

    function setPinned(key, on) {
        const list = pinnedKeys.filter(k => k !== key);
        if (on)
            list.push(key);
        pinnedFile.setText(list.join("\n") + "\n");
    }

    // ---- right-click menu (DockMenu reads these)
    property string menuKey: ""
    property real menuX: 0                  // screen x of the icon the menu points at

    function openMenu(key, item) {
        menuX = (shellScreen.width - width) / 2 + item.mapToItem(null, item.width / 2, 0).x;
        menuKey = key;
    }

    function closeMenu() {
        menuKey = "";
    }

    onKeysChanged: if (menuKey !== "" && !keys.includes(menuKey)) closeMenu()

    // ---- window
    readonly property int cardWidth: Math.max(1, keys.length) * slot + 2 * sidePad

    screen: shellScreen
    anchors.bottom: true
    exclusiveZone: cardHeight + bottomGap
    implicitWidth: cardWidth + 2 * pad
    implicitHeight: tipRoom + cardHeight + bottomGap
    color: "transparent"
    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "mugzx-dock"

    // Only the card takes input; the shadow and tooltip space are click-through.
    mask: Region { item: card }

    Surface {
        id: card
        x: dock.pad
        y: dock.tipRoom
        width: dock.cardWidth
        height: dock.cardHeight
        radius: 16

        Row {
            x: dock.sidePad

            Repeater {
                model: ScriptModel { values: dock.keys }

                // Named `host`, not `dock`: inside a delegate, `dock: dock` would bind the property to itself.
                DockItem {
                    required property string modelData
                    appKey: modelData
                    host: dock
                }
            }
        }
    }

    DockMenu { dock: dock }
}

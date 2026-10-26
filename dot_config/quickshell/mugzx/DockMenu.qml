import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Right-click menu for a dock app, floating just above the dock. Same look and
// close behaviour as the bar's panels: click outside or press Esc to close.
PanelWindow {
    id: win

    required property var dock

    readonly property int pad: 16
    readonly property int menuWidth: 260
    readonly property bool shown: dock.menuKey !== ""
    property bool mapped: false

    // Keep showing the last app while the close animation runs.
    property string key: ""
    readonly property var entry: key ? DesktopEntries.byId(key) : null
    readonly property var wins: key ? dock.windowsFor(key) : []
    readonly property bool pinned: dock.pinnedKeys.includes(key)
    readonly property var extraActions: entry ? Array.from(entry.actions).filter(a => a.id !== "new-window") : []

    readonly property int maxWorkspace: {
        let m = 5;
        for (const ws of Hyprland.workspaces.values)
            if (ws.id > m && ws.id <= 10)
                m = ws.id;
        return m;
    }

    onShownChanged: {
        if (shown) {
            key = dock.menuKey;
            mapped = true;
            unmapTimer.stop();
        } else {
            unmapTimer.restart();
        }
    }

    Connections {
        target: win.dock
        function onMenuKeyChanged() {
            if (win.dock.menuKey !== "")
                win.key = win.dock.menuKey;
        }
    }

    Connections {
        target: Panels
        function onCurrentChanged() {
            if (Panels.current !== "")
                win.dock.closeMenu();
        }
    }

    Timer {
        id: unmapTimer
        interval: Theme.anim + 40
        onTriggered: win.mapped = false
    }

    function act(fn) {
        fn();
        dock.closeMenu();
    }

    screen: dock.shellScreen
    visible: shown || mapped
    color: "transparent"
    anchors.bottom: true
    anchors.left: true
    exclusionMode: ExclusionMode.Ignore
    margins.bottom: dock.cardHeight + dock.bottomGap + Theme.barGap - pad
    margins.left: {
        const sw = dock.shellScreen.width;
        const left = Math.max(Theme.barGap, Math.min(sw - menuWidth - Theme.barGap, dock.menuX - menuWidth / 2));
        return Math.max(0, Math.round(left - pad));
    }
    implicitWidth: menuWidth + 2 * pad
    implicitHeight: column.implicitHeight + 2 * Theme.panelPadding + 2 * pad

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "mugzx-dock-menu"
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None

    mask: Region { item: card }

    // The dock is part of the grab, so right-clicking another icon switches the menu.
    HyprlandFocusGrab {
        active: win.shown
        windows: [win, win.dock]
        onCleared: win.dock.closeMenu()
    }

    Shortcut {
        sequence: "Escape"
        enabled: win.shown
        onActivated: win.dock.closeMenu()
    }

    Surface {
        id: card
        x: win.pad
        y: win.pad
        width: win.menuWidth
        height: win.height - 2 * win.pad
        opacity: win.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.anim } }

        transform: Translate {
            y: win.shown ? 0 : 6
            Behavior on y { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
        }

        Column {
            id: column
            x: Theme.panelPadding
            y: Theme.panelPadding
            width: win.menuWidth - 2 * Theme.panelPadding
            spacing: 4

            PanelHeader {
                width: parent.width
                title: win.entry ? win.entry.name : win.key
            }

            // ---- open windows
            SectionLabel {
                visible: win.wins.length > 0
                text: win.wins.length > 1 ? win.wins.length + " 个窗口" : "窗口"
            }

            Repeater {
                model: win.wins

                ListRow {
                    required property var modelData
                    width: column.width
                    icon: "app-window"
                    title: modelData.title || win.key
                    subtitle: modelData.workspace ? "工作区 " + modelData.workspace.id : ""
                    selected: modelData === Hyprland.activeToplevel
                    onClicked: win.act(() => win.dock.focusWindow(modelData))

                    IconButton {
                        icon: "x"
                        iconSize: 12
                        tint: Theme.textDim
                        onClicked: win.dock.closeWindow(modelData)
                    }
                }
            }

            // ---- move to workspace
            SectionLabel {
                visible: win.wins.length > 0
                text: win.wins.length > 1 ? "全部移到工作区" : "移到工作区"
            }

            Row {
                visible: win.wins.length > 0
                spacing: 4

                Repeater {
                    model: win.maxWorkspace

                    Rectangle {
                        id: chip
                        required property int index
                        readonly property int wsId: index + 1
                        readonly property bool here: win.wins.length > 0 && win.wins.every(w => w.workspace && w.workspace.id === wsId)
                        width: 24
                        height: 24
                        radius: 7
                        color: here ? Theme.surfaceActive : chipArea.containsMouse ? Theme.surfaceHover : Theme.surface
                        Behavior on color { ColorAnimation { duration: Theme.anim } }

                        Text {
                            anchors.centerIn: parent
                            text: chip.wsId
                            color: chip.here ? Theme.accent : Theme.text
                            font.family: Theme.mono
                            font.pixelSize: Theme.fontSmall
                        }

                        MouseArea {
                            id: chipArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: win.act(() => win.dock.moveWindows(win.wins, chip.wsId))
                        }
                    }
                }
            }

            Item { width: 1; height: 4; visible: win.wins.length > 0 }

            // ---- app actions
            ListRow {
                width: column.width
                visible: !!win.entry
                icon: "plus"
                title: "新建窗口"
                onClicked: win.act(() => win.dock.launch(win.key))
            }

            Repeater {
                model: win.extraActions

                ListRow {
                    required property var modelData
                    width: column.width
                    icon: "external"
                    title: modelData.name
                    onClicked: win.act(() => modelData.execute())
                }
            }

            ListRow {
                width: column.width
                visible: !!win.entry
                icon: win.pinned ? "pin-off" : "pin"
                title: win.pinned ? "从 Dock 取消固定" : "固定到 Dock"
                onClicked: win.act(() => win.dock.setPinned(win.key, !win.pinned))
            }

            ListRow {
                width: column.width
                visible: win.wins.length > 0
                icon: "x"
                title: win.wins.length > 1 ? "关闭全部 " + win.wins.length + " 个窗口" : "关闭窗口"
                onClicked: win.act(() => win.wins.forEach(w => win.dock.closeWindow(w)))
            }
        }
    }
}

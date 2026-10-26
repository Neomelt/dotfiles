import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland
import Quickshell.Services.SystemTray

// The top bar for one screen. Three sections, and the left and right ones
// are given the same width so the clock is always centred and nothing can
// slide under it. Auto-hides like before: it shows while the top hot edge or
// the bar is hovered, or while one of its panels is open.
PanelWindow {
    id: bar

    required property var shellScreen
    property bool hotHovered: false

    readonly property int pad: 16                 // shadow room (sides, bottom)
    readonly property int sidePad: 8
    readonly property int sectionGap: 18
    readonly property int mediaWidth: 170

    // nm-applet's icon duplicates the bar's own Wi-Fi button.
    readonly property var trayItems: SystemTray.items.values.filter(i => i.id !== "nm-applet")

    // ---- reveal / hide
    readonly property bool panelOpen: Panels.current !== "" && Panels.screen === shellScreen.name
    property bool barHovered: false
    property bool intro: true
    property int menusOpen: 0
    // The SwayNC notification centre hangs below the bar, so keep the bar up with it.
    readonly property bool wanted: intro || hotHovered || barHovered || panelOpen || menusOpen > 0
                                   || System.notifCenterOpen
    property bool revealed: true
    property bool mapped: true

    onWantedChanged: {
        if (wanted) {
            hideTimer.stop();
            revealed = true;
        } else {
            hideTimer.restart();
        }
    }
    onRevealedChanged: {
        if (revealed) {
            unmapTimer.stop();
            mapped = true;
        } else {
            unmapTimer.restart();
        }
    }

    Timer { interval: 1400; running: true; onTriggered: bar.intro = false }
    Timer { id: hideTimer; interval: 1200; onTriggered: if (!bar.wanted) bar.revealed = false }
    Timer { id: unmapTimer; interval: Theme.anim + 40; onTriggered: bar.mapped = false }

    // ---- size: symmetric sections around the clock
    readonly property real available: shellScreen.width - 2 * Theme.barGap
    function widthFor(leftW) {
        return Math.ceil(2 * Math.max(leftW, right.implicitWidth) + clock.implicitWidth + 2 * sectionGap + 2 * sidePad);
    }
    readonly property bool showMedia: !!Media.player
        && widthFor(workspaces.implicitWidth + left.spacing + mediaWidth) <= available
    readonly property int targetWidth: Math.min(available, widthFor(left.implicitWidth))

    screen: shellScreen
    visible: mapped
    color: "transparent"
    exclusiveZone: 0
    anchors.top: true
    implicitWidth: targetWidth + 2 * pad
    implicitHeight: Theme.barGap + Theme.barHeight + pad

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "mugzx-shell"

    mask: Region { item: card }

    Surface {
        id: card
        x: bar.pad
        y: Theme.barGap
        width: bar.targetWidth
        height: Theme.barHeight
        radius: Theme.barRadius
        opacity: bar.revealed ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.anim } }

        HoverHandler {
            onHoveredChanged: bar.barHovered = hovered
        }

        // ---- left: workspaces, now playing
        Row {
            id: left
            anchors.left: parent.left
            anchors.leftMargin: bar.sidePad + 2
            anchors.verticalCenter: parent.verticalCenter
            spacing: 8

            Workspaces {
                id: workspaces
                anchors.verticalCenter: parent.verticalCenter
                shellScreen: bar.shellScreen
            }

            Item {
                id: media
                visible: bar.showMedia
                width: bar.mediaWidth
                height: 27
                anchors.verticalCenter: parent.verticalCenter
                readonly property bool active: Panels.isOpen("media", bar.shellScreen.name)

                Rectangle {
                    anchors.fill: parent
                    radius: 7
                    color: media.active ? Theme.surfaceActive : mediaArea.containsMouse ? Theme.surfaceHover : "transparent"
                    Behavior on color { ColorAnimation { duration: Theme.anim } }
                }

                Icon {
                    id: mediaIcon
                    anchors.left: parent.left
                    anchors.leftMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    name: Media.player && Media.player.isPlaying ? "music" : "pause"
                    size: 12
                    color: media.active ? Theme.accent : Theme.textDim
                }

                Text {
                    anchors.left: mediaIcon.right
                    anchors.leftMargin: 7
                    anchors.right: parent.right
                    anchors.rightMargin: 7
                    anchors.verticalCenter: parent.verticalCenter
                    text: Media.artist ? Media.title + " · " + Media.artist : Media.title
                    color: Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                    elide: Text.ElideRight
                }

                MouseArea {
                    id: mediaArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                    onClicked: (mouse) => {
                        if (mouse.button === Qt.MiddleButton) {
                            if (Media.player) Media.player.togglePlaying();
                        } else {
                            Panels.toggle("media", bar.shellScreen.name);
                        }
                    }
                }
            }
        }

        // ---- centre: clock -> calendar
        Item {
            id: clock
            anchors.centerIn: parent
            implicitWidth: clockRow.implicitWidth + 16
            implicitHeight: 27
            width: implicitWidth
            height: implicitHeight
            readonly property bool active: Panels.isOpen("calendar", bar.shellScreen.name)

            SystemClock {
                id: time
                precision: SystemClock.Minutes
            }

            Rectangle {
                anchors.fill: parent
                radius: 7
                color: clock.active ? Theme.surfaceActive : clockArea.containsMouse ? Theme.surfaceHover : "transparent"
                Behavior on color { ColorAnimation { duration: Theme.anim } }
            }

            Row {
                id: clockRow
                anchors.centerIn: parent
                spacing: 8

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: (time.date.getMonth() + 1) + "月" + time.date.getDate() + "日 周" + "日一二三四五六"[time.date.getDay()]
                    color: Theme.textDim
                    font.family: Theme.font
                    font.pixelSize: Theme.fontSmall
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: Qt.formatDateTime(time.date, "HH:mm")
                    color: clock.active ? Theme.accent : Theme.text
                    font.family: Theme.mono
                    font.pixelSize: Theme.fontBody
                    font.weight: Font.Bold
                }
            }

            MouseArea {
                id: clockArea
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: Panels.toggle("calendar", bar.shellScreen.name)
            }
        }

        // ---- right: tray, status buttons, battery, power
        Row {
            id: right
            anchors.right: parent.right
            anchors.rightMargin: bar.sidePad
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2

            Repeater {
                model: bar.trayItems

                Item {
                    id: trayItem
                    required property var modelData
                    width: 24
                    height: 27
                    anchors.verticalCenter: parent.verticalCenter

                    Rectangle {
                        anchors.fill: parent
                        radius: 7
                        color: trayArea.containsMouse ? Theme.surfaceHover : "transparent"
                    }

                    Image {
                        id: trayIcon
                        anchors.centerIn: parent
                        width: 15
                        height: 15
                        source: trayItem.modelData.icon
                        sourceSize.width: 30
                        sourceSize.height: 30
                        fillMode: Image.PreserveAspectFit
                        smooth: true
                    }

                    MouseArea {
                        id: trayArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                        onClicked: (mouse) => {
                            Panels.close();
                            const item = trayItem.modelData;
                            if (mouse.button === Qt.LeftButton && !item.onlyMenu)
                                item.activate();
                            else if (mouse.button === Qt.MiddleButton)
                                item.secondaryActivate();
                            else if (item.hasMenu)
                                trayMenu.open();
                        }
                    }

                    QsMenuAnchor {
                        id: trayMenu
                        menu: trayItem.modelData.menu
                        anchor.item: trayIcon
                        anchor.edges: Edges.Bottom
                        anchor.gravity: Edges.Bottom
                        // Keep the bar (the menu's parent) mapped while it is open.
                        onOpened: bar.menusOpen++
                        onClosed: bar.menusOpen = Math.max(0, bar.menusOpen - 1)
                    }
                }
            }

            // divider between app tray icons and system buttons
            Item {
                visible: bar.trayItems.length > 0
                width: 9
                height: 27
                anchors.verticalCenter: parent.verticalCenter

                Rectangle {
                    anchors.centerIn: parent
                    width: 1
                    height: 14
                    color: Theme.track
                }
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: !Net.wifiEnabled ? "wifi-off" : Net.wiredConnected && !Net.wifiConnected ? "ethernet" : "wifi"
                tint: Net.wifiConnected || Net.wiredConnected ? Theme.text : Theme.textFaint
                active: Panels.isOpen("wifi", bar.shellScreen.name)
                onClicked: Panels.toggle("wifi", bar.shellScreen.name)
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: Audio.sinkMuted || Audio.sinkVolume === 0 ? "volume-x" : Audio.sinkVolume < 0.5 ? "volume-low" : "volume"
                tint: Audio.sinkMuted ? Theme.textFaint : Theme.text
                active: Panels.isOpen("volume", bar.shellScreen.name)
                onClicked: (button) => {
                    if (button === Qt.LeftButton)
                        Panels.toggle("volume", bar.shellScreen.name);
                    else
                        Audio.toggleMute(Audio.sink);
                }
                onScrolled: (steps) => Audio.nudgeSink(steps * 0.05)
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: System.dnd ? "bell-off" : "bell"
                tint: System.dnd ? Theme.textFaint : Theme.text
                badge: System.notifCount > 0 && !System.dnd
                onClicked: { Panels.close(); System.toggleNotificationCenter(); }
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "settings"
                active: Panels.isOpen("control", bar.shellScreen.name)
                onClicked: Panels.toggle("control", bar.shellScreen.name)
            }

            BatteryIndicator {
                anchors.verticalCenter: parent.verticalCenter
                onClicked: Panels.toggle("control", bar.shellScreen.name)
            }

            IconButton {
                anchors.verticalCenter: parent.verticalCenter
                icon: "power"
                active: Panels.isOpen("power", bar.shellScreen.name)
                onClicked: Panels.toggle("power", bar.shellScreen.name)
            }
        }
    }
}

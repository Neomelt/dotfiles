import QtQuick
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Centred search popup with a result list; the launcher and the clipboard
// history use it. Type to filter, Up/Down (Tab, Ctrl+J/K) to move, Enter to
// pick, Shift+Delete to remove, Esc or a click outside to close.
PanelWindow {
    id: win

    required property var shellScreen
    property bool shown: false
    property string icon: "search"
    property string placeholder
    property string emptyText: "没有结果"
    property string hint
    property var model: []
    property Component delegate
    property int rowHeight: 44
    property int maxRows: 8
    property int panelWidth: 540
    property int currentIndex: 0
    property alias query: input.text
    default property alias footerActions: actionRow.data

    signal accepted(int index)
    signal removeRequested(int index)
    signal dismissed()

    readonly property int pad: 16
    readonly property int count: model ? model.length : 0
    readonly property int searchHeight: 50
    readonly property int footerHeight: 32
    readonly property int bodyHeight: count > 0 ? Math.min(count, maxRows) * rowHeight + 12 : 52
    property bool mapped: false

    onShownChanged: {
        if (shown) {
            query = "";
            currentIndex = 0;
            mapped = true;
            unmapTimer.stop();
            input.forceActiveFocus();
        } else {
            unmapTimer.restart();
        }
    }
    onQueryChanged: currentIndex = 0
    onCountChanged: if (currentIndex >= count) currentIndex = Math.max(0, count - 1)
    onCurrentIndexChanged: list.positionViewAtIndex(currentIndex, ListView.Contain)

    function move(step) {
        if (count === 0)
            return;
        if (Math.abs(step) === 1)
            currentIndex = (currentIndex + step + count) % count;
        else
            currentIndex = Math.max(0, Math.min(count - 1, currentIndex + step));
    }

    Timer {
        id: unmapTimer
        interval: Theme.anim + 40
        onTriggered: win.mapped = false
    }

    screen: shellScreen
    visible: shown || mapped
    color: "transparent"
    anchors.top: true
    exclusionMode: ExclusionMode.Ignore
    margins.top: Math.round(shellScreen.height * 0.18) - pad
    implicitWidth: panelWidth + 2 * pad
    // Fixed at the tallest size so the window never resizes while typing; the card shrinks instead.
    implicitHeight: searchHeight + maxRows * rowHeight + 12 + footerHeight + 2 + 2 * pad

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.namespace: "mugzx-search"
    WlrLayershell.keyboardFocus: shown ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    mask: Region { item: card }

    HyprlandFocusGrab {
        active: win.shown
        windows: [win]
        onCleared: if (win.shown) win.dismissed()
    }

    Surface {
        id: card
        x: win.pad
        y: win.pad
        width: win.panelWidth
        height: win.searchHeight + 1 + win.bodyHeight + 1 + win.footerHeight
        radius: 16
        opacity: win.shown ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: Theme.anim } }
        Behavior on height { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }

        transform: Translate {
            y: win.shown ? 0 : -8
            Behavior on y { NumberAnimation { duration: Theme.anim; easing.type: Easing.OutCubic } }
        }

        // ---- search field
        Item {
            id: search
            width: parent.width
            height: win.searchHeight

            Icon {
                id: searchIcon
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                name: win.icon
                size: 17
                color: input.text.length > 0 ? Theme.accent : Theme.textDim
            }

            TextInput {
                id: input
                anchors.left: searchIcon.right
                anchors.leftMargin: 12
                anchors.right: parent.right
                anchors.rightMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                color: Theme.text
                selectionColor: Theme.surfaceActive
                selectedTextColor: Theme.text
                font.family: Theme.font
                font.pixelSize: 15
                clip: true

                Text {
                    anchors.fill: parent
                    visible: input.text.length === 0
                    text: win.placeholder
                    color: Theme.textFaint
                    font: input.font
                    verticalAlignment: Text.AlignVCenter
                }

                Keys.onPressed: (event) => {
                    const ctrl = event.modifiers & Qt.ControlModifier;
                    const k = event.key;
                    if (k === Qt.Key_Down || k === Qt.Key_Tab || (ctrl && (k === Qt.Key_J || k === Qt.Key_N)))
                        win.move(1);
                    else if (k === Qt.Key_Up || k === Qt.Key_Backtab || (ctrl && (k === Qt.Key_K || k === Qt.Key_P)))
                        win.move(-1);
                    else if (k === Qt.Key_PageDown)
                        win.move(win.maxRows);
                    else if (k === Qt.Key_PageUp)
                        win.move(-win.maxRows);
                    else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
                        if (win.count > 0)
                            win.accepted(win.currentIndex);
                    } else if (k === Qt.Key_Delete && (event.modifiers & Qt.ShiftModifier)) {
                        if (win.count > 0)
                            win.removeRequested(win.currentIndex);
                    } else if (k === Qt.Key_Escape)
                        win.dismissed();
                    else
                        return;
                    event.accepted = true;
                }
            }
        }

        Rectangle {
            y: win.searchHeight
            width: parent.width
            height: 1
            color: Theme.track
        }

        // ---- results
        ListView {
            id: list
            y: win.searchHeight + 1
            width: parent.width
            height: win.bodyHeight
            visible: win.count > 0
            clip: true
            model: win.model
            delegate: win.delegate
            currentIndex: win.currentIndex
            highlightFollowsCurrentItem: false
            boundsBehavior: Flickable.StopAtBounds
            topMargin: 6
            bottomMargin: 6
            leftMargin: 8
            rightMargin: 8
        }

        Text {
            y: win.searchHeight + 1
            width: parent.width
            height: win.bodyHeight
            visible: win.count === 0
            text: win.emptyText
            color: Theme.textFaint
            font.family: Theme.font
            font.pixelSize: Theme.fontBody
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Rectangle {
            y: win.searchHeight + 1 + win.bodyHeight
            width: parent.width
            height: 1
            color: Theme.track
        }

        // ---- footer: key hints and optional actions
        Item {
            y: win.searchHeight + 2 + win.bodyHeight
            width: parent.width
            height: win.footerHeight

            Text {
                anchors.left: parent.left
                anchors.leftMargin: 18
                anchors.verticalCenter: parent.verticalCenter
                text: win.hint
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
            }

            Row {
                id: actionRow
                anchors.right: parent.right
                anchors.rightMargin: 10
                anchors.verticalCenter: parent.verticalCenter
                spacing: 6
            }
        }
    }
}

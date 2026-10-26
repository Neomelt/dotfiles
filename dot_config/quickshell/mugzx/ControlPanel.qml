import QtQuick
import Quickshell

// Settings: brightness and volume, quick toggles, and links to full settings.
Popup {
    id: root

    name: "control"
    align: "right"

    onOpened: {
        System.refreshBrightness();
        System.refreshRecording();
    }

    PanelHeader {
        width: parent.width
        title: "设置"

        IconButton {
            icon: "external"
            iconSize: 14
            tint: Theme.textDim
            onClicked: { Panels.close(); System.systemSettings(); }
        }
    }

    SliderRow {
        width: parent.width
        visible: System.hasBacklight
        icon: "sun"
        value: System.brightness
        onMoved: (v) => System.setBrightness(Math.max(0.01, v))
    }

    SliderRow {
        width: parent.width
        icon: Audio.sinkMuted || Audio.sinkVolume === 0 ? "volume-x" : Audio.sinkVolume < 0.5 ? "volume-low" : "volume"
        value: Audio.sinkVolume
        muted: Audio.sinkMuted
        enabled: Audio.sinkReady
        onIconClicked: Audio.toggleMute(Audio.sink)
        onMoved: (v) => Audio.setVolume(Audio.sink, v)
    }

    Grid {
        width: parent.width
        columns: 2
        spacing: 6

        readonly property real cell: (width - spacing) / 2

        QuickToggle {
            width: parent.cell
            icon: Net.wifiEnabled ? "wifi" : "wifi-off"
            title: "Wi-Fi"
            checked: Net.wifiEnabled
            onClicked: Net.setWifiEnabled(!Net.wifiEnabled)
        }

        QuickToggle {
            width: parent.cell
            icon: System.dnd ? "bell-off" : "bell"
            title: "勿扰"
            checked: System.dnd
            onClicked: System.toggleDnd()
        }

        QuickToggle {
            width: parent.cell
            icon: "coffee"
            title: "保持亮屏"
            checked: System.keepAwake
            onClicked: System.keepAwake = !System.keepAwake
        }

        QuickToggle {
            width: parent.cell
            icon: "record"
            title: System.recording ? "停止录屏" : "录屏"
            checked: System.recording
            onClicked: { Panels.close(); System.toggleRecording(); }
        }
    }

    Column {
        width: parent.width
        spacing: 2

        ListRow {
            width: parent.width
            icon: "camera"
            title: "区域截图"
            onClicked: { Panels.close(); System.screenshot(); }
        }

        ListRow {
            width: parent.width
            icon: "bell"
            title: "通知中心"
            subtitle: System.notifCount > 0 ? System.notifCount + " 条通知" : ""
            onClicked: { Panels.close(); System.toggleNotificationCenter(); }
        }

        ListRow {
            width: parent.width
            icon: "keyboard"
            title: "快捷键"
            onClicked: { Panels.close(); System.keybinds(); }

            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: "F1"
                color: Theme.textFaint
                font.family: Theme.mono
                font.pixelSize: Theme.fontSmall
            }
        }

        ListRow {
            width: parent.width
            icon: "sliders"
            title: "系统设置"
            onClicked: { Panels.close(); System.systemSettings(); }
        }
    }
}

import QtQuick
import Quickshell

// Volume: output and input level, device pickers, and per-app levels.
Popup {
    id: root

    name: "volume"
    align: "right"

    property bool outputsOpen: false
    property bool inputsOpen: false

    onOpened: {
        outputsOpen = false;
        inputsOpen = false;
    }

    PanelHeader {
        width: parent.width
        title: "声音"

        IconButton {
            icon: "sliders"
            iconSize: 14
            tint: Theme.textDim
            onClicked: { Panels.close(); System.soundSettings(); }
        }
    }

    // ---- output
    SectionLabel { text: "输出" }

    SliderRow {
        width: parent.width
        icon: Audio.sinkMuted || Audio.sinkVolume === 0 ? "volume-x" : Audio.sinkVolume < 0.5 ? "volume-low" : "volume"
        value: Audio.sinkVolume
        muted: Audio.sinkMuted
        enabled: Audio.sinkReady
        onIconClicked: Audio.toggleMute(Audio.sink)
        onMoved: (v) => Audio.setVolume(Audio.sink, v)
    }

    ListRow {
        width: parent.width
        icon: Audio.deviceIcon(Audio.sink)
        title: Audio.sink ? Audio.deviceTitle(Audio.sink) : "没有输出设备"
        subtitle: Audio.sinks.length > 1 ? "点击切换输出设备" : ""
        interactive: Audio.sinks.length > 1
        onClicked: root.outputsOpen = !root.outputsOpen

        Icon {
            visible: Audio.sinks.length > 1
            name: root.outputsOpen ? "chevron-up" : "chevron-down"
            size: 14
            color: Theme.textDim
        }
    }

    Column {
        width: parent.width
        visible: root.outputsOpen
        spacing: 2

        Repeater {
            model: Audio.sinks

            ListRow {
                id: deviceRow
                required property var modelData
                width: parent.width
                icon: Audio.deviceIcon(modelData)
                title: Audio.deviceTitle(modelData)
                subtitle: modelData.description || ""
                selected: modelData === Audio.sink
                onClicked: { Audio.setDefault(modelData); root.outputsOpen = false; }

                Icon {
                    visible: deviceRow.selected
                    name: "check"
                    size: 14
                    color: Theme.accent
                }
            }
        }
    }

    // ---- input
    SectionLabel { text: "输入" }

    SliderRow {
        width: parent.width
        icon: Audio.sourceMuted ? "mic-off" : "mic"
        value: Audio.sourceVolume
        muted: Audio.sourceMuted
        enabled: Audio.sourceReady
        onIconClicked: Audio.toggleMute(Audio.source)
        onMoved: (v) => Audio.setVolume(Audio.source, v)
    }

    ListRow {
        width: parent.width
        visible: Audio.sources.length > 1
        icon: "mic"
        title: Audio.deviceTitle(Audio.source)
        subtitle: "点击切换输入设备"
        onClicked: root.inputsOpen = !root.inputsOpen

        Icon {
            name: root.inputsOpen ? "chevron-up" : "chevron-down"
            size: 14
            color: Theme.textDim
        }
    }

    Column {
        width: parent.width
        visible: root.inputsOpen
        spacing: 2

        Repeater {
            model: Audio.sources

            ListRow {
                id: deviceRow
                required property var modelData
                width: parent.width
                icon: "mic"
                title: Audio.deviceTitle(modelData)
                subtitle: modelData.description || ""
                selected: modelData === Audio.source
                onClicked: { Audio.setDefault(modelData); root.inputsOpen = false; }

                Icon {
                    visible: deviceRow.selected
                    name: "check"
                    size: 14
                    color: Theme.accent
                }
            }
        }
    }

    // ---- per-app
    SectionLabel {
        visible: Audio.streams.length > 0
        text: "应用"
    }

    Repeater {
        model: Audio.streams

        SliderRow {
            required property var modelData
            readonly property bool ready: !!(modelData && modelData.audio)
            width: parent.width
            label: Audio.streamTitle(modelData) + (Audio.streamSubtitle(modelData) ? " · " + Audio.streamSubtitle(modelData) : "")
            image: Audio.streamIcon(modelData)
            icon: "music"
            value: ready ? modelData.audio.volume : 0
            muted: ready ? modelData.audio.muted : false
            enabled: ready
            onIconClicked: Audio.toggleMute(modelData)
            onMoved: (v) => Audio.setVolume(modelData, v)
        }
    }

    Text {
        width: parent.width
        visible: Audio.streams.length === 0
        text: "没有正在播放声音的应用"
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        horizontalAlignment: Text.AlignHCenter
        topPadding: 2
        bottomPadding: 2
    }
}

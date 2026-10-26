pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

// PipeWire state for the bar icon and the volume panel. Nodes only report
// volume and properties while tracked, so the defaults are always tracked and
// everything else only while the volume panel is open (trackAll).
Singleton {
    id: root

    readonly property bool trackAll: Panels.current === "volume"

    readonly property var sink: Pipewire.defaultAudioSink
    readonly property var source: Pipewire.defaultAudioSource

    readonly property bool sinkReady: !!(sink && sink.audio)
    readonly property real sinkVolume: sinkReady ? sink.audio.volume : 0
    readonly property bool sinkMuted: sinkReady ? sink.audio.muted : false

    readonly property bool sourceReady: !!(source && source.audio)
    readonly property real sourceVolume: sourceReady ? source.audio.volume : 0
    readonly property bool sourceMuted: sourceReady ? source.audio.muted : false

    readonly property var nodes: Pipewire.nodes.values
    readonly property var sinks: nodes.filter(n => n.type === PwNodeType.AudioSink)
    readonly property var sources: nodes.filter(n => n.type === PwNodeType.AudioSource)
    readonly property var streams: nodes.filter(n => n.type === PwNodeType.AudioOutStream)

    PwObjectTracker {
        objects: [root.sink, root.source].filter(n => !!n)
    }

    PwObjectTracker {
        objects: root.trackAll ? root.sinks.concat(root.sources, root.streams) : []
    }

    function setVolume(node, v) {
        if (!node || !node.audio)
            return;
        if (v > 0 && node.audio.muted)
            node.audio.muted = false;
        node.audio.volume = Math.max(0, v);
    }

    function toggleMute(node) {
        if (node && node.audio)
            node.audio.muted = !node.audio.muted;
    }

    // Scroll on the bar icon. Stops at 100% unless the volume keys already
    // pushed it past that (they allow up to 150%).
    function nudgeSink(delta) {
        if (!sinkReady)
            return;
        const max = sinkVolume > 1.001 ? 1.5 : 1;
        setVolume(sink, Math.round(Math.max(0, Math.min(max, sinkVolume + delta)) * 100) / 100);
    }

    function setDefault(node) {
        if (!node)
            return;
        if (node.type === PwNodeType.AudioSink)
            Pipewire.preferredDefaultAudioSink = node;
        else if (node.type === PwNodeType.AudioSource)
            Pipewire.preferredDefaultAudioSource = node;
    }

    function percent(v) {
        return Math.round(v * 100) + "%";
    }

    function kind(node) {
        const name = (node && node.name) || "";
        if (name.startsWith("bluez_"))
            return "bluetooth";
        if (name.indexOf("hdmi") >= 0 || name.indexOf("iec958") >= 0)
            return "hdmi";
        if (name.indexOf("usb") >= 0)
            return "usb";
        return "builtin";
    }

    function deviceIcon(node) {
        if (node && node.type === PwNodeType.AudioSource)
            return "mic";
        switch (kind(node)) {
        case "bluetooth": return "headphones";
        case "hdmi": return "monitor";
        default: return "volume";
        }
    }

    function deviceTitle(node) {
        if (!node)
            return "";
        const k = kind(node);
        if (node.type === PwNodeType.AudioSource)
            return k === "builtin" ? "内置麦克风" : (node.description || node.name);
        if (k === "hdmi")
            return "HDMI 显示器";
        if (k === "builtin")
            return "扬声器 / 耳机";
        return node.description || node.name;
    }

    function streamTitle(node) {
        const p = (node && node.properties) || {};
        return p["application.name"] || node.description || node.name || "未知应用";
    }

    function streamSubtitle(node) {
        const p = (node && node.properties) || {};
        const media = p["media.name"] || "";
        return media === streamTitle(node) ? "" : media;
    }

    function streamIcon(node) {
        const p = (node && node.properties) || {};
        const candidates = [p["application.icon-name"], p["application.process.binary"], p["application.name"]];
        for (let i = 0; i < candidates.length; i++) {
            if (!candidates[i])
                continue;
            const path = Quickshell.iconPath(String(candidates[i]).toLowerCase(), true);
            if (path)
                return path;
        }
        return "";
    }
}

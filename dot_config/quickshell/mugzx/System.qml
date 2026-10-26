pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

// Notifications (SwayNC), backlight, screen recording and session actions.
Singleton {
    id: root

    readonly property string bin: Quickshell.env("HOME") + "/.local/bin/"

    // ---- notifications: `swaync-client -s` prints one JSON line per change
    property int notifCount: 0
    property bool dnd: false
    property bool notifCenterOpen: false

    Process {
        id: notifWatch
        // pdeathsig: exit with the shell instead of lingering after a restart.
        command: ["setpriv", "--pdeathsig", "TERM", "swaync-client", "-s"]
        running: true
        stdout: SplitParser {
            onRead: (line) => {
                try {
                    const j = JSON.parse(line);
                    root.notifCount = j.count || 0;
                    root.dnd = !!j.dnd;
                    root.notifCenterOpen = !!j.visible;
                } catch (e) {}
            }
        }
        onExited: notifRestart.start()
    }

    Timer {
        id: notifRestart
        interval: 3000
        onTriggered: notifWatch.running = true
    }

    function toggleDnd() {
        Quickshell.execDetached(["swaync-client", "-d", "-sw"]);
    }

    function toggleNotificationCenter() {
        Quickshell.execDetached(["swaync-client", "-t", "-sw"]);
    }

    // ---- backlight, through logind like mugzx-brightness
    property string backlight: ""
    property int brightnessRaw: 0
    property int brightnessMax: 0
    readonly property bool hasBacklight: backlight !== "" && brightnessMax > 0
    readonly property real brightness: hasBacklight ? brightnessRaw / brightnessMax : 0
    property int pendingBrightness: -1

    Process {
        id: brightnessRead
        command: ["sh", "-c", "d=$(ls /sys/class/backlight | head -n1); [ -n \"$d\" ] && echo \"$d $(cat /sys/class/backlight/$d/brightness) $(cat /sys/class/backlight/$d/max_brightness)\""]
        stdout: StdioCollector {
            onStreamFinished: {
                const p = text.trim().split(/\s+/);
                if (p.length !== 3 || root.pendingBrightness >= 0 || brightnessWrite.running)
                    return;
                root.backlight = p[0];
                root.brightnessRaw = parseInt(p[1]);
                root.brightnessMax = parseInt(p[2]);
            }
        }
    }

    Process {
        id: brightnessWrite
        onExited: root.flushBrightness()
    }

    function refreshBrightness() {
        if (!brightnessRead.running)
            brightnessRead.running = true;
    }

    // Slider drags fire quickly; keep at most one busctl call in flight.
    function setBrightness(v) {
        if (!hasBacklight)
            return;
        root.brightnessRaw = Math.max(1, Math.round(v * brightnessMax));
        root.pendingBrightness = root.brightnessRaw;
        flushBrightness();
    }

    function flushBrightness() {
        if (pendingBrightness < 0 || brightnessWrite.running)
            return;
        brightnessWrite.command = ["busctl", "call", "org.freedesktop.login1",
            "/org/freedesktop/login1/session/auto", "org.freedesktop.login1.Session",
            "SetBrightness", "ssu", "backlight", backlight, String(pendingBrightness)];
        pendingBrightness = -1;
        brightnessWrite.running = true;
    }

    // ---- screen recording (mugzx-record toggles wf-recorder)
    property bool recording: false

    Process {
        id: recordCheck
        command: ["pgrep", "-x", "wf-recorder"]
        onExited: (code) => root.recording = code === 0
    }

    Timer {
        id: recordRecheck
        interval: 1500
        onTriggered: root.refreshRecording()
    }

    function refreshRecording() {
        if (!recordCheck.running)
            recordCheck.running = true;
    }

    function toggleRecording() {
        Quickshell.execDetached([bin + "mugzx-record"]);
        recordRecheck.restart();
    }

    // ---- keep awake: hypridle honours systemd idle inhibitors
    property bool keepAwake: false

    Process {
        running: root.keepAwake
        command: ["setpriv", "--pdeathsig", "TERM", "systemd-inhibit", "--what=idle", "--who=mugzx", "--why=保持亮屏", "sleep", "infinity"]
    }

    // ---- launchers and session actions
    function run(args) {
        Quickshell.execDetached(args);
    }

    function lock() { run([bin + "lock-and-sleep"]); }
    function suspend() { run(["systemctl", "suspend"]); }
    function reboot() { run(["systemctl", "reboot"]); }
    function poweroff() { run(["systemctl", "poweroff"]); }
    function logout() { Hyprland.dispatch("hl.dsp.exit()"); }

    function screenshot() { run([bin + "mugzx-screenshot", "region"]); }
    function systemSettings() { run(["systemsettings"]); }
    function soundSettings() { run(["kcmshell6", "kcm_pulseaudio"]); }
    function networkSettings() { run(["kcmshell6", "kcm_networkmanagement"]); }
    function keybinds() { run([bin + "mugzx-term", bin + "mugzx-keys"]); }
}

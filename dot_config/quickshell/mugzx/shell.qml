//@ pragma UseQApplication
// mugzx desktop shell: an auto-hiding top bar per screen, plus floating
// panels (volume, Wi-Fi, power, settings, calendar, media) that drop down
// from it and close when you click elsewhere or press Esc.
//
// Panels can also be opened from scripts or keybinds:
//   qs ipc -p ~/.config/quickshell/mugzx call panels toggle power
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

ShellRoot {
    Variants {
        model: Quickshell.screens

        Scope {
            id: slot
            required property var modelData

            // Thin top-centre hot edge: the bar stays away until needed.
            PanelWindow {
                id: hotZone
                screen: slot.modelData
                anchors.top: true
                implicitWidth: 300
                implicitHeight: 3
                exclusiveZone: 0
                color: "transparent"
                WlrLayershell.layer: WlrLayer.Top
                WlrLayershell.namespace: "mugzx-hotzone"

                MouseArea {
                    id: hotArea
                    anchors.fill: parent
                    hoverEnabled: true
                }
            }

            Bar {
                id: bar
                shellScreen: slot.modelData
                hotHovered: hotArea.containsMouse
            }

            VolumePanel { shellScreen: slot.modelData; bar: bar }
            WifiPanel { shellScreen: slot.modelData; bar: bar }
            ControlPanel { shellScreen: slot.modelData; bar: bar }
            PowerPanel { shellScreen: slot.modelData; bar: bar }
            CalendarPanel { shellScreen: slot.modelData; bar: bar }
            MediaPanel { shellScreen: slot.modelData; bar: bar }

            Dock { shellScreen: slot.modelData }
            OsdWindow { shellScreen: slot.modelData }
            LauncherWindow { shellScreen: slot.modelData }
            ClipboardWindow { shellScreen: slot.modelData }
        }
    }

    IpcHandler {
        target: "panels"

        function toggle(name: string): void { Panels.toggle(name); }
        function open(name: string): void { Panels.open(name); }
        function close(): void { Panels.close(); }
    }

    IpcHandler {
        target: "launcher"

        function toggle(): void { Launcher.toggle(); }
    }

    IpcHandler {
        target: "clipboard"

        function toggle(): void { Clipboard.toggle(); }
    }

    IpcHandler {
        target: "osd"

        function brightness(): void { Osd.brightness(); }
    }
}

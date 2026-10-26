pragma Singleton
import QtQuick
import Quickshell

// Shared look for the bar and every popup panel, so they read as one system.
Singleton {
    // Hyprland blurs what is behind the shell's layers (layer rule "shell-blur"
    // in hyprland.lua), so this can stay translucent and still read well.
    readonly property color bg: Qt.rgba(0.031, 0.043, 0.063, 0.80)
    readonly property color border: Qt.rgba(0.561, 0.722, 1.0, 0.20)
    readonly property color surface: Qt.rgba(1, 1, 1, 0.045)
    readonly property color surfaceHover: Qt.rgba(1, 1, 1, 0.09)
    readonly property color surfaceActive: Qt.rgba(0.561, 0.722, 1.0, 0.16)
    readonly property color track: Qt.rgba(1, 1, 1, 0.10)

    readonly property color text: "#e8edf5"
    readonly property color textDim: "#9aa4b5"
    readonly property color textFaint: "#5d6676"
    readonly property color accent: "#8fb8ff"
    readonly property color accentFg: "#0a0d12"
    readonly property color danger: "#eb7a7a"
    readonly property color ok: "#9ad89a"

    // The CJK face carries matching Latin glyphs. With plain "Noto Sans",
    // Chinese falls back to a bolder-looking face than the Latin around it.
    readonly property string font: "Noto Sans CJK SC"
    readonly property string mono: "JetBrains Mono"
    readonly property int fontSmall: 10
    readonly property int fontBody: 12
    readonly property int fontTitle: 13

    readonly property int barHeight: 34
    readonly property int barGap: 6            // bar to screen edge, and bar to panel
    readonly property int barRadius: 10
    readonly property int panelWidth: 320
    readonly property int panelMaxHeight: 460
    readonly property int panelRadius: 14
    readonly property int panelPadding: 14
    readonly property int rowHeight: 34
    readonly property int rowRadius: 9
    readonly property int spacing: 10

    readonly property int anim: 140
}

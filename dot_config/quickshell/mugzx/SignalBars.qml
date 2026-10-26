import QtQuick

// Four rising bars for Wi-Fi strength (0..1).
Row {
    id: root

    property real strength: 0
    readonly property int level: strength >= 0.75 ? 4 : strength >= 0.5 ? 3 : strength >= 0.25 ? 2 : 1

    spacing: 2
    height: 11

    Repeater {
        model: 4

        Rectangle {
            required property int index
            anchors.bottom: parent.bottom
            width: 3
            height: 3 + index * 2.6
            radius: 1
            color: index < root.level ? Theme.textDim : Theme.track
        }
    }
}

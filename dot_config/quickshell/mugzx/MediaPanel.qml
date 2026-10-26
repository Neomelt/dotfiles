import QtQuick
import Quickshell
import Quickshell.Widgets
import Quickshell.Services.Mpris

// Now playing: cover, title, seek bar and transport controls.
Popup {
    id: root

    name: "media"
    align: "left"

    readonly property var player: Media.player
    readonly property bool canSeek: !!(player && player.canSeek && player.positionSupported && player.lengthSupported && player.length > 0)

    // MPRIS position is not pushed continuously; poll while visible.
    Timer {
        interval: 1000
        repeat: true
        running: root.shown && !!root.player && root.player.isPlaying
        onTriggered: root.player.positionChanged()
    }

    onOpened: if (player) player.positionChanged()

    Text {
        width: parent.width
        visible: !root.player
        text: "没有正在播放的媒体"
        color: Theme.textFaint
        font.family: Theme.font
        font.pixelSize: Theme.fontSmall
        horizontalAlignment: Text.AlignHCenter
        topPadding: 8
        bottomPadding: 8
    }

    Row {
        visible: !!root.player
        width: parent.width
        spacing: 12

        ClippingRectangle {
            width: 56
            height: 56
            radius: 9
            color: Theme.surface

            Icon {
                anchors.centerIn: parent
                visible: cover.status !== Image.Ready
                name: "music"
                size: 22
                color: Theme.textFaint
            }

            Image {
                id: cover
                anchors.fill: parent
                source: root.player ? root.player.trackArtUrl : ""
                sourceSize.width: 112
                sourceSize.height: 112
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
            }
        }

        Column {
            width: parent.width - 56 - parent.spacing
            anchors.verticalCenter: parent.verticalCenter
            spacing: 3

            Text {
                width: parent.width
                text: Media.title || "未知曲目"
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: Theme.fontTitle
                font.weight: Font.DemiBold
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                visible: text.length > 0
                text: Media.artist
                color: Theme.textDim
                font.family: Theme.font
                font.pixelSize: Theme.fontBody
                elide: Text.ElideRight
            }

            Text {
                width: parent.width
                text: root.player ? root.player.identity : ""
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
                elide: Text.ElideRight
            }
        }
    }

    Column {
        visible: root.canSeek
        width: parent.width
        spacing: 2

        ValueSlider {
            width: parent.width
            value: root.canSeek ? root.player.position / root.player.length : 0
            step: root.canSeek ? 5 / root.player.length : 0.05
            onMoved: (v) => { if (root.canSeek) root.player.position = v * root.player.length; }
        }

        Item {
            width: parent.width
            height: 14

            Text {
                anchors.left: parent.left
                text: root.canSeek ? Media.time(root.player.position) : ""
                color: Theme.textFaint
                font.family: Theme.mono
                font.pixelSize: Theme.fontSmall - 1
            }

            Text {
                anchors.right: parent.right
                text: root.canSeek ? Media.time(root.player.length) : ""
                color: Theme.textFaint
                font.family: Theme.mono
                font.pixelSize: Theme.fontSmall - 1
            }
        }
    }

    Row {
        visible: !!root.player
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 14

        IconButton {
            icon: "prev"
            iconSize: 16
            enabled: !!root.player && root.player.canGoPrevious
            opacity: enabled ? 1 : 0.35
            onClicked: root.player.previous()
        }

        IconButton {
            icon: root.player && root.player.isPlaying ? "pause" : "play"
            iconSize: 18
            enabled: !!root.player && root.player.canTogglePlaying
            opacity: enabled ? 1 : 0.35
            onClicked: root.player.togglePlaying()
        }

        IconButton {
            icon: "next"
            iconSize: 16
            enabled: !!root.player && root.player.canGoNext
            opacity: enabled ? 1 : 0.35
            onClicked: root.player.next()
        }
    }
}

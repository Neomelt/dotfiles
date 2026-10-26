import QtQuick
import Quickshell

// Month calendar under the clock.
Popup {
    id: root

    name: "calendar"
    align: "center"
    panelWidth: 300

    property date month: new Date()

    SystemClock {
        id: clock
        precision: SystemClock.Hours
    }

    onOpened: reset()

    function reset() {
        const d = new Date();
        month = new Date(d.getFullYear(), d.getMonth(), 1);
    }

    function shift(n) {
        month = new Date(month.getFullYear(), month.getMonth() + n, 1);
    }

    function dayAt(i) {
        const offset = (month.getDay() + 6) % 7;       // weeks start on Monday
        return new Date(month.getFullYear(), month.getMonth(), i - offset + 1);
    }

    function sameDay(a, b) {
        return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate();
    }

    readonly property bool showingToday: month.getFullYear() === clock.date.getFullYear()
                                         && month.getMonth() === clock.date.getMonth()

    PanelHeader {
        width: parent.width
        title: root.month.getFullYear() + " 年 " + (root.month.getMonth() + 1) + " 月"

        TextButton {
            anchors.verticalCenter: parent.verticalCenter
            visible: !root.showingToday
            text: "今天"
            onClicked: root.reset()
        }

        IconButton {
            icon: "chevron-left"
            iconSize: 14
            tint: Theme.textDim
            onClicked: root.shift(-1)
        }

        IconButton {
            icon: "chevron-right"
            iconSize: 14
            tint: Theme.textDim
            onClicked: root.shift(1)
        }
    }

    Grid {
        id: grid
        width: parent.width
        columns: 7
        readonly property real cell: width / 7

        Repeater {
            model: ["一", "二", "三", "四", "五", "六", "日"]

            Text {
                required property var modelData
                width: grid.cell
                height: 22
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: modelData
                color: Theme.textFaint
                font.family: Theme.font
                font.pixelSize: Theme.fontSmall
            }
        }

        Repeater {
            model: 42

            Item {
                id: cell
                required property int index
                readonly property date day: root.dayAt(index)
                readonly property bool inMonth: day.getMonth() === root.month.getMonth()
                readonly property bool today: root.sameDay(day, clock.date)
                width: grid.cell
                height: 32

                Rectangle {
                    anchors.centerIn: parent
                    width: 28
                    height: 28
                    radius: 14
                    color: cell.today ? Theme.accent : "transparent"
                }

                Text {
                    anchors.centerIn: parent
                    text: cell.day.getDate()
                    color: cell.today ? Theme.accentFg : cell.inMonth ? Theme.text : Theme.textFaint
                    font.family: Theme.mono
                    font.pixelSize: Theme.fontSmall + 1
                    font.weight: cell.today ? Font.Bold : Font.Normal
                }
            }
        }
    }
}

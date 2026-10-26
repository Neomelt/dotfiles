import QtQuick
import Quickshell.Services.UPower

// Battery outline + percent. Hidden on machines without a battery.
Item {
    id: root

    readonly property var device: UPower.displayDevice
    readonly property bool present: !!(device && device.isPresent && device.isLaptopBattery)
    // Quickshell's UPower binding exposes percentage as 0..1.
    readonly property int percent: present ? Math.round(device.percentage * 100) : 100
    readonly property bool charging: present && (device.state === UPowerDeviceState.Charging
                                                 || device.state === UPowerDeviceState.FullyCharged
                                                 || device.state === UPowerDeviceState.PendingCharge)
    readonly property color tint: charging ? Theme.ok : percent <= 15 ? Theme.danger : Theme.textDim

    signal clicked()

    visible: present
    implicitWidth: present ? content.implicitWidth + 12 : 0
    implicitHeight: 27

    Rectangle {
        anchors.fill: parent
        radius: 7
        color: area.containsMouse ? Theme.surfaceHover : "transparent"
        Behavior on color { ColorAnimation { duration: Theme.anim } }
    }

    Row {
        id: content
        anchors.centerIn: parent
        spacing: 5

        Item {
            width: 20
            height: 11
            anchors.verticalCenter: parent.verticalCenter

            Rectangle {
                width: 18
                height: 11
                radius: 3
                color: "transparent"
                border.width: 1
                border.color: root.tint

                Rectangle {
                    x: 2
                    y: 2
                    width: Math.max(1, 14 * Math.min(1, root.percent / 100))
                    height: 7
                    radius: 1.5
                    color: root.tint
                }
            }

            Rectangle {
                x: 18.5
                y: 3.5
                width: 1.5
                height: 4
                radius: 0.75
                color: root.tint
            }
        }

        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: root.percent + "%"
            color: Theme.textDim
            font.family: Theme.mono
            font.pixelSize: Theme.fontSmall
        }
    }

    MouseArea {
        id: area
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}

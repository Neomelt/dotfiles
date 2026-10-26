import QtQuick
import Quickshell

// Session actions. Lock and suspend run at once; logout, reboot and shutdown
// ask for a second click so a stray click cannot end the session.
Popup {
    id: root

    name: "power"
    align: "right"
    panelWidth: 240

    property string armed: ""

    onOpened: armed = ""
    onShownChanged: if (!shown) armed = ""

    Timer {
        id: disarm
        interval: 3000
        onTriggered: root.armed = ""
    }

    function run(action) {
        Panels.close();
        switch (action) {
        case "lock": System.lock(); break;
        case "suspend": System.suspend(); break;
        case "logout": System.logout(); break;
        case "reboot": System.reboot(); break;
        case "poweroff": System.poweroff(); break;
        }
    }

    function press(action, confirm) {
        if (!confirm || armed === action) {
            run(action);
            return;
        }
        armed = action;
        disarm.restart();
    }

    PanelHeader {
        width: parent.width
        title: "电源"
    }

    Column {
        width: parent.width
        spacing: 2

        Repeater {
            model: [
                { action: "lock", icon: "lock", title: "锁屏", confirm: false },
                { action: "suspend", icon: "moon", title: "睡眠", confirm: false },
                { action: "logout", icon: "logout", title: "注销", confirm: true },
                { action: "reboot", icon: "reboot", title: "重启", confirm: true },
                { action: "poweroff", icon: "power", title: "关机", confirm: true }
            ]

            ListRow {
                required property var modelData
                width: parent.width
                icon: modelData.icon
                title: root.armed === modelData.action ? "再点一次" + modelData.title : modelData.title
                danger: root.armed === modelData.action
                onClicked: root.press(modelData.action, modelData.confirm)
            }
        }
    }
}

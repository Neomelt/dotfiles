pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Networking

// NetworkManager state for the bar icon and the Wi-Fi panel.
Singleton {
    id: root

    // Scan only while the Wi-Fi panel is open.
    readonly property bool scanning: Panels.current === "wifi"

    readonly property var wifiDevice: {
        const d = Networking.devices.values;
        for (let i = 0; i < d.length; i++)
            if (d[i] && d[i].type === DeviceType.Wifi)
                return d[i];
        return null;
    }

    readonly property bool wiredConnected: {
        const d = Networking.devices.values;
        for (let i = 0; i < d.length; i++)
            if (d[i] && d[i].type === DeviceType.Wired && d[i].connected)
                return true;
        return false;
    }

    readonly property bool wifiEnabled: Networking.wifiEnabled
    readonly property bool wifiConnected: !!(wifiDevice && wifiDevice.connected)
    readonly property var networks: wifiDevice ? wifiDevice.networks.values : []

    readonly property var active: {
        for (let i = 0; i < networks.length; i++)
            if (networks[i].connected)
                return networks[i];
        return null;
    }

    // Connected first, then saved, then by coarse signal level; hidden SSIDs
    // dropped. Signal strength changes do not touch the list, so rows (and a
    // half-typed password) are not rebuilt on every scan. Re-sorted each
    // second while the panel is open; ScriptModel diffs, so rows only move.
    property int resortTick: 0

    Timer {
        interval: 1000
        repeat: true
        running: root.scanning
        onTriggered: root.resortTick++
    }

    readonly property var sorted: {
        root.resortTick;
        return root.networks
            .filter(n => n.name && n.name.length > 0)
            .sort((a, b) => (b.connected - a.connected) || (b.known - a.known)
                || (Math.round(b.signalStrength * 4) - Math.round(a.signalStrength * 4))
                || a.name.localeCompare(b.name));
    }

    Binding {
        when: root.wifiDevice !== null
        target: root.wifiDevice
        property: "scannerEnabled"
        value: root.scanning
    }

    function setWifiEnabled(on) {
        Networking.wifiEnabled = on;
    }

    function needsPassword(n) {
        return n.security !== WifiSecurityType.Open && n.security !== WifiSecurityType.Owe;
    }

    function isEnterprise(n) {
        switch (n.security) {
        case WifiSecurityType.Wpa2Eap:
        case WifiSecurityType.WpaEap:
        case WifiSecurityType.Wpa3SuiteB192:
        case WifiSecurityType.Leap:
        case WifiSecurityType.DynamicWep:
            return true;
        }
        return false;
    }

    function failText(reason) {
        switch (reason) {
        case ConnectionFailReason.NoSecrets: return "需要密码";
        case ConnectionFailReason.WifiAuthTimeout:
        case ConnectionFailReason.WifiClientFailed: return "连接失败，请检查密码";
        case ConnectionFailReason.WifiNetworkLost: return "信号丢失";
        case ConnectionFailReason.WifiClientDisconnected: return "连接被断开";
        }
        return "连接失败";
    }
}

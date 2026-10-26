pragma Singleton
import QtQuick
import Quickshell
import Quickshell.Services.Mpris

// The MPRIS player the bar shows: the one playing, else the first one.
Singleton {
    id: root

    readonly property var players: Mpris.players.values
    readonly property var player: {
        for (let i = 0; i < players.length; i++)
            if (players[i].isPlaying)
                return players[i];
        return players.length > 0 ? players[0] : null;
    }

    readonly property string title: player ? (player.trackTitle || player.identity || "") : ""
    readonly property string artist: player ? (player.trackArtist || "") : ""

    function time(seconds) {
        if (!isFinite(seconds) || seconds < 0)
            return "0:00";
        const s = Math.floor(seconds);
        const m = Math.floor(s / 60);
        return m + ":" + String(s % 60).padStart(2, "0");
    }
}

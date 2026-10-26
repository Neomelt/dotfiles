pragma Singleton
import QtQuick
import Quickshell

// .desktop entry helpers shared by the dock and the launcher.
Singleton {
    readonly property string bin: Quickshell.env("HOME") + "/.local/bin/"

    function entryFor(id) {
        return DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id);
    }

    // Theme icon by the entry's own name first. For an absolute path like
    // /usr/share/pixmaps/vscode.png try its basename in the theme, then the file
    // itself; guessing from the app id comes last ("code" is a generic editor icon).
    function iconFor(entry, key) {
        const icon = entry && entry.icon ? entry.icon : "";
        const absolute = icon.startsWith("/");
        const names = [];
        if (icon && !absolute)
            names.push(icon);
        if (absolute)
            names.push(icon.split("/").pop().replace(/\.(png|svg|xpm)$/i, ""));
        for (const n of names) {
            const p = Quickshell.iconPath(n, true);
            if (p)
                return p;
        }
        if (absolute)
            return "file://" + icon;
        for (const n of key ? [key, key.toLowerCase()] : []) {
            const p = Quickshell.iconPath(n, true);
            if (p)
                return p;
        }
        return Quickshell.iconPath("application-x-executable");
    }

    // DesktopEntry.execute() ignores Terminal=true, so terminal apps (btop, yazi…) open in kitty.
    function launch(entry) {
        if (!entry)
            return;
        if (entry.runInTerminal)
            Quickshell.execDetached([bin + "mugzx-term"].concat(Array.from(entry.command)));
        else
            entry.execute();
    }
}

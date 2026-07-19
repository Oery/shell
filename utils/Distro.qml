import QtQuick
import Quickshell
import Quickshell.Io
pragma Singleton

// Reads /etc/os-release once at startup so the bar can show the logo of
// whichever distro this host actually runs.
Singleton {
    id: root

    property string id: ''
    property string idLike: ''
    property string prettyName: ''

    readonly property var logos: ({
            "arch": '󰣇',
            "nixos": '󱄅',
            "debian": '',
            "ubuntu": '',
            "fedora": '',
            "linuxmint": '',
            "opensuse": '',
            "opensuse-tumbleweed": '',
            "opensuse-leap": '',
            "gentoo": '',
            "alpine": '',
            "manjaro": '',
            "endeavouros": '',
            "pop": '',
            "void": '',
            "raspbian": ''
        })

    // Generic Tux, used when the distro isn't one we have a glyph for.
    readonly property string fallbackLogo: ''

    readonly property string logo: {
        if (logos[root.id])
            return logos[root.id];

        // ID_LIKE is a space-separated list of parent distros, so a derivative
        // we don't know by name still gets its family's logo.
        for (const parent of root.idLike.split(' ')) {
            if (logos[parent])
                return logos[parent];
        }

        return root.fallbackLogo;
    }

    Process {
        id: readOsRelease
        command: ["cat", "/etc/os-release"]
        running: true

        stdout: StdioCollector {
            onStreamFinished: {
                for (const line of this.text.split('\n')) {
                    const eq = line.indexOf('=');
                    if (eq === -1)
                        continue;

                    const key = line.slice(0, eq).trim();
                    // Values are optionally quoted: ID=arch or ID="arch".
                    const value = line.slice(eq + 1).trim().replace(/^["']|["']$/g, '');

                    if (key === "ID")
                        root.id = value.toLowerCase();
                    else if (key === "ID_LIKE")
                        root.idLike = value.toLowerCase();
                    else if (key === "PRETTY_NAME")
                        root.prettyName = value;
                }
            }
        }
    }
}

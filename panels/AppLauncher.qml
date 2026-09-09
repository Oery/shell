pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Hyprland
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io
import QtQuick.Layouts
import Qt.labs.folderlistmodel
import qs.utils

Singleton {
    id: appLauncher

    // Starts visible on purpose: the launcher renders once at startup behind
    // opacity 0 to warm the icon and entry caches, then hides itself (see the
    // double callLater below). Setting this to false makes the first real open
    // slow, since nothing is cached until then.
    property bool isVisible: true
    property var cachedIcons: ({})

    // Monitor the launcher opened on, captured at open time so it doesn't jump
    // if focus moves elsewhere while it's up.
    property string activeScreen: ""

    property var wallpaperFiles: []
    property string originalWallpaperPath: ""

    function getIconPath(iconName) {
        if (iconName && iconName.startsWith('file://')) {
            return iconName;
        }
        return Quickshell.iconPath(iconName, false);
    }

    function toggle() {
        if (!isVisible)
            activeScreen = FocusedScreen.name;
        isVisible = !isVisible;
    }

    function launchEntry(entry) {
        if (entry.runInTerminal && Config.terminalCommand !== '') {
            Quickshell.execDetached({
                command: [Config.terminalCommand, '-e'].concat(entry.command),
                workingDirectory: entry.workingDirectory
            });
        } else {
            entry.execute();
        }
    }

    function loadWallpapers() {
        if (wallpaperFiles.length > 0)
            return;

        if (folderListModel.status !== FolderListModel.Ready) {
            Qt.callLater(loadWallpapers);
            return;
        }

        sortProc.command = ["bash", "-c", "cd /home/oery/Pictures/Wallpapers && ls -t -- *.jpg *.jpeg *.png *.webp *.gif 2>/dev/null"];
        sortProc.running = true;
    }

    Process {
        id: sortProc
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const lines = this.text.trim().split('\n').filter(l => l.length > 0);
                const folderModel = folderListModel;
                const fileMap = new Map();
                for (let i = 0; i < folderModel.count; i++) {
                    const fp = folderModel.get(i, 'filePath');
                    const fn = folderModel.get(i, 'fileName');
                    fileMap.set(fn, {
                        filePath: fp.replace('file://', ''),
                        fileName: fn
                    });
                }
                const sorted = [];
                for (const line of lines) {
                    const file = fileMap.get(line);
                    if (file)
                        sorted.push(file);
                }
                appLauncher.wallpaperFiles = sorted;

                thumbnailProc.command = [
                    "bash", "-c",
                    "sourceDir=$1; cacheDir=$2; mkdir -p -- \"$cacheDir\"; "
                    + "find \"$sourceDir\" -maxdepth 1 -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.webp' -o -iname '*.gif' \\) -print0 | "
                    + "while IFS= read -r -d '' source; do name=${source##*/}; thumbnail=\"$cacheDir/$name.jpg\"; "
                    + "if [ ! -f \"$thumbnail\" ] || [ \"$source\" -nt \"$thumbnail\" ]; then "
                    + "temporary=\"$thumbnail.tmp.jpg\"; magick \"$source[0]\" -auto-orient -thumbnail '96x54^' -gravity center -extent 96x54 -strip -quality 82 \"$temporary\" && mv -f -- \"$temporary\" \"$thumbnail\"; "
                    + "fi; [ -f \"$thumbnail\" ] && printf '%s\\n' \"$name\"; done",
                    "wallpaper-thumbnail-cache",
                    "/home/oery/Pictures/Wallpapers",
                    Quickshell.cachePath("wallpaper-thumbnails")
                ];
                thumbnailProc.running = true;
            }
        }
    }

    Process {
        id: thumbnailProc
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                const cachedNames = new Set(this.text.trim().split('\n').filter(name => name.length > 0));
                const cacheDir = Quickshell.cachePath("wallpaper-thumbnails");
                appLauncher.wallpaperFiles = appLauncher.wallpaperFiles.map(file => ({
                    filePath: file.filePath,
                    fileName: file.fileName,
                    thumbnailPath: cachedNames.has(file.fileName) ? cacheDir + "/" + file.fileName + ".jpg" : file.filePath
                }));
            }
        }
    }

    FolderListModel {
        id: folderListModel
        folder: 'file:///home/oery/Pictures/Wallpapers'
        nameFilters: ['*.jpg', '*.jpeg', '*.png', '*.webp', '*.gif']
        showDirs: false
        onStatusChanged: {
            if (status === FolderListModel.Ready) {
                Qt.callLater(loadWallpapers);
            }
        }
    }

    function calculateSearchScore(query, entry) {
        const q = query.toLowerCase();
        if (!q)
            return 0;

        let score = 0;
        const fields = [
            {
                value: entry.name,
                weight: 2.0
            },
            {
                value: entry.genericName,
                weight: 1.5
            },
            {
                value: entry.keywords ? entry.keywords.join(' ') : '',
                weight: 1.2
            },
            {
                value: entry.comment,
                weight: 0.8
            },
            {
                value: entry.executable,
                weight: 0.3
            }
        ];

        for (const field of fields) {
            if (!field.value)
                continue;
            const v = field.value.toLowerCase();
            const w = field.weight;

            if (v === q) {
                score += 1000 * w;
            } else if (v.startsWith(q)) {
                score += 500 * w;
            } else if (v.includes(' ' + q) || v.includes('-' + q) || v.startsWith(q + ' ')) {
                score += 350 * w;
            } else if (v.includes(q)) {
                score += 100 * w;
            } else {
                const fuzzyScore = calculateFuzzyScore(q, v);
                if (fuzzyScore > 0) {
                    score += fuzzyScore * w;
                }
            }
        }

        return score;
    }

    function calculateFuzzyScore(query, target) {
        let qi = 0;
        let ti = 0;
        let consecutive = 0;
        let maxConsecutive = 0;
        let matched = 0;

        while (qi < query.length && ti < target.length) {
            if (query[qi] === target[ti]) {
                matched++;
                consecutive++;
                maxConsecutive = Math.max(maxConsecutive, consecutive);
                qi++;
            } else {
                consecutive = 0;
            }
            ti++;
        }

        if (qi < query.length)
            return 0;

        const matchRatio = matched / query.length;
        const targetBonus = 1 - (matched / target.length) * 0.5;
        const consecutiveBonus = maxConsecutive / query.length;

        return Math.floor(50 * matchRatio * targetBonus + 30 * consecutiveBonus);
    }

    function searchEntries(query) {
        const allEntries = [...DesktopEntries.applications.values].filter(a => a.name != "uuctl");
        if (!query || !query.trim()) {
            const sorted = allEntries.slice().sort((a, b) => a.name.localeCompare(b.name));
            return sorted;
        }

        const q = query.trim();
        const scored = [];

        for (const entry of allEntries) {
            const score = calculateSearchScore(q, entry);
            if (score > 0) {
                scored.push({
                    entry,
                    score
                });
            }
        }

        scored.sort((a, b) => b.score - a.score);
        return scored.slice(0, 50).map(s => s.entry);
    }

    property var commands: [
        {
            name: "Wallpaper",
            icon: "preferences-desktop-wallpaper",
            keywords: ["wallpaper", "background", "wall"]
        }
    ]

    function calculateCommandScore(query, entry) {
        const q = query.toLowerCase();
        if (!q)
            return 0;

        let score = 0;
        const fields = [
            {
                value: entry.name,
                weight: 2.0
            },
            {
                value: entry.keywords ? entry.keywords.join(' ') : '',
                weight: 1.2
            }
        ];

        for (const field of fields) {
            if (!field.value)
                continue;
            const v = field.value.toLowerCase();
            const w = field.weight;

            if (v === q) {
                score += 1000 * w;
            } else if (v.startsWith(q)) {
                score += 500 * w;
            } else if (v.includes(' ' + q) || v.includes('-' + q) || v.startsWith(q + ' ')) {
                score += 350 * w;
            } else if (v.includes(q)) {
                score += 100 * w;
            }
        }

        return score;
    }

    function searchCommands(query) {
        const allCommands = commands;
        if (!query || !query.trim()) {
            const sorted = allCommands.slice().sort((a, b) => a.name.localeCompare(b.name));
            return sorted;
        }

        const q = query.trim();
        const scored = [];

        for (const entry of allCommands) {
            const score = calculateCommandScore(q, entry);
            if (score > 0) {
                scored.push({
                    entry,
                    score
                });
            }
        }

        scored.sort((a, b) => b.score - a.score);
        return scored.slice(0, 50).map(s => s.entry);
    }

    function searchWallpapers(query) {
        let filtered = wallpaperFiles;
        if (query && query.trim()) {
            const q = query.toLowerCase();
            filtered = wallpaperFiles.filter(w => w.fileName.toLowerCase().includes(q));
        }
        return filtered;
    }

    property string mode: "apps"
    property string currentSearchText: ""

    onModeChanged: {
        if (mode === "wallpaper") {
            originalWallpaperPath = Config.wallpaperPath;
            wallpaperFiles = [];
            loadWallpapers();
        }
    }

    property var searchResults: {
        if (mode === "command")
            return searchCommands(currentSearchText.substring(1));
        if (mode === "wallpaper")
            return searchWallpapers(currentSearchText);
        return searchEntries(currentSearchText);
    }

    function transitionToMode(newMode) {
        if (mode === newMode)
            return;
        mode = newMode;
    }

    Variants {
        model: Quickshell.screens

        PanelWindow {
            id: launcher
            required property var modelData

            WlrLayershell.namespace: "quickshell-launcher"

            screen: modelData
            // Only the focused monitor's instance shows. Otherwise every
            // monitor gets a copy, and their focus grabs cancel each other out.
            visible: appLauncher.isVisible && FocusedScreen.matches(modelData, appLauncher.activeScreen)
            focusable: true
            exclusiveZone: 0
            color: 'transparent'

            HyprlandFocusGrab {
                windows: [launcher]
                active: launcher.visible
                onCleared: appLauncher.isVisible = false
            }

            anchors {
                top: true
                left: true
                bottom: true
            }

            implicitWidth: 500

            onVisibleChanged: {
                if (visible) {
                    searchField.text = "";
                    appLauncher.currentSearchText = "";
                    appLauncher.mode = "apps";
                    listView.currentIndex = 0;
                    Qt.callLater(() => {
                        searchField.forceActiveFocus();
                    });
                }
            }

            Rectangle {
                anchors.fill: parent
                anchors.margins: 5
                // color: '#E5080808'
                color: '#D8080808'
                radius: 4

                opacity: 0

                // Double callLater so that it runs after 1st render, by which
                // point the icon and entry caches are warm.
                Component.onCompleted: {
                    Qt.callLater(() => {
                        Qt.callLater(() => {
                            appLauncher.isVisible = false;
                            opacity = 1;
                        });
                    });
                }

                Timer {
                    id: previewTimer
                    interval: 0
                    onTriggered: {
                        if (appLauncher.mode !== "wallpaper")
                            return;
                        const files = appLauncher.searchResults;
                        const file = files[listView.currentIndex];
                        if (file) {
                            Config.wallpaperPath = "file://" + file.filePath;
                        }
                    }
                }

                focus: true
                Keys.enabled: true
                Keys.onEscapePressed: {
                    if (appLauncher.mode === "wallpaper") {
                        Config.wallpaperPath = appLauncher.originalWallpaperPath;
                        appLauncher.mode = "apps";
                        appLauncher.currentSearchText = "";
                    } else if (appLauncher.mode === "command") {
                        appLauncher.mode = "apps";
                        appLauncher.currentSearchText = "";
                    } else {
                        appLauncher.isVisible = false;
                    }
                }
                Keys.onUpPressed: {
                    if (listView.currentIndex > 0) {
                        listView.currentIndex--;
                    } else if (listView.keyNavigationWraps) {
                        listView.currentIndex = listView.count - 1;
                    }
                    if (appLauncher.mode === "wallpaper") {
                        previewTimer.restart();
                    }
                }
                Keys.onDownPressed: {
                    if (listView.currentIndex < listView.count - 1) {
                        listView.currentIndex++;
                    } else if (listView.keyNavigationWraps) {
                        listView.currentIndex = 0;
                    }
                    if (appLauncher.mode === "wallpaper") {
                        previewTimer.restart();
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 10
                    spacing: 10

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        Rectangle {
                            Layout.fillWidth: true
                            height: 24
                            color: "transparent"

                            StyledText {
                                id: placeholder
                                text: {
                                    if (appLauncher.mode === "command")
                                        return "Type a command...";
                                    if (appLauncher.mode === "wallpaper")
                                        return "Search wallpapers...";
                                    return "Search applications...";
                                }
                                color: "#808080"
                                font.pixelSize: 14
                                visible: searchField.text === ""
                            }

                            TextInput {
                                id: searchField
                                anchors.fill: parent
                                font.family: "JetBrains Mono"
                                font.pixelSize: 14
                                color: "#F7F1FF"
                                cursorDelegate: Rectangle {
                                    width: 1
                                    color: "#F7F1FF"
                                }
                                onTextChanged: {
                                    if (appLauncher.mode === "apps" && text.startsWith('>')) {
                                        appLauncher.mode = "command";
                                    } else if (appLauncher.mode === "command" && !text.startsWith('>') && text === "") {
                                        appLauncher.mode = "apps";
                                    }
                                    appLauncher.currentSearchText = text;
                                }
                                onAccepted: {
                                    const entry = listView.model[listView.currentIndex];
                                    if (!entry)
                                        return;

                                    if (appLauncher.mode === "command") {
                                        if (entry.name === "Wallpaper") {
                                            appLauncher.mode = "wallpaper";
                                            appLauncher.currentSearchText = "";
                                            searchField.text = "";
                                        }
                                    } else if (appLauncher.mode === "wallpaper") {
                                        Config.wallpaperPath = "file://" + entry.filePath;
                                        appLauncher.isVisible = false;
                                    } else {
                                        appLauncher.launchEntry(entry);
                                        appLauncher.isVisible = false;
                                    }
                                }
                            }
                        }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        implicitHeight: 1
                        color: '#40FFFFFF'
                    }

                    ListView {
                        id: listView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        clip: true
                        currentIndex: 0

                        keyNavigationWraps: true

                        highlightMoveDuration: 100
                        highlightRangeMode: ListView.ApplyRange
                        preferredHighlightBegin: 500
                        preferredHighlightEnd: 600

                        onCurrentIndexChanged: {
                            if (appLauncher.mode === "wallpaper") {
                                previewTimer.restart();
                            }
                        }

                        model: appLauncher.searchResults

                        delegate: Rectangle {
                            width: listView.width
                            implicitHeight: content.implicitHeight + 12
                            radius: 4
                            border.width: 1

                            property bool isCurrent: index === listView.currentIndex
                            property bool isWallpaperMode: appLauncher.mode === "wallpaper"

                            border.color: isCurrent ? '#40FFFFFF' : "transparent"
                            color: isCurrent ? '#20FFFFFF' : "transparent"

                            RowLayout {
                                id: content
                                anchors.fill: parent
                                anchors.margins: 8
                                spacing: 10

                                IconImage {
                                    visible: !isWallpaperMode
                                    source: getIconPath(modelData.icon)
                                    width: 24
                                    height: 24
                                    asynchronous: true
                                }

                                Image {
                                    visible: isWallpaperMode && modelData.filePath
                                    source: modelData.filePath ? "file://" + (modelData.thumbnailPath || modelData.filePath) : ""
                                    Layout.preferredWidth: 43
                                    Layout.preferredHeight: 24
                                    width: 43
                                    height: 24
                                    sourceSize: Qt.size(96, 54)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    cache: true
                                }

                                StyledText {
                                    text: isWallpaperMode ? modelData.fileName : modelData.name
                                    font.pixelSize: 12
                                    font.bold: true
                                    Layout.fillWidth: true
                                    elide: Text.ElideRight
                                }
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true

                                onEntered: {
                                    parent.color = '#20FFFFFF';
                                    listView.currentIndex = index;
                                }

                                onExited: parent.color = "transparent"

                                onClicked: {
                                    if (appLauncher.mode === "command") {
                                        if (modelData.name === "Wallpaper") {
                                            appLauncher.mode = "wallpaper";
                                            appLauncher.currentSearchText = "";
                                            searchField.text = "";
                                        }
                                    } else if (appLauncher.mode === "wallpaper") {
                                        Config.wallpaperPath = "file://" + modelData.filePath;
                                        appLauncher.isVisible = false;
                                    } else {
                                        appLauncher.launchEntry(modelData);
                                        appLauncher.isVisible = false;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

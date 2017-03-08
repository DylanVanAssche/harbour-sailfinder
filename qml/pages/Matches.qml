import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/matches.js" as Matches

Item {
    width: parent.width; height: parent.height

    SilicaListView {
        id: matchesView
        width: parent.width; height: parent.height
        model: matchesModel
        opacity: count? 1.0: 0.0
        delegate: MatchesDelegate {}

        Behavior on opacity {
            FadeAnimation {}
        }

        Connections {
            target: app
            onCachingMatchesChanged: app.matchesData? Matches.load(): console.log("[ERROR] Invalid matches data: " + app.matchesData)
            onLoadingMatchesChanged: !app.loadingMatches && !matchesView.count? app.headerMatches = qsTr("Matches"): undefined
            onCleanup: Matches.clear()
        }

        ListModel {
            id: matchesModel
            onCountChanged: count>0? app.headerMatches = count + " " + qsTr("matches"): undefined
        }
    }

    // Placeholder
    Label {
        anchors { centerIn: parent }
        font.pixelSize: Theme.fontSizeExtraLarge
        font.bold: true
        visible: matchesView.opacity == 0.0 && !matchesView.count? true: false
        text: {
            if(!app.loadingMatches && !app.cachingMatches)
            {
                qsTr("No matches") + "!"
            }
            else if (app.loadingMatches || app.cachingMatches) {
                qsTr("Loading") + "..."
            }
        }
    }
}




import QtQuick 2.0
import Sailfish.Silica 1.0
import "js/matches.js" as Matches
import "js/updates.js" as Updates

Item {
    width: parent.width; height: parent.height
    Component.onCompleted: {
        Updates.get(true) // Get updates from when we were offline
        Matches.get() // Getting matches
    }

    property bool refreshing
    onRefreshingChanged: refreshing? Updates.get(true): undefined // Refresh immediately

    Connections {
        target: app
        onCachingMatchesChanged: app.matchesData? Matches.load(): console.log("[ERROR] Invalid matches data: " + app.matchesData)
        onLoadingMatchesChanged: !app.loadingMatches && !matchesView.count? app.headerMatches = qsTr("Matches"): undefined
        onCleanup: Matches.clear()
        onRefreshMatches: {
            refreshing = true;
            Matches.get()
        }
    }

    SilicaListView {
        id: matchesView
        width: parent.width; height: parent.height
        model: ListModel { id: matchesModel }
        opacity: count && !refreshing? 1.0: 0.0
        onOpacityChanged: count>0 && matchesView.opacity == 1.0? app.headerMatches = count + " " + qsTr("matches"): app.headerMatches = qsTr("Matches")
        delegate: MatchesDelegate {}

        Behavior on opacity {
            FadeAnimation {}
        }  
    }

    // Placeholder
    Label {
        anchors { centerIn: parent }
        font.pixelSize: Theme.fontSizeExtraLarge
        font.bold: true
        visible: (matchesView.opacity == 0.0 && !matchesView.count) || refreshing? true: false
        text: {
            if(!app.loadingMatches && !app.cachingMatches && !refreshing)
            {
                qsTr("No matches") + "!"
            }
            else if (app.loadingMatches || app.cachingMatches || refreshing) {
                qsTr("Loading") + "..."
            }
        }
    }
}




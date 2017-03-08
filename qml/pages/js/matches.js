/*
Sailfinder Matches handles all the interaction in the matches UI
*/

function load() {
    try {
        for(var userCounter=0; userCounter<Object.keys(app.matchesData).length; userCounter++) {
            matchesModel.append({
                                    name: app.matchesData[userCounter].person.name,
                                    id: app.matchesData[userCounter].person._id,
                                    matchId: app.matchesData[userCounter]._id,
                                    lastSeen: convertLastSeen(app.matchesData[userCounter].last_activity_date),
                                    avatar: app.matchesData[userCounter].person.photos[0].processedFiles[0].url,
                                    isSuperlike: app.matchesData[userCounter].is_super_like
                                });
        }
        app.loadingMatches = false;
    }
    catch(err) {
        console.log("[ERROR] Loading matches UI failed due: " + err);
    }
}

function convertLastSeen(lastActivityData) {
    var lastSeenDate = new Date(lastActivityData);
    var today = new Date();
    var difference = today.getTime() - lastSeenDate.getTime();
    if (difference > 7*24*3600*1000)  { // More then a week ago
        return (lastSeenDate.getDate() + "-" + (lastSeenDate.getMonth()+1) + "-" + lastSeenDate.getFullYear()); //Javascript months (0-11) so +1
    }
    else if(difference > 24*3600*1000) { // More then a day ago
        return (difference/(24*3600*1000)).toFixed(0)  + " " + qsTr("day(s) ago");
    }
    else if (difference > 3600*1000) { // More then an hour ago
        return (difference/(3600*1000)).toFixed(0) + " " + qsTr("hour(s) ago");
    }
    else if (difference > 5*60*1000) { // More then 5 minutes ago
        return (difference/(60*1000)).toFixed(0) + " " + qsTr("minute(s) ago");
    }
    return qsTr("Just now");
}

function unmatch(matchId) {
    python.call("app.matches.delete", [matchId]);
}

function report(userId, reason, explanation) {
    python.call("app.matches.report", [userId, reason, explanation])
}

function getReason(reason) {
    switch(reason) {
        case 1:
            return qsTr("SPAM");
        case 2:
            return qsTr("inappropriate messages");
        case 4:
            return qsTr("inappropriate pictures");
        case 5:
            return qsTr("bad offline behavior");
        default:
            return qsTr("other reason");
    }
}

function clear() {
    app.headerMatches = qsTr("Matches");
    matchesModel.clear()
}

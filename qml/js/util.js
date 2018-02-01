// Male = 0
// Female = 1
// Everyone = -1

function createHeaderRecs(name, birthDate, gender) {
    var today = new Date();
    var age = today.getFullYear() - birthDate.getFullYear();
    var genderSymbol = "♀";
    if(gender === 0) {
        genderSymbol = "♂";
    }
    return name + " (" + age + ") " + genderSymbol;
}

function createHeaderProfile(name, birthDate, gender) {
    return createHeaderRecs(name, birthDate, gender);
}

function createHeaderMatches(count) {
    //: Header for matches
    //% "Matches"
    return qsTrId("sailfinder-matches") + " (" + count + ")";
}

function createHeaderMessages(name, birthDate, gender) {
    return createHeaderRecs(name, birthDate, gender);
}

function formatDate(date) {
    if(!isNaN(date.getTime())) {
        var difference = new Date().getTime() - date.getTime();
        difference = difference / 1000 // convert from miliseconds to seconds
        if(difference < 60) { // Less then a minute ago
            //% "Just now"
            return qsTrId("sailfinder-just-now")
        }
        else if(difference < 60*60) { // 60 seconds, 60 minutes = 1 hour
            //% "%L0 minute(s) ago"
            return qsTrId("sailfinder-minutes-ago").arg(Math.round(difference/60));
        }
        else if(difference < 24*60*60) { // 60 seconds, 60 minutes, 24 hours = 1 day
            //% "%L0 hour(s) ago"
            return qsTrId("sailfinder-hours-ago").arg(Math.round(difference/3600));
        }
        else {
            return date.toLocaleString(Qt.locale(), "dd/MM/yyyy HH:mm");
        }
    }
    console.warn("Timestamp is undefined or not a Date object");
    return "";
}

function getUTCDate() {
    var now = new Date();
    return new Date(now.getUTCFullYear(), now.getUTCMonth(), now.getUTCDate(),  now.getUTCHours(), now.getUTCMinutes(), now.getUTCSeconds());
}

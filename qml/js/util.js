/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/

// Male = 0
// Female = 1
// Everyone = -1

function createHeaderRecs(name, birthDate, gender, distance) {
    var today = new Date();
    var age = today.getFullYear() - birthDate.getFullYear() - 1; // Due the fuzzy birthDate feature the age is off by 1
    var genderSymbol = "♀";
    var distanceText = "";
    if(gender === 0) {
        genderSymbol = "♂";
    }
    if(distance > -1) { // Only show when distance is available
        distanceText = " - " + distance + " km"
    }

    return name + " (" + age + ") " + genderSymbol + distanceText;
}

function createHeaderProfile(name, birthDate, gender) {
    return createHeaderRecs(name, birthDate, gender, -1);
}

function createHeaderMatches(count) {
    //: Header for matches
    //% "Matches"
    return qsTrId("sailfinder-matches") + " (" + count + ")";
}

function createHeaderMessages(name, birthDate, gender, distance) {
    return createHeaderRecs(name, birthDate, gender, distance);
}

function createHeaderMatchProfile(name, birthDate, gender) {
    return createHeaderRecs(name, birthDate, gender, -1);
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

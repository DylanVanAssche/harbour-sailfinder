/*
Sailfinder Matches handles all the interaction in the matches UI
*/

function load() {
    try {
        matchesModel.clear();
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

function get() {
    python.call("app.matches.get", [settings.imageFormat], function() { // Get our matches
        refreshing = false; // Reset internal refreshing
    });
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
    python.call("app.matches.report", [userId, reason, explanation]);
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

function about(user_id) {
    python.call("app.matches.about", [userId], function(aboutData) {
        var avatarList = [];
        for(var i=0; i<Object.keys(aboutData.photos).length; i++) {
            try {
                avatarList.push(aboutData.photos[i].processedFiles[0].url);
            }
            catch(err) { // In very rare cases the Tinder API returns an image with only an id property.
                console.log("[ERROR] API returned image without URL")
            }
        }
        bio.text = aboutData.bio;
        header = createHeader(aboutData);

        if (typeof(aboutData.instagram) != 'undefined') {
            instagram.iconText = aboutData.instagram.username;
            instagram.link = "https://www.instagram.com/" + aboutData.instagram.username;
        }
        else {
            instagram.iconText = "";
            instagram.link = "";
        }

        if (aboutData.schools.length) {
            if("name" in aboutData.schools[0]) {
                school.iconText = aboutData.schools[0].name;
            }

            if("id" in aboutData.schools[0]) {
                school.link = "https://www.facebook.com/" + aboutData.schools[0].id;
            }
        }
        else {
            school.iconText = "";
            school.link = "";
        }

        if (aboutData.jobs.length) {
            if("company" in aboutData.jobs[0]) {
                if("name" in aboutData.jobs[0].company) {
                    job.iconText = aboutData.jobs[0].company.name;
                }

                if ("id" in aboutData.jobs[0].company) {
                    job.link = "https://www.facebook.com/" + aboutData.jobs[0].company.id;
                }
            }

            if("title" in aboutData.jobs[0]) {
                if("name" in aboutData.jobs[0].title) {
                    if(job.iconText.length > 0) {
                        job.iconText += " - ";
                    }
                    job.iconText += aboutData.jobs[0].title.name;
                }
                if ((!"id" in aboutData.jobs[0].title) && ("id" in aboutData.jobs[0].title)) {
                    job.link = "https://www.facebook.com/" + aboutData.jobs[0].title.id;
                }
            }
        }
        else {
            job.iconText = "";
            job.link = "";
        }
        avatars.images = avatarList;
        loadingAbout = false;
    });
}

function createHeader(aboutData)
{
    var userHeader = aboutData.name + " (" + convertAge(aboutData.birth_date) +") " + convertGender(aboutData.gender) + " - " + Math.round(aboutData.distance_mi*1.609344) + "km";
    return userHeader;
}

function convertAge(date) {
    var birthDate = new Date(date);
    var today = new Date();
    var difference = today.getFullYear() - birthDate.getFullYear();

    if (today.getMonth() < (birthDate.getMonth() - 1)) {
        difference--;
    }

    if (((birthDate.getMonth() - 1) == today.getMonth()) && (today.getDay() < birthDate.getDay())) {
        difference--;
    }
    return difference;
}

function convertGender(gender) {
    if(gender) {
        return "♀";
    }
    else {
        return "♂";
    }
}

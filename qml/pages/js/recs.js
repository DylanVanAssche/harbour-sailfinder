/*
Sailfinder Recs handles all the interaction in the recommendations UI
*/

var userCounter = 0;

function get() {
    app.loadingRecs = true;
    app.coverBackgroundRecs = "../resources/images/cover-background.png";

    python.call("app.recs.get", [settings.imageFormat], function(recs) {
        app.recsData = recs;
    })
}

function clear() {
    app.headerRecs = qsTr("Recommendations");
    userAvatars.images = [];
    bio.text = "";
    instagram.iconText = "";
    instagram.link = "";
    school.iconText = "";
    school.link = "";
    job.iconText = "";
    job.link = "";
}

function load() {
    try {
        if(app.recsData == "outOfUsers") { //No users anymore in this area
            outOfUsers = true;
        }
        else {
            outOfUsers = false;
            var avatarList = [];
            for(var i=0; i<Object.keys(app.recsData[userCounter].photos).length; i++) {
                try {
                    avatarList.push(app.recsData[userCounter].photos[i].processedFiles[0].url);
                }
                catch(err) { // In very rare cases the Tinder API returns an image with only an id property.
                    console.log("[ERROR] API returned image without URL")
                }
            }
            userAvatars.images = avatarList;
            if (typeof(app.recsData[userCounter].bio) != 'undefined') {
                bio.text = app.recsData[userCounter].bio;
            }
            else {
                bio.text = "";
            }
            app.headerRecs = createHeader();
            app.coverBackgroundRecs = app.recsData[userCounter].photos[0].processedFiles[0].url;

            if (typeof(app.recsData[userCounter].instagram) != 'undefined') {
                instagram.iconText = app.recsData[userCounter].instagram.username;
                instagram.link = "https://www.instagram.com/" + app.recsData[userCounter].instagram.username;
            }
            else {
                instagram.iconText = "";
                instagram.link = "";
            }

            if (app.recsData[userCounter].schools.length) {
                if("name" in app.recsData[userCounter].schools[0]) {
                    school.iconText = app.recsData[userCounter].schools[0].name;
                }

                if("id" in app.recsData[userCounter].schools[0]) {
                    school.link = "https://www.facebook.com/" + app.recsData[userCounter].schools[0].id;
                }
            }
            else {
                school.iconText = "";
                school.link = "";
            }

            if (app.recsData[userCounter].jobs.length) {
                if("company" in app.recsData[userCounter].jobs[0]) {
                    if("name" in app.recsData[userCounter].jobs[0].company) {
                        job.iconText = app.recsData[userCounter].jobs[0].company.name;
                    }

                    if ("id" in app.recsData[userCounter].jobs[0].company) {
                        job.link = "https://www.facebook.com/" + app.recsData[userCounter].jobs[0].company.id;
                    }
                }

                if("title" in app.recsData[userCounter].jobs[0]) {
                    if("name" in app.recsData[userCounter].jobs[0].title) {
                        if(job.iconText.length > 0) {
                            job.iconText += " - ";
                        }
                        job.iconText += app.recsData[userCounter].jobs[0].title.name;
                    }
                    if ((!"id" in app.recsData[userCounter].jobs[0].title) && ("id" in app.recsData[userCounter].jobs[0].title)) {
                        job.link = "https://www.facebook.com/" + app.recsData[userCounter].jobs[0].title.id;
                    }
                }
            }
            else {
                job.iconText = "";
                job.link = "";
            }
        }

        app.loadingRecs = false; // Recommendation loaded into UI
    }
    catch(err) { // When loading fails, automatically skip to the next one.
        console.log("[ERROR] Loading recommendations UI failed due: " + err);
        next();
    }
}

function createHeader()
{
    var userHeader = app.recsData[userCounter].name;
    if (!app.recsData[userCounter].hide_age) {
        userHeader += " (" + convertAge(app.recsData[userCounter].birth_date) +")";
    }

    userHeader += " " + convertGender(app.recsData[userCounter].gender);

    if (!app.recsData[userCounter].hide_distance) {
        userHeader += " - " + Math.round(app.recsData[userCounter].distance_mi*1.609344) + "km";
    }
    return userHeader;
}

function like() {
    app.loadingRecs = true;
    userAvatars.zoom = false;
    python.call("app.recs.like", [app.recsData[userCounter]._id], function(action) {
        if (action) {
            if(action.likes_remaining == 0) {
                parameters.wasOutOfLikes = true;
                outOfLikes = true;
                app.loadingRecs = false;
            }
            else {
                outOfLikes = false;
                checkMatching(action.match);
                next();
            }
        }
    })
}

function dislike() {
    app.loadingRecs = true;
    userAvatars.zoom = false;
    python.call("app.recs.dislike", [app.recsData[userCounter]._id], function(action) {
        if (action) {
            next();
        }
    })
}

function superlike() {
    app.loadingRecs = true;
    userAvatars.zoom = false;
    python.call("app.recs.superlike", [app.recsData[userCounter]._id], function(action) {
        console.log("Superlike:" + JSON.stringify(action))
        if (action) {
            if (action === 2 || action.super_likes.remaining == 0) { // Out of superlikes
                outOfSuperlikes = true;
                app.loadingRecs = false;
            }
            checkMatching(action.match);
            next();
        }
    })
}

function checkMatching(match) {
    if(match) {
        popupContent.avatar = app.recsData[userCounter].photos[0].processedFiles[0].url;
        popupContent.name = app.recsData[userCounter].name;
        popup.open = true;
        app.refreshMatches(); // Request an update
    }
    else {
        popup.open = false;
    }
}

function next() {
    if (userCounter < Object.keys(app.recsData).length-1) {
        userCounter++;
        load(); // Load new user in UI
    }
    else {
        userCounter = 0;
        get();  // Get new users in the area
    }
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

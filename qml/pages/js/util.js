/*
Sailfinder Utilbox to execute several simple UI things in JS
*/

function getHeader(index)
{
    switch(index) {
    case 0: // Recommendations
        app.coverText = app.headerRecs.split("(")[0].split("-")[0]; // Reduce the length of the cover text
        try {
            app.coverBackground = app.coverBackgroundRecs;
        }
        catch(err) {
            app.coverBackground = "../resources/images/cover-background.png";
        }
        return app.headerRecs;

    case 1: // Matches
        app.coverText = qsTr("Matches");
        try {
            app.coverBackground = app.matchesData[Math.min(Math.max(Math.floor(Math.random()*Object.keys(app.matchesData).length-1), 1),Object.keys(app.matchesData).length-1)].person.photos[0].processedFiles[0].url;
        }
        catch(err) {
            app.coverBackground = "../resources/images/cover-background.png";
        }
        return app.headerMatches;

    case 2: // Profile
        app.coverText = qsTr("Profile");
        try {
            app.coverBackground = app.profileData.photos[0].processedFiles[0].url;
        }
        catch(err) {
            app.coverBackground = "../resources/images/cover-background.png";
        }
        return app.headerProfile;

    case 3: // Social
        app.coverText = qsTr("Social");
        app.coverBackground = app.coverBackgroundSocial;
        return app.headerSocial;

    default: // Unknown
        console.log("[ERROR] Main view crashed on index: " + index);
        app.coverText = "Sailfinder";
        app.coverBackground = "../resources/images/cover-background.png";
        return "Sailfinder";
    }
}

function getImageGridHeight(numberOfImages)
{
    if(numberOfImages === 2 || numberOfImages === 3) {
        return 2*parent.width/3;
    }
    else {
        return parent.width;
    }
}

function init()
{
    python.call("app.account.meta", [], function(meta) {
        try {
            if(meta.rating.likes_remaining == 0)
            {
                parameters.wasOutOfLikes = true;
                outOfLikes = true;
            }
            else if(parameters.wasOutOfLikes) {
                notification.summary = qsTr("Swipes available") + "!";
                notification.body = qsTr("You can swipe again") + ".";
                notification.previewSummary = qsTr("Swipes available") + "!";
                notification.previewBody = qsTr("You can swipe again") + ".";
                notification.publish();
                parameters.wasOutOfLikes = false;
            }

            if(meta.rating.super_likes.remaining == 0) {
                outOfSuperlikes = true;
            }

            discovery = meta.user.discoverable;

            if(outOfLikes == false && discovery == true) {
                python.call("app.recs.get"); // Get our recommendations
            }
            else {
                app.loadingRecs = false;
                app.cachingRecs = false;
            }
        }
        catch(err){
            console.log("[ERROR] Reading meta data failed: " + err)
        }

    })

    python.call("app.profile.get", [true]); // Get our profile
    python.call("app.matches.get", [getLastActive()]); // Get our matches
    console.log("[INFO] LAST ACTIVE: " + parameters.last_activity_date);
    var today = new Date();
    parameters.last_activity_date = today.toISOString();
}

function getLastActive()
{
    if (parameters.last_activity_date.length == 0)
    {
        var today = new Date();
        parameters.last_activity_date = today.toISOString();
    }

    return parameters.last_activity_date;
}

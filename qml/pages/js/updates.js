function get(override) {
    if((!cachingMatches && !cachingRecs && !cachingProfile) || override) { // Skip when downloading data
        python.call("app.matches.incremental", [parameters.last_activity_date], function(update) {
            if(update) {
                console.log("[DEBUG] Liked msg: " + JSON.stringify(update.liked_messages) + " matches: " + JSON.stringify(update.matches) + " groups: " + JSON.stringify(update.squads))
                parameters.last_activity_date = update.last_activity_date; // Update last activity date
                parse(update)
            }
            else {
                console.log("[DEBUG] Network connection disabled, can't check for notifications right now!")
            }
        });
    }
    return true;
}

function parse(update) {
    if(update.liked_messages.length > 0) {
        var newLiked = 0;

        for(var likedCounter=0; likedCounter<update.liked_messages.length; likedCounter++) {
            if(update.liked_messages[likedCounter].is_liked && update.liked_messages[likedCounter].liker_id != app.userId) { // Only when liked and the other party did it
                newLiked++;
            }
        }

        if(newLiked > 0) {
            notificationLiked.close()
            notificationLiked.summary = qsTr("New liked message(s)") + "!";
            notificationLiked.body = newLiked + " " + qsTr("new message(s) liked by your match(es)") + ".";
            notificationLiked.previewSummary = qsTr("New liked message(s)") + "!";
            notificationLiked.previewBody = newLiked + " " + qsTr("new message(s) liked by your match(es)") + ".";
            notificationLiked.publish();
        }
    }

    if(update.matches.length > 0) {
        var newMessages = 0;
        var newMatches = 0;

        for(var matchesCounter=0; matchesCounter<update.matches.length; matchesCounter++) {
            if(update.matches[matchesCounter].is_new_message) {
                for(var messagesCounter=0; messagesCounter<update.matches[matchesCounter].messages.length; messagesCounter++) { // A match can send mutiple messages between updates
                    if(update.matches[matchesCounter].messages[messagesCounter].from != app.userId) { // Only when the other party sends a message
                        newMessages++;
                    }
                }
            }
            else {
                newMatches++;
            }
        }

        if(newMatches > 0) { // New matches
            notificationMatches.close()
            notificationMatches.summary = qsTr("New match(es)") + "!";
            notificationMatches.body = newMatches + " " + qsTr("new match(es)") + ".";
            notificationMatches.previewSummary = qsTr("New match(es)") + "!";
            notificationMatches.previewBody = newMatches + " " + qsTr("new match(es)") + ".";
            notificationMatches.publish();
        }

        if(newMessages > 0) { // New messages
            notificationMessages.close()
            notificationMessages.summary = qsTr("New message(s)") + "!";
            notificationMessages.body = newMessages + " " + qsTr("new message(s)") + ".";
            notificationMessages.previewSummary = qsTr("New message(s)") + "!";
            notificationMessages.previewBody = newMessages + " " + qsTr("new message(s)") + ".";
            notificationMessages.publish();
        }
    }

    if(update.squads.length > 0) { // UNKNOWN HOW THIS WORKS YET Sailfinder V3.X
        console.log("GROUP SOCIAL")
        /*
        notificationSocial.close()
        notificationSocial.summary = qsTr("New group message(s)") + "!";
        notificationSocial.body = update.squads.length + " " + qsTr("new messages") + ".";
        notificationSocial.previewSummary = qsTr("New group message(s)") + "!";
        notificationSocial.previewBody = update.squads.length + " " + qsTr("new messages") + ".";
        notificationSocial.publish();*/
    }

    if(update.liked_messages.length > 0 || update.matches.length > 0 || update.blocks.length > 0 /* || update.squads.length > 0*/) { // Refresh when data changed
        console.log("[DEBUG] Refresh data requested")
        app.refreshMatches() // New data, update requested!
    }
}

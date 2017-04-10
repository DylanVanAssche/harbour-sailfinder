/*
Sailfinder Messaging handles all the interaction in the messages UI
*/

function load() {  // Get messages from a specific user by his/her id
    messagesModel.clear()
    for(var messageCounter=0; messageCounter<Object.keys(app.matchesData[userIndex].messages).length; messageCounter++) {
        messagesModel.append({
                                 message: app.matchesData[userIndex].messages[messageCounter].message,
                                 id: app.matchesData[userIndex].messages[messageCounter]._id,
                                 from: app.matchesData[userIndex].messages[messageCounter].from,
                                 createdDate: calculateMessageDate(app.matchesData[userIndex].messages[messageCounter].created_date),
                                 isGif: "type" in app.matchesData[userIndex].messages[messageCounter],
                                 liked: app.likedMessagesData? checkLiked(app.matchesData[userIndex].messages[messageCounter]._id): false //likedMessages will return false when no data
                             });
    }
    messagesCount = Object.keys(app.matchesData[userIndex].messages).length;
}

function calculateMessageDate(messageData) {
    var messageDate = new Date(messageData);
    var today = new Date();
    var difference = today.getTime() - messageDate.getTime();

    if (difference > 7*24*3600*1000) { // More then a week ago
        return (messageDate.getDate() + "-" + (messageDate.getMonth()+1) + "-" + messageDate.getFullYear()); //Javascript months (0-11) so +1
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

function checkLiked(message_id) {
    for(var likedMessageCounter=0; likedMessageCounter<Object.keys(app.likedMessagesData).length; likedMessageCounter++) {
        if(app.likedMessagesData[likedMessageCounter].is_liked && message_id == app.likedMessagesData[likedMessageCounter].message_id) {
            return true;
        }
    }
    return false;
}

function like(message_id) {
    console.log("LIKING MSG")
    python.call("app.matches.like_msg", [message_id], function(result) {
        console.log("[DEBUG] Message liked: " + JSON.stringify(result));
        return result;
    });
    return false;
}

function unlike(message_id) {
    console.log("DISLIKING MSG")
    python.call("app.matches.unlike_msg", [message_id], function(result) {
        console.log("[DEBUG] Message unliked: " + JSON.stringify(result));
        return result;
    });
    return false;
}

function send(match_id, message) {
    python.call("app.matches.send", [match_id, message], function(result) {
        console.log("[DEBUG] Message send: " + JSON.stringify(result));
        return result;
    });
    return false;
}

function sendGif(match_id, message, gif_id) {
    python.call("app.matches.send", [match_id, message, true, gif_id], function(result) {
        if(result == false) {
            console.log("[WARNING] User tried to send a GIF that's not allowed by Tinder");
            toaster.previewBody = qsTr("GIF content blocked") + "!"; // Tinder filters explicite content
            toaster.publish();
            return false;
        }
        else {
            messagesModel.append({from: "myself", message: message, createdDate: qsTr("Just now"), isGif: true, liked: false}); // Send GIF, clear and scroll down
            return true;
        }
    });
    return false;
}


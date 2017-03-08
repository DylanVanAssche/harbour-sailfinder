/*
Sailfinder Messaging handles all the interaction in the messages UI
*/

function load() {  // Get messages from a specific user by his/her id
    messagesModel.clear()
    for(var messageCounter=0; messageCounter<Object.keys(app.matchesData[userIndex].messages).length; messageCounter++) {
        messagesModel.append({
                                 message: app.matchesData[userIndex].messages[messageCounter].message,
                                 from: app.matchesData[userIndex].messages[messageCounter].from,
                                 createdDate: calculateMessageDate(app.matchesData[userIndex].messages[messageCounter].created_date),
                                 isGif: "type" in app.matchesData[userIndex].messages[messageCounter]
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

function send(match_id, message) {
    python.call("app.matches.send", [match_id, message], function(result) {
        console.log(JSON.stringify(result))
    });
}

function sendGif(match_id, message, gif_id) {
    python.call("app.matches.send", [match_id, message, true, gif_id], function(result) {
        console.log(JSON.stringify(result))
    });
}


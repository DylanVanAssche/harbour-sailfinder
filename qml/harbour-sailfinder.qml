import QtQuick 2.0
import Sailfish.Silica 1.0
import io.thp.pyotherside 1.3
import org.nemomobile.configuration 1.0
import "pages"
import "./pages/js/util.js" as Util
import "./pages/js/updates.js" as Updates

ApplicationWindow
{
    id: app
    initialPage: Component { FirstPage { } }
    cover: Qt.resolvedUrl("cover/CoverPage.qml")
    allowedOrientations: Orientation.All
    _defaultPageOrientations: Orientation.All    
    onCleanup: { // Reset to initial state, except 'pythonReady' since it's already loaded
        authenticatingText = qsTr("Authenticating") + "..."
        headerRecs = qsTr("Recommendations")
        headerMatches = qsTr("Matches")
        headerProfile = qsTr("Profile")
        headerSocial = "" //qsTr("Social") // Sailfinder V3.X
        cover = { background: "../resources/images/cover-background.png", text: "Sailfinder" }
        coverText = "Sailfinder"
        coverBackground = "../resources/images/cover-background.png"
        coverBackgroundRecs = "../resources/images/cover-background.png"
        coverBackgroundMatches = "../resources/images/cover-background.png"
        coverBackgroundProfile = "../resources/images/cover-background.png"
        coverBackgroundSocial = "../resources/images/cover-background.png"
        loadingMatches = true
        cachingMatches = true
        loadingRecs = true
        cachingRecs = true
        loadingProfile = true
        cachingProfile = true
        //loadingSocial = true // Sailfinder V3.X
        //cachingSocial = true
        recsData = {}
        matchesData = {}
        likedMessagesData = {}
        blocksData = {}
        profileData = {}
        //socialData = {} // Sailfinder V3.X
        numberOfMatches = 0
        authenticatingProgress = 0
        banned = false
        parameters.wasOutOfLikes = false
        parameters.last_activity_date = ""
    }
    // Signals
    signal cleanup()
    signal refreshMatches()
    signal refreshRecs()
    signal forceSwipeviewIndex(int swipeIndex)

    // Globals
    readonly property string version: "V3.1";
    property string userId
    property string authenticatingText: qsTr("Authenticating") + "..."
    property string headerRecs: qsTr("Recommendations")
    property string headerMatches: qsTr("Matches")
    property string headerProfile: qsTr("Profile")
    property string headerSocial: "" //qsTr("Social") // Sailfinder V3.X
    property string coverText: "Sailfinder"
    property string coverBackground: "../resources/images/cover-background.png"
    property string coverBackgroundRecs: "../resources/images/cover-background.png"
    property string coverBackgroundMatches: "../resources/images/cover-background.png"
    property string coverBackgroundProfile: "../resources/images/cover-background.png"
    property string coverBackgroundSocial: "../resources/images/cover-background.png"
    property bool loadingRecs: true //On launch we need to load and cache them all
    property bool cachingRecs: true
    property bool loadingMatches: true
    property bool cachingMatches: true
    property bool loadingProfile: true
    property bool cachingProfile: true
    //property bool loadingSocial: true // Sailfinder V3.X
    //property bool cachingSocial: true
    property int numberOfMatches
    property int authenticatingProgress
    property bool banned
    property bool pythonReady
    property bool returnToLogin
    property var recsData
    property var matchesData
    property var likedMessagesData
    property var blocksData
    property var profileData
    //property var socialData // Sailfinder V3.X

    // Check for new data/notifications
    Timer {
        id: incrementalUpdateTimer
        interval: Util.parseInterval(settings.refreshInterval)
        running: false
        repeat: true
        triggeredOnStart: true
        onTriggered: Updates.get(false)
    }

    // Notifications & toaster init
    Toaster { id: toaster }
    NotificationManager { id: notificationSwipeAgain; onActivateApp: {app.activate(); forceSwipeviewIndex(0) }}
    NotificationManager { id: notificationLiked; onActivateApp: {app.activate(); forceSwipeviewIndex(1) } }
    NotificationManager { id: notificationMatches; onActivateApp: {app.activate(); forceSwipeviewIndex(1) } }
    NotificationManager { id: notificationMessages; onActivateApp: {app.activate(); forceSwipeviewIndex(1) } }
    //NotificationManager { id: notificationSocial; onActivateApp: {app.activate(); forceSwipeviewIndex(3) } } //Sailfinder V3.X

    // App settings
    ConfigurationGroup {
        id: settings
        path: "/apps/harbour-sailfinder/settings"

        property bool saveEmail: true
        property bool showBio: true
        property bool showSchool: true
        property bool showJob: true
        property bool showFriends: true
        property bool showInstagram: true
        property bool showSpotify: true
        property bool showNotifications: true
        property bool logging: false
        property int refreshInterval: 1 //Normal refresh interval
        property int imageFormat: 1 //320x320 image size
    }

    // App rememberd parameters
    ConfigurationGroup {
        id: parameters
        path: "/apps/harbour-sailfinder/parameters"

        property bool wasOutOfLikes //Only show notification when we were out of likes, not on every launch
        property string last_activity_date
        property string facebookEmail
    }

    Python {
        id: python
        property bool _networkWasLost

        Component.onCompleted: {
            addImportPath(Qt.resolvedUrl("./backend")); //Add the import path for our QML/Python bridge 'app.py'
            addImportPath(Qt.resolvedUrl("./backend/sailfinder")); //Add import path for our backend module 'sailfinder'
            importModule("platform", function() {   //Add the right import path depending on the architecture of the processor
                if (evaluate("platform.machine()") == "armv7l") {
                    console.info("[INFO] ARM processor detected")
                    addImportPath(Qt.resolvedUrl("./backend/lib/armv7l/"));
                } else {
                    console.info("[INFO] x86 processor detected")
                    addImportPath(Qt.resolvedUrl("./backend/lib/i486/"));
                }

                importModule("app", function() {}); // Import "app" after we imported our platform specific modules
                call("app.cache.clearMeta") // Empty cache
                call("app.cache.clearLogger")
                call("app.cache.clearRecs")
                pythonReady = true
            });

            //Notify user of the current network state
            setHandler("network", function (status) {
                if(!status)
                {
                    toaster.previewBody = qsTr("Network down") + "!"
                    toaster.publish()
                    _networkWasLost = true
                }
                else if (_networkWasLost) {
                    toaster.previewBody = qsTr("Network recovered") + "!"
                    toaster.publish()
                    _networkWasLost = false
                }
            });

            //Notify user of the login progress
            setHandler("loginProgress", function (progress) {
                if(progress <= 50) {
                    authenticatingText = qsTr("Facebook") + " - " + Math.round(progress) + "%"
                }
                else {
                    authenticatingText = qsTr("Tinder") + " - " + Math.round(progress) + "%"
                }
                authenticatingProgress = progress
            });
            setHandler("returnToLogin", function (result) {
                if(result)
                {
                    pageStack.clear()
                    returnToLogin = true //Enforce an Auth reload
                    pageStack.push(Qt.resolvedUrl("pages/FirstPage.qml"))
                }
            });

            // Recommendations progress & data
            setHandler("recsProgress", function (progress) {
                headerRecs = qsTr("Discovering") + " - " + Math.round(progress) + "%";
                cachingRecs = true;
            });
            setHandler("recsData", function (recs) {
                recsData = recs;
                cachingRecs = false;
            });

            // Matches progress & data
            setHandler("matchesProgress", function (progress) {
                headerMatches = qsTr("Refreshing") + " - " + Math.round(progress) + "%";
                cachingMatches = true;
            });
            setHandler("matchesData", function (data) {
                matchesData = data;
                cachingMatches = false;
            });
            setHandler("lastActive", function (date) {
                parameters.last_activity_date = date; // Update last activity date
                incrementalUpdateTimer.start() // Date is updated, start timer
                console.info("[INFO] Updated LAST ACTIVE: " + parameters.last_activity_date);
            });
            setHandler("likedMessages", function (data) {
                likedMessagesData = data;
            });

            // Profile progress & data
            setHandler("profileProgress", function (progress) {
                headerProfile = qsTr("Refreshing") + " - " + Math.round(progress) + "%";
                cachingProfile = true;
            });
            setHandler("profileData", function (profile) {
                profileData = profile;
                app.userId = profile._id;
                cachingProfile = false;
            });

            // Social progress & data
            /*setHandler("socialProgress", function (progress) {
                headerSocial = qsTr("Refreshing") + " - " + Math.round(progress) + "%";
                cachingSocial = true;
            }); // Sailfinder V3.X
            setHandler("socialData", function (social) { socialData = social; cachingSocial = true });*/
        }
        onError: console.error("[ERROR] %1".arg(traceback));
        onReceived: console.info("[INFO] Message: " + JSON.stringify(data));
    }
}


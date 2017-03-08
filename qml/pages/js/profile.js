/*
Sailfinder Profile handles all the interaction in the profile UI
*/


function set() {
    app.loadingProfile = true;
    python.call("app.profile.set", [discoverable.checked, minAge.value, maxAge.value, gender.currentIndex, interestedIn.currentIndex-1, Math.round(distance.value/1.609344), bio.text]);
    discovery = discoverable.checked;
}

function get(refresh) {
    app.loadingProfile = true;
    python.call("app.profile.get", [refresh]);
}

function load() {
    try {
        // Check if user is banned
        if("banned" in app.profileData) {
            app.banned = true;
        }

        var avatarList = [];
        for(var i=0; i<Object.keys(app.profileData.photos).length; i++) {
            avatarList.push(app.profileData.photos[i].processedFiles[0].url);
        }
        avatars.images = avatarList;
        bio.text = app.profileData.bio;
        discoverable.checked = app.profileData.discoverable;
        distance.value = Math.round(app.profileData.distance_filter*1.609344); //Convert to km
        minAge.value = app.profileData.age_filter_min;
        maxAge.value = app.profileData.age_filter_max;
        gender.currentIndex = app.profileData.gender;
        interestedIn.currentIndex = app.profileData.gender_filter+1; //Convert Tinder filter to contextmenu
        app.headerProfile = app.profileData.name + " (" + convertAge(app.profileData.birth_date) +") " + convertGender(app.profileData.gender);

        if (app.profileData.schools.length) {
            if("name" in app.profileData.schools[0]) {
                school.iconText = app.profileData.schools[0].name;
            }

            if("id" in app.profileData.schools[0]) {
                school.link = "https://www.facebook.com/" + app.profileData.schools[0].id;
            }
        }
        else {
            school.iconText = "";
            school.link = "";
        }

        if (app.profileData.jobs.length) {
            if("company" in app.profileData.jobs[0]) {
                if("name" in app.profileData.jobs[0].company) {
                    job.iconText = app.profileData.jobs[0].company.name;
                }

                if ("id" in app.profileData.jobs[0].company) {
                    job.link = "https://www.facebook.com/" + app.profileData.jobs[0].company.id;
                }
            }

            if("title" in app.profileData.jobs[0]) {
                if("name" in app.profileData.jobs[0].company) {
                    job.iconText += " - " + app.profileData.jobs[0].company.name;
                }
                if ((!"id" in app.profileData.jobs[0].company) && ("id" in app.profileData.jobs[0].title)) {
                    job.link = "https://www.facebook.com/" + app.profileData.jobs[0].title.id;
                }
            }
        }
        else {
            job.iconText = "";
            job.link = "";
        }

        loadingProfile = false;
        updateRequired = false;
    }
    catch(err) {
        console.log("[ERROR] Loading profile UI failed due: " + err);
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

function deleteAccount() {
    python.call("app.account.delete");
}

function logout() {
    python.call("app.account.logout");
}

function clear() {
    app.headerProfile = qsTr("Profile");
    avatars.images = [];
    job.iconText = "";
    job.link = "";
    school.iconText = "";
    school.link = "";
    bio.text = "";
    discoverable.checked = false;
    distance.value = 0; //Convert to km
    minAge.value = 18;
    maxAge.value = 18;
    gender.currentIndex = -1;
    interestedIn.currentIndex = -1;
}

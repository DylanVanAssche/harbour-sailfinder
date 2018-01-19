function header(index) {
    switch(index) {
    case 0:
        //% "Recommendations"
        return qsTrId("sailfinder-recommendations")
    case 1:
        //% "Matches"
        return qsTrId("sailfinder-matches")
    case 2:
        var header;
        var age;
        var gender;
        // Check if profile data isn't a NULL pointer or Undefined
        // https://askubuntu.com/questions/527799/how-do-you-check-if-a-property-is-undefined-in-qml
        if(!!api.profile) {
            console.debug("Profile data is valid, setting header...")
            var today = new Date();
            var birthDate = api.profile.birthDate;
            age = today.getFullYear() - birthDate.getFullYear() // Convert from seconds to years
            gender = "♀";
            if(api.profile.gender === 1) {
                gender = "♂";
            }
            header = api.profile.name + " (" + age + ") " + gender;
        }
        else {
            //% "Profile"
            header = qsTrId("sailfinder-profile")
        }
        return header;
    }
}

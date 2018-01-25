// Male = 0
// Female = 1
// Everyone = -1

function createHeaderRecs(name, birthDate, gender) {
    var today = new Date();
    var age = today.getFullYear() - birthDate.getFullYear();
    var genderSymbol = "♀";
    if(gender === 0) {
        genderSymbol = "♂";
    }
    return name + " (" + age + ") " + genderSymbol;
}

function createHeaderProfile(name, birthDate, gender) {
    return createHeaderRecs(name, birthDate, gender);
}

function createHeaderMatches(count) {
    //: Header for matches
    //% "Matches"
    return qsTrId("sailfinder-matches") + " (" + count + ")";
}

function createHeaderMessages(name, birthDate, gender) {
    return createHeaderRecs(name, birthDate, gender);
}

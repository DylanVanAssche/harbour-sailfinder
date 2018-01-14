/*
*   This file is part of Sailfinder.
*
*   Sailfinder is free software: you can redistribute it and/or modify
*   it under the terms of the GNU General Public License as published by
*   the Free Software Foundation, either version 3 of the License, or
*   (at your option) any later version.
*
*   Sailfinder is distributed in the hope that it will be useful,
*   but WITHOUT ANY WARRANTY; without even the implied warranty of
*   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
*   GNU General Public License for more details.
*
*   You should have received a copy of the GNU General Public License
*   along with Sailfinder.  If not, see <http://www.gnu.org/licenses/>.
*/

#include "api.h"

API::API(QObject *parent) : QObject(parent)
{
    // Set authenticated to false at init
    this->setAuthenticated(false);

    // Initiate a new QNetworkAccessManager with cache
    QNAM = new QNetworkAccessManager(this);
    QNetworkConfigurationManager QNAMConfig;
    QNAM->setConfiguration(QNAMConfig.defaultConfiguration());
    QNAMCache = new QNetworkDiskCache(this);
    QNAMCache->setCacheDirectory(SFOS.cacheLocation()+ "/network");
    QNAM->setCache(QNAMCache);
    this->setNetworkEnabled(QNAM->networkAccessible() > 0);

    // Connect QNetworkAccessManager signals
    connect(QNAM, SIGNAL(networkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)), this, SLOT(networkAccessible(QNetworkAccessManager::NetworkAccessibility)));
    connect(QNAM, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)), this, SLOT(sslErrors(QNetworkReply*,QList<QSslError>)));
    connect(QNAM, SIGNAL(finished(QNetworkReply*)), this, SLOT(finished(QNetworkReply*)));

    // Start Location services
    positionUpdateCounter = 0;
    positionSource = QGeoPositionInfoSource::createDefaultSource(this);
    if (positionSource) {
        qDebug() << "Positioning enabled, waiting for fix...";
        connect(positionSource, SIGNAL(positionUpdated(QGeoPositionInfo)), this, SLOT(positionUpdated(QGeoPositionInfo)));
        positionSource->startUpdates();
    }
    else {
        qCritical() << "Positioning not available";
        //: Error shown to the user when an Positioning error occurs. The users could disabled GPS or an other error may be occured.
        //% "Positioning unavailable, check if location services are enabled"
        emit this->errorOccurred(qtTrId("sailfinder-positioning-error"));
    }
}

/**
 * @class API
 * @brief API destructor.
 * @details Deallocates QNetworkAccessManager and QNetworkDiskCache memory space on destruction.
 * By checking if the pointers are set we avoid to delete NULL pointers.
 */
API::~API()
{
    if(QNAM) {
        QNAM->deleteLater();
    }

    if(QNAMCache) {
        QNAMCache->deleteLater();
    }
}

/**
 * @class API
 * @brief Prepare HTTP request
 * @details Tinder API requires the same headers every time so writing them once is easier to maintain.
 * @param url
 * @param parameters
 * @return QNetworkRequest
 */
QNetworkRequest API::prepareRequest(QUrl url, QUrlQuery parameters)
{
    // Set busy state
    this->setBusy(true);

    // Add default URL parameters
    parameters.addQueryItem("locale", "en-GB");
    url.setQuery(parameters);

    // Create QNetworkRequest
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    request.setHeader(QNetworkRequest::UserAgentHeader, TINDER_USER_AGENT);
    request.setRawHeader("accept", "*/*");
    request.setRawHeader("accept-language", "en-GB,en-US;q=0.9,en;q=0.8");
    request.setRawHeader("app-version", "1000000");
    request.setRawHeader("connection", "keep-alive");
    request.setRawHeader("dnt", "1");
    request.setRawHeader("host", "api.gotinder.com");
    request.setRawHeader("origin", "https://tinder.com");
    request.setRawHeader("platform", "web");
    request.setRawHeader("referer", "https://tinder.com");
    if(url.toString() != AUTH_FACEBOOK_ENDPOINT) {
        request.setRawHeader("x-auth-token", this->token().toLocal8Bit());
    }
    request.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferNetwork);
    return request;
}

void API::getMatches(bool withMessages)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(MATCHES_ENDPOINT));
        QUrlQuery parameters;
        if(withMessages) {
            parameters.addQueryItem("message", "1");
        }
        else {
            parameters.addQueryItem("message", "0");
        }

        // Prepare & do request
        QNAM->get(this->prepareRequest(url, parameters));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve recommendations data";
    }
}

/**
 * @class API
 * @brief Authenticate the user with the API
 * @details Retrieve the API token for the user based on it's Facebook access token
 * @param fbToken
 */
void API::login(QString fbToken)
{
    // Build URL
    QUrl url(QString(AUTH_FACEBOOK_ENDPOINT));
    QUrlQuery parameters;

    // Build POST payload
    QVariantMap data;
    data["token"] = fbToken;
    QJsonDocument payload = QJsonDocument::fromVariant(data);

    // Prepare & do request
    QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
}

/**
 * @class API
 * @brief Meta data
 * @details Retrieve the meta data of the account, this can be used for several purposes. Also this endpoint is perfectly to test the validity of the API token.
 * @param latitude, longitude
 */
void API::getMeta(int latitude, int longitude)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(META_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        QVariantMap data;
        data["lat"] = latitude;
        data["lon"] = longitude;
        data["force_fetch_resources"] = true;
        QJsonDocument payload = QJsonDocument::fromVariant(data);

        // Prepare & do request
        QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
    }
    else {
        qWarning() << "Not authenticated, can't retrieve meta data";
    }
}

/**
 * @class API
 * @brief profile data
 * @details Retrieve the profile data of the account which contains information about the user and it's settings
 */
void API::getProfile()
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(PROFILE_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("include","user,plus_control,boost,travel,tutorials,notifications,purchase,products,likes,super_likes,facebook,instagram,spotify,select");

        // Prepare & do request
        QNAM->get(this->prepareRequest(url, parameters));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve profile data";
    }
}

void API::getRecommendations()
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(RECS_ENDPOINT));
        QUrlQuery parameters;

        // Prepare & do request
        QNAM->get(this->prepareRequest(url, parameters));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve recommendations data";
    }
}

void API::getMatchesWithMessages()
{
    this->getMatches(true);
}

void API::getMatchesWithoutMessages()
{
    this->getMatches(false);
}

void API::getUpdates(QDateTime lastActivityDate)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(UPDATES_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        QVariantMap data;
        data["last_activity_date"] = lastActivityDate.toString(Qt::ISODate);
        QJsonDocument payload = QJsonDocument::fromVariant(data);

        // Prepare & do request
        QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
    }
    else {
        qWarning() << "Not authenticated, can't retrieve updates data";
    }
}

/**
 * @class API
 * @brief Parse the positioning
 * @details Handler to parse the positioning signals from QGeoPositionInfoSource
 * @param info
 */
void API::positionUpdated(const QGeoPositionInfo &info)
{
    QGeoCoordinate position = info.coordinate();
    positionUpdateCounter++;

    // Enough accuracy, stop updates
    if (info.hasAttribute(QGeoPositionInfo::HorizontalAccuracy) && info.hasAttribute(QGeoPositionInfo::VerticalAccuracy)) {
        if (info.attribute(QGeoPositionInfo::HorizontalAccuracy) < 1000 && info.attribute(QGeoPositionInfo::VerticalAccuracy) < 1000) {
            qDebug() << "Position fix OK:" << position;
            // Only perform request when API is ready
            if(this->authenticated()) {
                qDebug() << "Authenticated, updating on API and stopping location services";
                this->getMeta(position.latitude(), position.longitude());
                positionSource->stopUpdates();
            }
        }
    }
    // Position fix takes too long
    else if(positionUpdateCounter > POSITION_MAX_UPDATE && this->authenticated()) {
        qWarning() << "No accurate fix aquired, using the best available location:" << position;
        this->getMeta(position.latitude(), position.longitude());
        positionSource->stopUpdates();
    }
    // Wait for next position information
    else {
        qWarning() << "Position fix not accurate enough yet" << positionUpdateCounter << "/" << POSITION_MAX_UPDATE ;
    }
}

int API::persistentPollInterval() const
{
    return m_persistentPollInterval;
}

void API::setPersistentPollInterval(int persistentPollInterval)
{
    m_persistentPollInterval = persistentPollInterval;
}

int API::standardPollInterval() const
{
    return m_standardPollInterval;
}

void API::setStandardPollInterval(int standardPollInterval)
{
    m_standardPollInterval = standardPollInterval;
}

bool API::canLike() const
{
    return m_canLike;
}

void API::setCanLike(bool canLike)
{
    m_canLike = canLike;
}

bool API::canShowCommonConnections() const
{
    return m_canShowCommonConnections;
}

void API::setCanShowCommonConnections(bool canShowCommonConnections)
{
    m_canShowCommonConnections = canShowCommonConnections;
    emit this->canShowCommonConnectionsChanged();
}

bool API::canAddPhotosFromFacebook() const
{
    return m_canAddPhotosFromFacebook;
}

void API::setCanAddPhotosFromFacebook(bool canAddPhotosFromFacebook)
{
    m_canAddPhotosFromFacebook = canAddPhotosFromFacebook;
    emit this->canAddPhotosFromFacebookChanged();
}

bool API::canEditSchools() const
{
    return m_canEditSchools;
}

void API::setCanEditSchools(bool canEditSchools)
{
    m_canEditSchools = canEditSchools;
    emit this->canEditSchoolsChanged();
}

bool API::canEditJobs() const
{
    return m_canEditJobs;
}

void API::setCanEditJobs(bool canEditJobs)
{
    m_canEditJobs = canEditJobs;
    emit this->canEditJobsChanged();
}

User *API::profile() const
{
    return m_profile;
}

void API::setProfile(User *profile)
{
    m_profile = profile;
    emit this->profileChanged();
}


bool API::authenticated() const
{
    return m_authenticated;
}

void API::setAuthenticated(bool authenticated)
{
    m_authenticated = authenticated;
    emit this->authenticatedChanged();
}

/**
 * @class API
 * @brief Logs the networkstate.
 * @details The networkstate can be handy for debugging purposes.
 * @param state
 */
void API::networkAccessible(QNetworkAccessManager::NetworkAccessibility state)
{
    if(state == 0) {
        qInfo() << "Network offline";
        this->setNetworkEnabled(false);
    }
    else {
        qInfo() << "Network online";
        this->setNetworkEnabled(true);
    }
}

/**
 * @class API
 * @brief Logs SSL errors.
 * @param reply
 * @param sslError
 */
void API::sslErrors(QNetworkReply* reply, QList<QSslError> sslError)
{
    qCritical() << "SSL error occured:" << reply->errorString() << sslError;
    //: Error shown to the user when an SSL error occurs due a bad certificate or incorrect time settings.
    //% "SSL error, please check your device is running with the correct date and time"
    emit this->errorOccurred(qtTrId("berail-ssl-error"));
}

/**
 * @class API
 * @brief Handling HTTP replies.
 * @details Handles the Tinder HTTP JSON replies, dispatches them to the right JSON parser
 * and updates the API data with the help of the JSON parsers.
 * @param reply
 */
void API::finished (QNetworkReply *reply)
{
    qInfo() << "Request finished:" << reply->url().toString();
    if(!this->networkEnabled()) {
        qCritical() << "Network inaccesible, can't retrieve API request!";
    }
    else if(reply->error()) {
        if(reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 404 || reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 500)
        {
            qCritical() << reply->errorString();
            //: Error shown to the user when the Tinder API failed to retrieve the requested data
            //% "Tinder API couldn't complete your request"
            emit this->errorOccurred(qtTrId("sailfinder-api-error"));
        }
        else if(reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 401) {
            qWarning() << "X-Auth-Token is not valid (anymore)";
            //% "Tinder token expired, refreshing now"
            emit this->authenticationRequested(qtTrId("sailfinder-api-authentication-requested"));
        }
        else {
            qCritical() << reply->errorString();
            emit this->errorOccurred(reply->errorString());
        }
    }
    else if(reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 301 || reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 302) {
        qWarning() << "HTTP 301/302: Moved, following redirect...";
    }
    else if(reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt() == 304) {
        qDebug() << "HTTP 304: Not-Modified";
    }
    else {
        qDebug() << "Content-Header:" << reply->header(QNetworkRequest::ContentTypeHeader).toString();
        qDebug() << "Content-Length:" << reply->header(QNetworkRequest::ContentLengthHeader).toULongLong() << "bytes";
        qDebug() << "HTTP code:" << reply->attribute(QNetworkRequest::HttpStatusCodeAttribute).toInt();
        qDebug() << "HTTP reason:" << reply->attribute(QNetworkRequest::HttpReasonPhraseAttribute).toString();
        qDebug() << "Cache:" << reply->attribute(QNetworkRequest::SourceIsFromCacheAttribute).toBool();

        // Get the data from the request
        QString replyData = (QString)reply->readAll();

        // Try to parse the data as JSON
        QJsonParseError parseError;
        QJsonDocument jsonData = QJsonDocument::fromJson(replyData.toUtf8(), &parseError);

        // If parsing succesfull, use the data
        if(parseError.error == QJsonParseError::NoError) {
            QJsonObject jsonObject = jsonData.object();

            // Parse data in the right C++ model or database
            if(reply->url().toString().contains(AUTH_FACEBOOK_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder login data received";
                this->parseLogin(jsonObject);
            }
            else if(reply->url().toString().contains(META_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder meta data received";
                this->parseMeta(jsonObject);
            }
            else if(reply->url().toString().contains(UPDATES_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder updates data received";
                this->parseUpdates(jsonObject);
            }
            else if(reply->url().toString().contains(PROFILE_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder profile data received";
                this->parseProfile(jsonObject);
            }
            else if(reply->url().toString().contains(RECS_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder recommendations data received";
                this->parseRecommendations(jsonObject);
            }
            else if(reply->url().toString().contains(MATCHES_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder matches data received";
                this->parseMatches(jsonObject);
            }
            else {
                qWarning() << "Received unhandeled API endpoint: " << reply->url().toString();
            }
        }
        else {
            qCritical() << "Received data isn't properly formatted as JSON! QJsonParseError:" << parseError.errorString();
            //: Error shown to the user when the data is invalid JSON data
            //% "Invalid JSON data received, please try again later"
            emit this->errorOccurred(qtTrId("sailfinder-json-error"));
        }
    }

    reply->deleteLater();
    this->setBusy(false);
}

void API::parseLogin(QJsonObject json)
{
    QJsonObject login = json["data"].toObject();
    this->setToken(login["api_token"].toString());
    this->setIsNewUser(login["is_new_user"].toBool());
    this->setAuthenticated(this->token().length() > 0);

    qDebug() << "Login data:";
    qDebug() << "\tToken:" << this->token();
    qDebug() << "\tisNewUser" << this->isNewUser();
}

void API::parseMeta(QJsonObject json)
{
    QJsonObject meta = json["data"].toObject();
    this->setCanEditJobs(meta["can_edit_jobs"].toBool());
    this->setCanEditSchools(meta["can_edit_schools"].toBool());
    this->setCanAddPhotosFromFacebook(meta["can_add_photos_from_facebook"].toBool());
    this->setCanShowCommonConnections(meta["can_show_common_connections"].toBool());

    qDebug() << "Meta data:";
    qDebug() << "\tCan edit jobs:" << this->canEditJobs();
    qDebug() << "\tCan edit schools:" << this->canEditSchools();
    qDebug() << "\tCan add photos from Facebook:" << this->canAddPhotosFromFacebook();
    qDebug() << "\tCan show common connections:" << this->canShowCommonConnections();
}

void API::parseUpdates(QJsonObject json)
{
    // TODO: Parse the update data and update the models for matches, send notifications, ...
    QJsonObject pollingData = json["poll_interval"].toObject();
    this->setStandardPollInterval(pollingData["standard"].toInt());
    this->setPersistentPollInterval(pollingData["persistent"].toInt());

    qDebug() << "Updates data:";
    qDebug() << "\tPolling interval standard:" << this->standardPollInterval();
    qDebug() << "\tPolling interval persitent:" << this->persistentPollInterval();
}

void API::parseProfile(QJsonObject json)
{
    QJsonObject user = json["data"].toObject()["user"].toObject();
    QJsonObject likes = json["data"].toObject()["likes"].toObject();
    QList<Photo *> photoList;
    QList<School *> schoolList;
    QList<Job *> jobList;
    bool canLike = likes["likes_remaining"].toInt() > 0;
    int ageMin = user["age_filter_min"].toInt();
    int ageMax = user["age_filter_max"].toInt();
    QString bio = user["bio"].toString();
    QDateTime birthDate = QDateTime::fromString(user["birth_date"].toString(), Qt::ISODate);
    int distanceMax = user["distance_filter"].toInt();
    bool discoverable = user["discoverable"].toBool();
    Sailfinder::Gender gender = Sailfinder::Gender::Female;
    if(user["gender"].toInt() == 0) { // Default female, change if needed
        gender = Sailfinder::Gender::Male;
    }

    Sailfinder::Gender interestedIn = Sailfinder::Gender::Female;
    if(user["interested_in"].toArray().count() > 1) { // Both genders
        interestedIn = Sailfinder::Gender::All;
    }
    else if(user["interested_in"].toArray().at(0) == 0) { // Change to male only
        interestedIn = Sailfinder::Gender::Male;
    }
    QString name = user["name"].toString();
    QString id = user["_id"].toString();
    double latitude = user["pos"].toObject()["lat"].toDouble();
    double longitude = user["pos"].toObject()["lon"].toDouble();
    QGeoCoordinate position;
    position.setLatitude(latitude);
    position.setLongitude(longitude);

    foreach(QJsonValue item, user["photos"].toArray()) {
        QJsonObject photo = item.toObject();
        photoList.append(new Photo(photo["id"].toString(), photo["url"].toString()));
    }

    foreach(QJsonValue item, user["schools"].toArray()) {
        QJsonObject school = item.toObject();
        // Name is needed but ID might be missing sometimes!
        if(school.value("id") != QJsonValue::Undefined) {
            schoolList.append(new School(school["id"].toString(), school["name"].toString()));
        }
        else {
            qWarning() << "School id is missing";
            schoolList.append(new School(school["name"].toString()));
        }
    }

    foreach(QJsonValue item, user["jobs"].toArray()) {
        QJsonObject job = item.toObject();
        // Name is needed but ID might be missing sometimes!
        if(job.value("id") != QJsonValue::Undefined) {
            jobList.append(new Job(job["id"].toString(), job["name"].toString()));
        }
        else {
            qWarning() << "Job id is missing";
            jobList.append(new Job(job["name"].toString()));
        }
    }

    qDebug() << "Profile data:";
    qDebug() << "\tName:" << name;
    qDebug() << "\tBirthdate:" << birthDate;
    qDebug() << "\tBio:" << bio;
    qDebug() << "\tAge min:" << ageMin;
    qDebug() << "\tAge max:" << ageMax;
    qDebug() << "\tGender:" << (int)(gender);
    qDebug() << "\tDistance max:" << distanceMax;
    qDebug() << "\tInterested in:" << (int)(interestedIn);
    qDebug() << "\tPosition:" << position;
    qDebug() << "\tDiscoverable:" << discoverable;
    qDebug() << "\tPhotos:" << photoList;
    qDebug() << "\tSchools:" << schoolList;
    qDebug() << "\tJobs:" << jobList;
    qDebug() << "\tCan like:" << canLike;

    this->setCanLike(canLike);
    this->setProfile(new User(id, name, birthDate, gender, bio, schoolList, jobList, photoList, ageMin, ageMax, distanceMax, interestedIn, position, discoverable));
}

void API::parseRecommendations(QJsonObject json)
{
    QList<Recommendation *> recsList;
    foreach(QJsonValue item, json["results"].toArray()) {
        QList<Photo *> photoList;
        QList<School *> schoolList;
        QList<Job *> jobList;
        QJsonObject recommendation = item.toObject()["user"].toObject();
        int distance = recommendation["distance_mi"].toInt();
        QString contentHash = recommendation["content_hash"].toString();
        int sNumber = recommendation["s_number"].toInt();
        Sailfinder::Gender gender = Sailfinder::Gender::Female;
        if(recommendation["gender"].toInt() == 0) { // Default female, change if needed
            gender = Sailfinder::Gender::Male;
        }
        QString id = recommendation["_id"].toString();
        QString bio = recommendation["bio"].toString();
        QDateTime birthDate = QDateTime::fromString(recommendation["birth_date"].toString(), Qt::ISODate);
        QString name = recommendation["name"].toString();
        foreach(QJsonValue item, recommendation["photos"].toArray()) {
            QJsonObject photo = item.toObject();
            photoList.append(new Photo(photo["id"].toString(), photo["url"].toString()));
        }

        foreach(QJsonValue item, recommendation["schools"].toArray()) {
            QJsonObject school = item.toObject();
            // Name is needed but ID might be missing sometimes!
            if(school.value("id") != QJsonValue::Undefined) {
                schoolList.append(new School(school["id"].toString(), school["name"].toString()));
            }
            else {
                qWarning() << "School id is missing";
                schoolList.append(new School(school["name"].toString()));
            }
        }

        foreach(QJsonValue item, recommendation["jobs"].toArray()) {
            QJsonObject job = item.toObject();
            // Name is needed but ID might be missing sometimes!
            if(job.value("id") != QJsonValue::Undefined) {
                jobList.append(new Job(job["id"].toString(), job["name"].toString()));
            }
            else {
                qWarning() << "Job id is missing";
                jobList.append(new Job(job["name"].toString()));
            }
        }

        recsList.append(new Recommendation(id, name, birthDate, gender, bio, schoolList, jobList, photoList, contentHash, sNumber, distance));

        qDebug() << "Recommendation data:";
        qDebug() << "\tName:" << name;
        qDebug() << "\tBirthdate:" << birthDate;
        qDebug() << "\tBio:" << bio;
        qDebug() << "\tDistance:" << distance;
        qDebug() << "\tPhotos:" << photoList;
        qDebug() << "\tSchools:" << schoolList;
        qDebug() << "\tJobs:" << jobList;
        qDebug() << "\tContentHash:" << contentHash;
        qDebug() << "\tSNumber:" << sNumber;
        qDebug() << "\tGender:" << (int)(gender);
    }
    // SET HERE THE QABSTRACTLISTMODEL CONTAINING OUR QLIST
}

void API::parseMatches(QJsonObject json)
{
    QList<Match *> matchesList;
    QJsonObject matchesData = json["data"].toObject();
    foreach(QJsonValue item, matchesData["matches"].toArray()) {
        QList<Photo *> photoList;
        QJsonObject match = item.toObject();
        QJsonObject person = match["person"].toObject();

        // Match related data
        QString matchId = match["_id"].toString();

        // Person with who the user matched with data
        QString name = person["name"].toString();
        QString id = person["_id"].toString();
        QString bio = person["bio"].toString();
        QDateTime birthDate = QDateTime::fromString(person["birth_date"].toString(), Qt::ISODate);

        foreach(QJsonValue item, person["photos"].toArray()) {
            QJsonObject photo = item.toObject();
            photoList.append(new Photo(photo["id"].toString(), photo["url"].toString()));
        }
    }

    qDebug() << "Matches data received";
}

QString API::token() const
{
    return m_token;
}

void API::setToken(const QString &token)
{
    m_token = token;
    this->tokenChanged();
}

bool API::networkEnabled() const
{
    return m_networkEnabled;
}

void API::setNetworkEnabled(bool networkEnabled)
{
    m_networkEnabled = networkEnabled;
    this->networkEnabledChanged();
}

bool API::busy() const
{
    return m_busy;
}

void API::setBusy(bool busy)
{
    m_busy = busy;
    this->busyChanged();
}

bool API::isNewUser() const
{
    return m_isNewUser;
}

void API::setIsNewUser(bool isNewUser)
{
    m_isNewUser = isNewUser;
    emit this->isNewUserChanged();
}

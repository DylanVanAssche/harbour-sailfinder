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
    QNAMCache = new QNetworkDiskCache(this);
    QNAMCache->setCacheDirectory(SFOS.cacheLocation()+ "/network");
    QNAM->setCache(QNAMCache);
    this->setNetworkEnabled(QNAM->networkAccessible() > 0);

    // Connect QNetworkAccessManager signals
    connect(QNAM, SIGNAL(networkAccessibleChanged(QNetworkAccessManager::NetworkAccessibility)), this, SLOT(networkAccessible(QNetworkAccessManager::NetworkAccessibility)));
    connect(QNAM, SIGNAL(sslErrors(QNetworkReply*,QList<QSslError>)), this, SLOT(sslErrors(QNetworkReply*,QList<QSslError>)));
    connect(QNAM, SIGNAL(finished(QNetworkReply*)), this, SLOT(finished(QNetworkReply*)));

    // Initiate a new QTimer for QNAM timeout check
    QNAMTimeoutTimer = new QTimer(this);
    QNAMTimeoutTimer->setInterval(TIMEOUT_TIME);
    connect(QNAMTimeoutTimer, SIGNAL(timeout()), this, SLOT(timeoutOccured()));

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
    request.setRawHeader("app-version", TINDER_APP_VERSION);
    request.setRawHeader("connection", "keep-alive");
    request.setRawHeader("dnt", "1");
    request.setRawHeader("host", "api.gotinder.com");
    request.setRawHeader("origin", "https://tinder.com");
    request.setRawHeader("platform", "web");
    request.setRawHeader("referer", "https://tinder.com");
    if(url.toString() != AUTH_FACEBOOK_ENDPOINT) { // not needed when we're authenticating
        request.setRawHeader("x-auth-token", this->token().toLocal8Bit());
    }
    request.setAttribute(QNetworkRequest::FollowRedirectsAttribute, true);
    request.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::PreferNetwork);
    return request;
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
    QNetworkReply* reply = QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
    connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
}

/**
 * @class API
 * @brief Meta data
 * @details Retrieve the meta data of the account, this can be used for several purposes. Also this endpoint is perfectly to test the validity of the API token.
 * @param latitude, longitude
 */
void API::getMeta(double latitude, double longitude)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(META_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        QVariantMap data;
        data["force_fetch_resources"] = true;
        data["lat"] = latitude;
        data["lon"] = longitude;
        QJsonDocument payload = QJsonDocument::fromVariant(data);
        qDebug() << "Tinder meta data: " << data;

        // Prepare & do request
        QNetworkReply* reply = QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
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
    if(this->authenticated() && !profileFetchLock) {
        // Lock profile fetching
        profileFetchLock = true;

        // Build URL
        QUrl url(QString(PROFILE_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("include","user,plus_control,boost,travel,tutorials,notifications,purchase,products,likes,super_likes,facebook,instagram,spotify,select");

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(profileFetchLock) {
        qWarning() << "Profile fetching is locked";
    }
    else {
        qWarning() << "Not authenticated, can't retrieve profile data";
    }
}

void API::getRecommendations()
{
    if(this->authenticated() && !recommendationsFetchLock) {
        // Lock recommendations fetching
        recommendationsFetchLock = true;

        // Build URL
        QUrl url(QString(RECS_ENDPOINT));
        QUrlQuery parameters;

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(recommendationsFetchLock) {
        qWarning() << "Recommendations fetching is locked";
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

void API::getMatchesAll()
{
    if(this->authenticated() && !matchFetchLock) {
        // Lock matches fetching
        matchFetchLock = true;

        // Build URL
        QUrl url(QString(MATCHES_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("count", "60");

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(matchFetchLock) {
        qWarning() << "Skipping matches fetching since locked by other request";
    }
    else {
        qWarning() << "Not authenticated, can't retrieve matches data";
    }
}

void API::getMatches(bool withMessages)
{
    if(this->authenticated() && !matchFetchLock) {
        // Lock matches fetching
        matchFetchLock = true;

        // Build URL
        QUrl url(QString(MATCHES_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("count", "60");
        if(withMessages) {
            parameters.addQueryItem("message", "1");
        }
        else {
            parameters.addQueryItem("message", "0");
        }

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(matchFetchLock) {
        qWarning() << "Skipping matches fetching since locked by other request";
    }
    else {
        qWarning() << "Not authenticated, can't retrieve matches data";
    }
}

void API::getMatches(QString pageToken)
{
    if(this->authenticated()) {
        // Lock matches fetching
        matchFetchLock = true;

        // Build URL
        QUrl url(QString(MATCHES_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("count", "60");
        parameters.addQueryItem("page_token", pageToken);

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve matches data";
    }
}

void API::getMessages(QString matchId, QString pageToken)
{
    if(this->authenticated()) {
        // Lock matches fetching
        messagesFetchLock = true;

        // Build URL
        QUrl url(QString(MATCHES_ENDPOINT) + "/" + matchId + QString(MESSAGES_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("count", "100");
        parameters.addQueryItem("page_token", pageToken);

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve messages data";
    }
}

void API::getUpdates(QDateTime lastActivityDate)
{
    if(this->authenticated() && !updatesFetchLock) {
        // Lock updates fetching
        updatesFetchLock = true;

        // Build URL
        QUrl url(QString(UPDATES_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        QVariantMap data;
        data["nudge"] = false;
        data["last_activity_date"] = lastActivityDate.toString(Qt::ISODate) + "Z"; // Qt::ISODate doesn't include the required 'Z'
        QJsonDocument payload = QJsonDocument::fromVariant(data);

        // Prepare & do request
        QNetworkReply* reply = QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(updatesFetchLock) {
        qWarning() << "Updates fetching locked";
        emit this->updatesReady(lastActivityDate, false); // Restarting updates timer on failure
    }
    else {
        qWarning() << "Not authenticated, can't retrieve updates data";
        emit this->updatesReady(lastActivityDate, false);
    }
}

void API::getMessages(QString matchId)
{
    if(this->authenticated() && !messagesFetchLock) {
        // Lock message fetching
        messagesFetchLock = true;

        // Save the matchId for pagination
        // It's includedin every message but there's always a chance that the payload empty is
        messagesMatchId = matchId;

        // Build URL
        QUrl url(QString(MATCHES_ENDPOINT) + "/" + matchId + QString(MESSAGES_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("count", "100");

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(messagesFetchLock) {
        qWarning() << "Messages fetching is locked";
    }
    else {
        qWarning() << "Not authenticated, can't retrieve messages data";
    }
}

void API::sendMessage(QString matchId, QString message, QString userId, QString tempMessageId)
{
    // Build POST payload for text message
    QVariantMap data;
    data["matchId"] = matchId;
    data["message"] = message;
    data["tempMessageId"] = tempMessageId;
    data["userId"] = userId;
    QJsonDocument payload = QJsonDocument::fromVariant(data);
    this->sendMessage(payload);
}

void API::sendGIF(QString matchId, QString url, QString gifId, QString userId, QString tempMessageId)
{
    // Build POST payload for GIF message
    QVariantMap data;
    data["matchId"] = matchId;
    data["message"] = url;
    data["gif_id"] = gifId;
    data["type"] = "gif";
    data["tempMessageId"] = tempMessageId;
    data["userId"] = userId;
    QJsonDocument payload = QJsonDocument::fromVariant(data);
    this->sendMessage(payload);
}

void API::likeUser(QString userId)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(LIKE_ENDPOINT) + "/" + userId);
        QUrlQuery parameters;

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve like data";
    }
}

void API::passUser(QString userId)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(PASS_ENDPOINT) + "/" + userId);
        QUrlQuery parameters;

        // Prepare & do request
        QNetworkReply* reply= QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve pass data";
    }
}

void API::superlikeUser(QString userId)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(LIKE_ENDPOINT) + "/" + userId + QString(SUPERLIKE_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        // Empty POST data for this endpoint but it's required to use HTTP POST request
        QVariantMap data;
        QJsonDocument payload = QJsonDocument::fromVariant(data);

        // Prepare & do request
        QNetworkReply* reply = QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve superlike data";
    }
}

void API::nextRecommendation()
{
    // Recommendations list is valid
    if(this->recsList().length() > 0) {

        // When out of recommendations, start HTTP request
        if(this->recsList().length() <= recommendationCounter) {
            qDebug() << "Out of recommendations, retrieving...";
            this->getRecommendations();
        }
        // Retrieve the recommendation and increment the iterator counter
        else {
            this->setRecommendation(this->recsList().at(recommendationCounter));
            recommendationCounter++;
            qDebug() << "Pushing next recommendation:";
            qDebug() << "\tId:" << this->recommendation()->id();
        }
    }
    else {
        qCritical() << "Recommendation list is NULL";
    }
}

void API::updateProfile(QString bio, int ageMin, int ageMax, int distanceMax, Sailfinder::Gender interestedIn, bool discoverable, bool optimizer)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(PROFILE_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        QVariantMap data;
        QVariantMap dataUser;
        int genderFilter = -1;
        bool updateRequired = false;

        switch(interestedIn) {
        case Sailfinder::Gender::All:
            genderFilter = -1;
            break;
        case Sailfinder::Gender::Male:
            genderFilter = 0;
            break;
        case Sailfinder::Gender::Female:
            genderFilter = 1;
            break;
        default:
            qCritical() << "Unknown interestedIn gender";
            break;
        }

        // We only want to update different values
        if(this->profile()->bio() != bio) {
            qDebug() << "'Bio' is different";
            dataUser["bio"] = bio;
            updateRequired = true;
        }

        if(this->profile()->interestedIn() != interestedIn) {
            qDebug() << "'Interested in' is different";
            dataUser["gender_filter"] = genderFilter;
            updateRequired = true;
        }

        if(this->profile()->distanceMax() != distanceMax) {
            qDebug() << "'DistanceMax' is different";
            dataUser["distance_filter"] = distanceMax;
            updateRequired = true;
        }

        if(this->profile()->ageMin() != ageMin) {
            qDebug() << "'Min age' different";
            dataUser["age_filter_min"] = ageMin;
            updateRequired = true;
        }

        if(this->profile()->ageMax() != ageMax) {
            qDebug() << "'Max age' different";
            dataUser["age_filter_max"] = ageMax;
            updateRequired = true;
        }

        if(this->profile()->discoverable() != discoverable) {
            qDebug() << "'Discoverable' different";
            dataUser["discoverable"] = discoverable;
            updateRequired = true;
        }

        if(this->profile()->optimizer() != optimizer) {
            qDebug() << "Optimizer' different";
            dataUser["photo_optimizer_enabled"] = optimizer;
            updateRequired = true;
        }

        data["user"] = dataUser;
        QJsonDocument payload = QJsonDocument::fromVariant(data);

        // Prepare & do request if update is required
        if(updateRequired) {
            QNetworkReply* reply = QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
            connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
            connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        }
        else {
            qDebug() << "No profile data has been changed, skipping update...";
        }
    }
    else {
        qWarning() << "Not authenticated, can't retrieve superlike data";
    }
}

void API::logout()
{
    if(this->authenticated()) {
        // Clear Webkit cache for Facebook authentication
        const QString cachePath = SFOS.cacheLocation() + "/" + SFOS.appName() + "/.QtWebKit";
        QDir webcache(cachePath);
        if (webcache.exists()) {
            if (webcache.removeRecursively()) {
                qInfo() << "Succesfully cleared webview cache:" << cachePath;
            }
            else {
                qCritical() << "Clearing webview cache failed:" << cachePath;
                //: Error shown to the user when logging out of Facebook failed
                //% "Logout error, please try again later"
                emit this->errorOccurred(qtTrId("sailfinder-logout-error"));
            }
        }
        else {
            qWarning() << "Webview cache not found:" << cachePath << " logged in via SMS?";
        }

        // Build URL
        QUrl url(QString(AUTH_LOGOUT_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        // Empty POST data for this endpoint but it's required to use HTTP POST request
        QVariantMap data;
        QJsonDocument payload = QJsonDocument::fromVariant(data);

        // Prepare & do request
        QNetworkReply* reply = QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve logout data";
    }
}

void API::unmatch(QString matchId)
{
    if(this->authenticated()) {
        // Build URL
        QUrl url(QString(MATCH_OPERATIONS_ENDPOINT) + "/" + matchId);
        QUrlQuery parameters;

        // Prepare & do request
        QNetworkReply* reply = QNAM->deleteResource(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else {
        qWarning() << "Not authenticated, can't retrieve unmatch data";
    }
}

/**
 * @class API
 * @brief Upload photo
 * @details Upload a photo to the user profile
 * @param path
 */
void API::uploadPhoto(QString path)
{
    if(this->authenticated() && !uploadPhotoLock) {
        // Lock photo upload
        uploadPhotoLock = true;

        // Build URL
        QUrl url(QString(IMAGE_ENDPOINT));
        QUrlQuery parameters;
        parameters.addQueryItem("client_photo_id", QString("{photoId}?client_photo_id=ProfilePhoto%1").arg(QDateTime::currentMSecsSinceEpoch()));
        qDebug() << url;

        // Build multipart
        QHttpMultiPart *multiPart = new QHttpMultiPart(QHttpMultiPart::FormDataType);
        QHttpPart imagePart; // Create imagePart and set headers
        imagePart.setHeader(QNetworkRequest::ContentDispositionHeader, QVariant("form-data; name=\"file\"; filename=\"blob\""));
        imagePart.setHeader(QNetworkRequest::ContentTypeHeader, QVariant("image/jpeg"));
        QFile *file = new QFile(path); // Read image
        file->open(QIODevice::ReadOnly);
        imagePart.setBodyDevice(file); // Attach file to imagePart
        file->setParent(multiPart); // Delete file when multiPart is deleted
        multiPart->append(imagePart);

        // Prepare & do request
        QNetworkRequest request = this->prepareRequest(url, parameters);
        request.setHeader(QNetworkRequest::ContentTypeHeader, "multipart/form-data; boundary=" + multiPart->boundary()); // special content-type header
        qDebug() << request.header(QNetworkRequest::ContentTypeHeader);
        QNetworkReply* reply = QNAM->post(request, multiPart);
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        multiPart->setParent(reply); // Delete multiPart when reply is deleted
    }
}

/**
 * @class API
 * @brief Upload photo
 * @details Upload a photo to the user profile
 * @warning: Tinder uses a body when performing a HTTP DELETE, this isn't supported by QNetworkAccessManager!
 * @param path
 */
void API::removePhoto(QString photoId)
{
    if(this->authenticated() && !removePhotoLock) {
        // Lock photo remover
        removePhotoLock = true;

        // Build URL
        QUrl url(QString(MEDIA_ENDPOINT));
        QUrlQuery parameters;

        // Build POST payload
        // https://stackoverflow.com/questions/34065735/qnetworkaccessmanager-how-to-send-patch-request
        QVariantMap data;
        QList<QVariant> assets;
        assets.append(photoId);
        data["assets"] = assets;
        qDebug() << data;

        QJsonDocument payload = QJsonDocument::fromVariant(data);
        qDebug() << payload;
        QBuffer *payloadBuffer = new QBuffer();
        payloadBuffer->open(QBuffer::ReadWrite);
        payloadBuffer->write(payload.toJson());
        payloadBuffer->seek(0);

        // Prepare & do custom request
        QNetworkReply* reply = QNAM->sendCustomRequest(this->prepareRequest(url, parameters), "DELETE", payloadBuffer);
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        //payloadBuffer->deleteLater();
    }
    else {
        qWarning() << "Not authenticated, can't remove photo";
    }
}

/**
 * @class API
 * @brief Full profile of a match
 * @details Retrieves the missing items of a match it's profile like distance, schools, jobs, ...
 * @param userId
 */
void API::getFullMatchProfile(QString userId)
{
    if(this->authenticated() && !fullMatchProfileLock) {
        // Lock recommendations fetching
        fullMatchProfileLock = true;

        // Build URL
        QUrl url(QString(USER_ENDPOINT) + "/" + userId);
        QUrlQuery parameters;

        // Prepare & do request
        QNetworkReply* reply = QNAM->get(this->prepareRequest(url, parameters));
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(fullMatchProfileLock) {
        qWarning() << "Full match profile fetching is locked";
    }
    else {
        qWarning() << "Not authenticated, can't retrieve recommendations data";
    }
}

int API::getBearerType()
{
    return QNAM->configuration().bearerType();
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

MessageListModel *API::messages() const
{
    return m_messages;
}

void API::setMessages(MessageListModel *messages)
{
    m_messages = messages;
    emit this->messagesChanged();
}

bool API::hasRecommendations() const
{
    return m_hasRecommendations;
}

void API::setHasRecommendations(bool hasRecommendations)
{
    m_hasRecommendations = hasRecommendations;
    emit this->hasRecommendationsChanged();
}

Recommendation *API::recommendation() const
{
    return m_recommendation;
}

void API::setRecommendation(Recommendation *recommendation)
{
    m_recommendation = recommendation;
    emit this->recommendationChanged();
}

MatchesListModel *API::matchesList() const
{
    return m_matchesList;
}

void API::setMatchesList(MatchesListModel *matchesList)
{
    m_matchesList = matchesList;
    emit this->matchesListChanged();
}

QList<Recommendation *> API::recsList() const
{
    return m_recsList;
}

void API::setRecsList(const QList<Recommendation *> &recsList)
{
    m_recsList = recsList;
    emit this->recsListChanged();
}

bool API::canSuperlike() const
{
    return m_canSuperlike;
}

void API::setCanSuperlike(bool canSuperlike)
{
    m_canSuperlike = canSuperlike;
    emit this->canSuperlikeChanged();
}

int API::persistentPollInterval() const
{
    return m_persistentPollInterval;
}

void API::setPersistentPollInterval(int persistentPollInterval)
{
    m_persistentPollInterval = persistentPollInterval;
    emit this->persistentPollIntervalChanged();
}

int API::standardPollInterval() const
{
    return m_standardPollInterval;
}

void API::setStandardPollInterval(int standardPollInterval)
{
    m_standardPollInterval = standardPollInterval;
    emit this->standardPollIntervalChanged();
}

bool API::canLike() const
{
    return m_canLike;
}

void API::setCanLike(bool canLike)
{
    m_canLike = canLike;
    emit this->canLikeChanged();
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
    emit this->errorOccurred(qtTrId("sailfinder-ssl-error"));
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
    QNAMTimeoutTimer->stop(); // request complete
    if(!this->networkEnabled()) {
        qCritical() << "Network inaccesible, can't retrieve API request!";
        // Network offline, unlock all endpoints
        this->unlockAll();
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

        // Unlock all on critical errors
        this->unlockAll();
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
            else if(reply->url().toString().contains(MATCHES_ENDPOINT, Qt::CaseInsensitive) && !reply->url().toString().contains(MESSAGES_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder matches data received";
                this->parseMatches(jsonObject);
            }
            else if(reply->url().toString().contains(MESSAGES_ENDPOINT, Qt::CaseInsensitive) && reply->url().toString().contains(MATCHES_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder messages data received";
                this->parseMessages(jsonObject);
            }
            else if(reply->url().toString().contains(LIKE_ENDPOINT, Qt::CaseInsensitive) && !reply->url().toString().contains(SUPERLIKE_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder like data received";
                this->parseLike(jsonObject);
            }
            else if(reply->url().toString().contains(PASS_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder pass data received";
                this->parsePass(jsonObject);
            }
            else if(reply->url().toString().contains(SUPERLIKE_ENDPOINT, Qt::CaseInsensitive) && reply->url().toString().contains(LIKE_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder superlike data received";
                this->parseSuperlike(jsonObject);
            }
            else if(reply->url().toString().contains(AUTH_LOGOUT_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder logout data received";
                this->parseLogout(jsonObject);
            }
            else if(reply->url().toString().contains(MATCH_OPERATIONS_ENDPOINT, Qt::CaseInsensitive) && reply->operation() == QNetworkAccessManager::Operation::DeleteOperation) {
                qDebug() << "Tinder unmatch data received";
                this->parseUnmatch(jsonObject);
            }
            else if(reply->url().toString().contains(MATCH_OPERATIONS_ENDPOINT, Qt::CaseInsensitive) && reply->operation() == QNetworkAccessManager::Operation::PostOperation) {
                qDebug() << "Tinder send message data received";
                this->parseSendMessage(jsonObject);
            }
            else if(reply->url().toString().contains(USER_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder full match profile received";
                this->parseFullMatchProfile(jsonObject);
            }
            else if(reply->url().toString().contains(MEDIA_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder remove picture data received";
                this->parseRemovePhoto(jsonObject);
            }
            else if(reply->url().toString().contains(IMAGE_ENDPOINT, Qt::CaseInsensitive)) {
                qDebug() << "Tinder upload picture data received";
                this->parseUploadPhoto(jsonObject);
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

void API::timeoutOccured()
{
    qDebug() << "Timeout detected, resetting network access";

    QNAM->setNetworkAccessible(QNetworkAccessManager::NotAccessible);
    this->unlockAll();
    QNAM->setNetworkAccessible(QNetworkAccessManager::Accessible);

    //: Error shown to the user when a network timeout was received
    //% "Network timeout"
    emit this->errorOccurred(qtTrId("sailfinder-timeout-error"));
}

void API::timeoutChecker(qint64 bytesReceived, qint64 bytesTotal)
{
    if(bytesReceived > -1 && bytesTotal > -1) {
        qDebug() << "Progress:" << bytesReceived << " bytes received of " << bytesTotal << "bytes";
        QNAMTimeoutTimer->start(); // restart timer
    }
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
    QJsonObject meta = json["data"].toObject()["profile"].toObject();
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
    QJsonArray matchesArray = json["matches"].toArray();
    bool refetch = false;
    int newMatchesCount = 0;
    int newMessagesCount = 0;

    if(matchesArray.count() > 0) {
        qDebug() << "Matches updates received";
        foreach(QJsonValue item, matchesArray) {
            QJsonObject match = item.toObject();
            if(match["messages"].toArray().count() > 0) {
                if(this->profile() != NULL) {
                    qDebug() << "Counting new messages";
                    foreach (QJsonValue item, match["messages"].toArray()) {
                        QJsonObject message = item.toObject();
                        if(message["to"].toString() == this->profile()->id()) {
                            newMessagesCount++;
                        }
                    }
                }
                else {
                    qCritical() << "Can't determine update messages origin since profile date is NULL";
                }
            }
            else {
                qDebug() << "Counting new matches";
                newMatchesCount++;
            }
        }

        if(newMatchesCount > 0) {
            emit this->newMatch(newMatchesCount);
        }

        if(newMessagesCount > 0) {
            emit this->newMessage(newMessagesCount);
        }
        refetch = true;
    }

    QJsonArray blocksArray = json["blocks"].toArray();
    if(blocksArray.count() > 0) {
        qDebug() << "Blocks data received";
        refetch = true;
    }

    QJsonObject pollingData = json["poll_interval"].toObject();
    this->setStandardPollInterval(pollingData["standard"].toInt());
    this->setPersistentPollInterval(pollingData["persistent"].toInt());

    qDebug() << "Updates data:";
    qDebug() << "\tPolling interval standard:" << this->standardPollInterval();
    qDebug() << "\tPolling interval persitent:" << this->persistentPollInterval();
    qDebug() << "\tMatches:" << newMatchesCount;
    qDebug() << "\tMessages:" << newMessagesCount;
    qDebug() << "\tBlocks:" << blocksArray.count();

    emit this->updatesReady(QDateTime::fromString(json["last_activity_date"].toString(), Qt::ISODate), refetch);

    // Unlock updates fetching
    updatesFetchLock = false;
}

void API::parseProfile(QJsonObject json)
{
    QList<Photo *> photoList;
    QList<School *> schoolList;
    QList<Job *> jobList;

    // Only update when 'likes' included
    if(json["data"].toObject().value("likes") != QJsonValue::Undefined) {
        QJsonObject likes = json["data"].toObject()["likes"].toObject();
        bool canLike = likes["likes_remaining"].toInt() > 0;
        this->setCanLike(canLike);
        qDebug() << "\tCan like:" << canLike;
    }

    // Only update when 'super_likes' included
    if(json["data"].toObject().value("super_likes") != QJsonValue::Undefined) {
        QJsonObject superlikes = json["data"].toObject()["super_likes"].toObject();
        bool canSuperlike = superlikes["remaining"].toInt() > 0;
        this->setCanSuperlike(canSuperlike);
        qDebug() << "\tCan superlike:" << canSuperlike << "remaining:" << superlikes["remaining"].toInt();
    }

    // Only update when 'user' included
    if(json["data"].toObject().value("user") != QJsonValue::Undefined) {
        QJsonObject user = json["data"].toObject()["user"].toObject();
        int ageMin = user["age_filter_min"].toInt();
        int ageMax = user["age_filter_max"].toInt();
        QString bio = user["bio"].toString();
        QDateTime birthDate = QDateTime::fromString(user["birth_date"].toString(), Qt::ISODate);
        int distanceMax = user["distance_filter"].toInt();
        bool discoverable = user["discoverable"].toBool();
        bool optimizer = user["photo_optimizer_enabled"].toBool();;
        Sailfinder::Gender gender = Sailfinder::Gender::Female;
        if(user["gender"].toInt() == (int)Sailfinder::Gender::Male) { // Default female, change if needed
            gender = Sailfinder::Gender::Male;
        }

        Sailfinder::Gender interestedIn = Sailfinder::Gender::All;
        if(user["gender_filter"].toInt() == (int)Sailfinder::Gender::Male) { // Both genders
            interestedIn = Sailfinder::Gender::Male;
        }
        else if(user["gender_filter"].toInt() == (int)Sailfinder::Gender::Female) { // Change to male only
            interestedIn = Sailfinder::Gender::Female;
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

            QString companyName;
            QString titleName;
            QString id;
            if(job.value("company") != QJsonValue::Undefined)
            {
                QJsonObject company = job["company"].toObject();
                companyName = company["name"].toString();
                if(company.value("id") != QJsonValue::Undefined)
                {
                    id = company["id"].toString();
                }
            }

            if(job.value("title") != QJsonValue::Undefined)
            {
                QJsonObject title = job["title"].toObject();
                titleName = title["name"].toString();
                if(id.length() == 0 && title.value("id") != QJsonValue::Undefined)
                {
                    id = title["id"].toString();
                }
            }
            jobList.append(new Job(id, companyName, titleName));
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
        qDebug() << "\tOptimizer:" << optimizer;

        this->setProfile(new User(id, name, birthDate, gender, bio, schoolList, jobList, photoList, ageMin, ageMax, distanceMax, interestedIn, position, discoverable, optimizer));
    }

    // Unlock profile fetching
    profileFetchLock = false;
}

void API::parseRecommendations(QJsonObject json)
{
    QList<Recommendation *> recsList;
    if(json.value("message") == QJsonValue::Undefined) {
        foreach(QJsonValue item, json["results"].toArray()) {
            QList<Photo *> photoList;
            QList<School *> schoolList;
            QList<Job *> jobList;
            QJsonObject recommendation = item.toObject()["user"].toObject();
            int distance = recommendation["distance_mi"].toInt();
            QString contentHash = recommendation["content_hash"].toString();
            int sNumber = recommendation["s_number"].toInt();
            Sailfinder::Gender gender = Sailfinder::Gender::Female;
            if(recommendation["gender"].toInt() == (int)Sailfinder::Gender::Male) { // Default female, change if needed
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

                QString companyName;
                QString titleName;
                QString id;
                if(job.value("company") != QJsonValue::Undefined)
                {
                    QJsonObject company = job["company"].toObject();
                    companyName = company["name"].toString();
                    if(company.value("id") != QJsonValue::Undefined)
                    {
                        id = company["id"].toString();
                    }
                }

                if(job.value("title") != QJsonValue::Undefined)
                {
                    QJsonObject title = job["title"].toObject();
                    titleName = title["name"].toString();
                    if(id.length() == 0 && title.value("id") != QJsonValue::Undefined)
                    {
                        id = title["id"].toString();
                    }
                }
                jobList.append(new Job(id, companyName, titleName));
            }

            recsList.append(new Recommendation(id, name, birthDate, gender, bio, schoolList, jobList, photoList, contentHash, sNumber, distance));

            qDebug() << "Recommendation data:";
            qDebug() << "\tName:" << name;
            qDebug() << "\tID:" << id;
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

        this->setHasRecommendations(true);
        qDebug() << "Has recommendations:" << this->hasRecommendations();
    }
    else {
        QString msg = json["message"].toString();
        if(msg == "recs timeout") {
            qWarning() << "Recommendations timeout received";
            this->setHasRecommendations(false);
            qDebug() << "Has recommendations:" << this->hasRecommendations();
            emit this->recommendationTimeOut();
        }
        if(msg == "recs exhausted") {
            qWarning() << "Recommendations exhausted received";
            this->setHasRecommendations(false);
            qDebug() << "Has recommendations:" << this->hasRecommendations();
        }
        else {
            qCritical() << "Unknown recommendation message:" << json["message"].toString();
        }
    }

    // Reset the iterator, set the recs list and update the 'recommendation' property
    this->setRecsList(recsList);
    recommendationCounter = 0;
    if(this->hasRecommendations()) {
        this->nextRecommendation();
    }

    // Unlock recommendations fetching
    recommendationsFetchLock = false;
}

void API::parseMatches(QJsonObject json)
{
    QList<Match *> matchesList;
    QJsonObject matchesData = json["data"].toObject();
    foreach(QJsonValue item, matchesData["matches"].toArray()) {
        QList<Photo *> photoList;
        Message* latestMessage = NULL;
        QJsonObject match = item.toObject();
        QJsonObject person = match["person"].toObject();

        // Match related data
        QString matchId = match["_id"].toString();
        bool isDead = match["dead"].toBool();
        bool isSuperlike = match["is_super_like"].toBool();
        
        if(!match["messages"].toArray().empty()) {
            // Matches only return 1 message (last message as preview) if available
            QJsonObject message = match["messages"].toArray().at(0).toObject();
            latestMessage = new Message(
                        message["_id"].toString(),
                    message["match_id"].toString(),
                    message["message"].toString(),
                    QDateTime::fromString(message["sent_date"].toString(), Qt::ISODate),
                    message["from"].toString(),
                    message["to"].toString()
                    );
        }

        // Person with who the user matched with data
        QString name = person["name"].toString();
        QString id = person["_id"].toString();
        QString bio = person["bio"].toString();
        QDateTime birthDate = QDateTime::fromString(person["birth_date"].toString(), Qt::ISODate);
        Sailfinder::Gender gender = Sailfinder::Gender::Female;
        if(person["gender"].toInt() == (int)Sailfinder::Gender::Male) { // Default female, change if needed
            gender = Sailfinder::Gender::Male;
        }

        foreach(QJsonValue item, person["photos"].toArray()) {
            QJsonObject photo = item.toObject();
            photoList.append(new Photo(photo["id"].toString(), photo["url"].toString()));
        }

        matchesList.append(new Match(id, name, birthDate, gender, bio, photoList, matchId, isSuperlike, isDead, latestMessage));
        qDebug() << "Match data:";
        qDebug() << "\tName:" << name;
        qDebug() << "\tGender:" << (int)(gender);
        qDebug() << "\tBirthDate:" << birthDate;
        qDebug() << "\tBio:" << bio;
        qDebug() << "\tPhotos:" << photoList;
        qDebug() << "\tMatch ID:" << matchId;
        qDebug() << "\tSuperlike:" << isSuperlike;
        qDebug() << "\tDead:" << isDead;
        qDebug() << "\tLatest message:" << latestMessage;
    }

    matchesTempList.append(matchesList);

    // Handle pagination if available
    if(matchesData.value("next_page_token") != QJsonValue::Undefined) {
        qDebug() << "Pagination detected in matches, fetching next page...";
        this->getMatches(matchesData["next_page_token"].toString());
    }
    else {
        qDebug() << "Last page fetched, all matches loaded";
        this->setMatchesList(new MatchesListModel(matchesTempList));
        matchesTempList.clear();
    }

    // Unlock matches fetching
    matchFetchLock = false;
}

void API::parseLike(QJsonObject json)
{
    // Handle matching
    if(json["match"].isBool()) {
        qDebug() << "Recommendation was not a pending match";
    }
    else if(json["match"].isObject()) {
        qDebug() << "Recommendation was a pending match";
        // Updating is done using /updates
    }
    else {
        qCritical() << "Unknown JSON response for liking recommendation";
    }

    // Handle out of likes
    bool canLike = json["likes_remaining"].toInt() > 0;
    this->setCanLike(canLike);

    qDebug() << "Recommendation succesfully liked";
    this->nextRecommendation();
}

void API::parsePass(QJsonObject json)
{
    qDebug() << "Recommendation succesfully passed";
    this->nextRecommendation();
}

void API::parseSuperlike(QJsonObject json)
{
    // Handle matching
    if(json.value("limit_exceeded") != QJsonValue::Undefined) {
        if(json["match"].isBool()) {
            qDebug() << "Recommendation was not a pending match";
        }
        else if(json["match"].isObject()) {
            qDebug() << "Recommendation was a pending match";
            emit this->newSuperMatch();
        }
        else {
            qCritical() << "Unknown JSON response for superliking recommendation";
        }
    }
    else {
        qCritical() << "Superliking limit exceeded";
    }

    // Handle out of superlikes
    qDebug() << "SUPERLIKE REMAINING" << json["super_likes"].toObject()["remaining"].toInt();
    bool canSuperlike = json["super_likes"].toObject()["remaining"].toInt() > 0;
    this->setCanSuperlike(canSuperlike);

    qDebug() << "Recommendation succesfully superliked";
    this->nextRecommendation();
}

void API::parseLogout(QJsonObject json)
{
    qDebug() << "Logging out";
    emit this->loggedOut();
}

void API::parseUnmatch(QJsonObject json)
{
    qDebug() << "Unmatching OK, refreshing matches...";
    this->getMatchesAll();
}

void API::parseMessages(QJsonObject json)
{
    QJsonObject messagesData = json["data"].toObject();
    QList<Message*> messagesList;
    foreach(QJsonValue item, messagesData["messages"].toArray()) {
        QJsonObject message = item.toObject();
        Message* msg = new Message(
                    message["_id"].toString(),
                message["match_id"].toString(),
                message["message"].toString(),
                QDateTime::fromString(message["sent_date"].toString(), Qt::ISODate),
                message["from"].toString(),
                message["to"].toString()
                );
        messagesList.append(msg);
    }

    messagesTempList.append(messagesList);

    // Handle pagination if available
    if(messagesData.value("next_page_token") != QJsonValue::Undefined) {
        qDebug() << "Pagination detected in messages, fetching next page...";
        this->getMessages(messagesMatchId, messagesData["next_page_token"].toString());
    }
    else {
        qDebug() << "Last page fetched, all messages loaded";
        // Profile is always loaded before messages but we check it to be sure
        if(this->profile() != NULL) {
            std::reverse(messagesTempList.begin(), messagesTempList.end());
            this->setMessages(new MessageListModel(messagesTempList, this->profile()->id()));
            messagesTempList.clear();
        }
        else {
            qCritical() << "Profile data is NULL, can't determine user id for messages";
            //: Error shown to the user when profile data wasn't succesfull retrieved. It's impossible then to get the messages between the user and it's matches.
            //% "Messages couldn't be retrieved due missing profile information"
            emit this->errorOccurred(qtTrId("sailfinder-messaging-error"));
        }
    }

    // Unlock messages fetching
    messagesFetchLock = false;
}

void API::parseSendMessage(QJsonObject json)
{
    // Get our current messages and reverse them again
    QList<Message *> oldMessages = this->messages()->messageList();

    // Create and add new message
    Message* newMessage = new Message(
                json["_id"].toString(),
            json["match_id"].toString(),
            json["message"].toString(),
            QDateTime::fromString(json["sent_date"].toString(), Qt::ISODate),
            json["from"].toString(),
            json["to"].toString()
            );
    oldMessages.append(newMessage);

    // Update QAbstractListModel it's data
    this->messages()->setMessageList(oldMessages);
    qDebug() << "Added sended message to messagesList";

    // Enforce view updates
    emit this->newMessage(0);
    this->matchesList()->updateMatchLastMessage(json["match_id"].toString(), newMessage);

    // Unlock send messages
    messagesSendLock = false;
}

void API::sendMessage(QJsonDocument payload)
{
    if(this->authenticated() && !messagesSendLock) {
        // Lock message sending
        messagesSendLock = true;

        // Build URL
        QUrl url(QString(MATCH_OPERATIONS_ENDPOINT) + "/" + matchId);
        QUrlQuery parameters;

        // Prepare & do request
        QNetworkReply* reply = QNAM->post(this->prepareRequest(url, parameters), payload.toJson());
        connect(reply, SIGNAL(uploadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
        connect(reply, SIGNAL(downloadProgress(qint64, qint64)), SLOT(timeoutChecker(qint64, qint64)));
    }
    else if(messagesSendLock) {
        qWarning() << "Message sending is locked";
    }
    else {
        qWarning() << "Not authenticated, can't send message data";
    }
}

void API::parseRemovePhoto(QJsonObject json)
{
    this->getProfile(); // Requires a refresh after deletion of a photo
    removePhotoLock = false;
}

void API::parseUploadPhoto(QJsonObject json)
{
    this->getProfile(); // Requires a refresh after uploading of a photo
    uploadPhotoLock = false;
}

void API::parseFullMatchProfile(QJsonObject json)
{
    QList<School *> schoolList;
    QList<Job *> jobList;

    foreach(Match* match, this->matchesList()->matchesList()) {
        QJsonObject result = json["results"].toObject();
        if(match->id() == result["_id"].toString()) {
            qDebug() << "Match ID found, enhancing profile...";

            // Add schools if available
            foreach(QJsonValue item, result["schools"].toArray()) {
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

            // Add jobs if available
            foreach(QJsonValue item, result["jobs"].toArray()) {
                QJsonObject job = item.toObject();

                QString companyName;
                QString titleName;
                QString id;
                if(job.value("company") != QJsonValue::Undefined)
                {
                    QJsonObject company = job["company"].toObject();
                    companyName = company["name"].toString();
                    if(company.value("id") != QJsonValue::Undefined)
                    {
                        id = company["id"].toString();
                    }
                }

                if(job.value("title") != QJsonValue::Undefined)
                {
                    QJsonObject title = job["title"].toObject();
                    titleName = title["name"].toString();
                    if(id.length() == 0 && title.value("id") != QJsonValue::Undefined)
                    {
                        id = title["id"].toString();
                    }
                }
                jobList.append(new Job(id, companyName, titleName));
            }

            // Update match profile
            match->setDistance(result["distance_mi"].toInt());
            match->setSchools(new SchoolListModel(schoolList));
            match->setJobs(new JobListModel(jobList));

            qDebug() << "Match full profile data:";
            qDebug() << "\tDistance:" << match->distance();
            qDebug() << "\tSchools:" << match->schools()->schoolList();
            qDebug() << "\tJobs:" << match->jobs()->jobList();
            emit this->fullMatchProfileFetched(match->distance(), match->schools(), match->jobs());
            break;
        }
    }

    fullMatchProfileLock = false;
}

void API::unlockAll() // In case something goes wrong, avoid deadlock and reset everything
{
    matchFetchLock = false;
    profileFetchLock = false;
    recommendationsFetchLock = false;
    updatesFetchLock = false;
    messagesFetchLock = false;
    messagesSendLock = false;
    removePhotoLock = false;
    fullMatchProfileLock = false;
    qWarning() << "All endpoints unlocked!";
    emit this->unlockedAllEndpoints();
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

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

/**
 * @class API
 * @brief Parse the positioning
 * @details Handler to parse the positioning signals from QGeoPositionInfoSource
 * @param info
 */
void API::positionUpdated(const QGeoPositionInfo &info)
{
    QGeoCoordinate geoCoordinate = info.coordinate();
    positionUpdateCounter++;

    // Enough accuracy, stop updates
    if (info.hasAttribute(QGeoPositionInfo::HorizontalAccuracy) && info.hasAttribute(QGeoPositionInfo::VerticalAccuracy)) {
        if (info.attribute(QGeoPositionInfo::HorizontalAccuracy) < 1000 && info.attribute(QGeoPositionInfo::VerticalAccuracy) < 1000) {
            qDebug() << "Position fix OK";
            // Only perform request when API is ready
            if(this->authenticated()) {
                qDebug() << "Authenticated, updating on API and stopping location services";
                this->getMeta(geoCoordinate.latitude(), geoCoordinate.longitude());
                positionSource->stopUpdates();
            }
        }
    }
    // Position fix takes too long
    else if(positionUpdateCounter > POSITION_MAX_UPDATE && this->authenticated()) {
        qWarning() << "No accurate fix aquired, using the best available location";
        this->getMeta(geoCoordinate.latitude(), geoCoordinate.longitude());
        positionSource->stopUpdates();
    }
    // Wait for next position information
    else {
        qWarning() << "Position fix not accurate enough yet" << positionUpdateCounter << "/" << POSITION_MAX_UPDATE ;
    }
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
            if(reply->url().toString().contains("/v2/auth/login/facebook", Qt::CaseInsensitive)) {
                qDebug() << "Tinder login data received";
                this->parseLogin(jsonObject);
            }
            else if(reply->url().toString().contains("/v2/meta", Qt::CaseInsensitive)) {
                qDebug() << "Tinder meta data received";
                this->parseMeta(jsonObject);
            }
            else if(reply->url().toString().contains("/updates", Qt::CaseInsensitive)) {
                qDebug() << "Tinder updates data received";
                this->parseUpdates(jsonObject);
            }
            else if(reply->url().toString().contains("/v2/profile", Qt::CaseInsensitive)) {
                qDebug() << "Tinder profile data received";
                this->parseProfile(jsonObject);
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
    QJsonObject data = json["data"].toObject();
    this->setToken(data["api_token"].toString());
    this->setIsNewUser(data["is_new_user"].toBool());
    this->setAuthenticated(this->token().length() > 0);
}

void API::parseMeta(QJsonObject json)
{
    QJsonObject data = json["data"].toObject();
    this->setCanEditJobs(data["can_edit_jobs"].toBool());
    this->setCanEditSchools(data["can_edit_schools"].toBool());
    this->setCanAddPhotosFromFacebook(data["can_add_photos_from_facebook"].toBool());
    this->setCanShowCommonConnections(data["can_show_common_connections"].toBool());
}

void API::parseUpdates(QJsonObject json)
{

}

void API::parseProfile(QJsonObject json)
{
 // USER OBJECTS NEEDED
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

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

void API::authenticate(QString fbToken)
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
    qInfo() << "Request finished:" << reply->url();
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
        qDebug() << "Data:" << replyData;

        // Try to parse the data as JSON
        QJsonParseError parseError;
        QJsonDocument jsonData = QJsonDocument::fromJson(replyData.toUtf8(), &parseError);

        // If parsing succesfull, use the data
        if(parseError.error == QJsonParseError::NoError) {
            QJsonObject jsonObject = jsonData.object();

            // Parse data in the right C++ model or database
            if(reply->url().toString().contains("/auth/login/facebook", Qt::CaseInsensitive)) {
                qDebug() << "Tinder authentication data received";
                this->parseAuthentication(jsonObject);
            }
            else {
                qWarning() << "Received unhandeled API endpoint: " << reply->url();
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

void API::parseAuthentication(QJsonObject json)
{
    QJsonObject data = json["data"].toObject();
    this->setToken(data["api_token"].toString());
    this->setIsNewUser(data["is_new_user"].toBool());
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

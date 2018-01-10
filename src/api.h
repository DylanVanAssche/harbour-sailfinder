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

#ifndef API_H
#define API_H

#include <QtGlobal>
#include <QtNetwork/QNetworkAccessManager>
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QtNetwork/QNetworkConfigurationManager>
#include <QtNetwork/QNetworkDiskCache>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QJsonDocument>
#include <QtCore/QVariantMap>

#include "os.h"
#define TINDER_USER_AGENT "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.108 Safari/537.36"
#define AUTH_FACEBOOK_ENDPOINT "https://api.gotinder.com/v2/auth/login/facebook"

class API : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString token READ token NOTIFY tokenChanged)

public:
    explicit API(QObject *parent = 0);
    ~API();
    Q_INVOKABLE void authenticate(QString fbToken);
    QString token() const;
    void setToken(const QString &token);
    bool networkEnabled() const;
    void setNetworkEnabled(bool networkEnabled);
    bool busy() const;
    void setBusy(bool busy);
    bool isNewUser() const;
    void setIsNewUser(bool isNewUser);

signals:
    void busyChanged();
    void tokenChanged();
    void isNewUserChanged();
    void networkEnabledChanged();
    void errorOccurred(const QString &text);
    void authenticationRequested(const QString &text);

public slots:
    void networkAccessible(QNetworkAccessManager::NetworkAccessibility state);
    void sslErrors(QNetworkReply* reply, QList<QSslError> sslError);
    void finished(QNetworkReply *reply);

private:
    QString m_token;
    bool m_isNewUser;
    bool m_busy;
    bool m_networkEnabled;
    QNetworkAccessManager* QNAM;
    QNetworkDiskCache* QNAMCache;
    OS SFOS;
    QNetworkRequest prepareRequest(QUrl url, QUrlQuery parameters);
    void parseAuthentication(QJsonObject json);
};

#endif // API_H

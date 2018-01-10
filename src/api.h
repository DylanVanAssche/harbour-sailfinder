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

#include "os.h"

class API : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool busy READ busy NOTIFY busyChanged)
    Q_PROPERTY(QString token READ token NOTIFY tokenChanged)

public:
    explicit API(QObject *parent = 0);
    ~API();
    Q_INVOKABLE authenticate(QString fbToken);
    QString token() const;
    void setToken(const QString &token);
    bool networkEnabled() const;
    void setNetworkEnabled(bool networkEnabled);
    bool busy() const;
    void setBusy(bool busy);

signals:
    void busyChanged();
    void tokenChanged();
    void errorOccurred(const QString &text);
    void authenticationRequested(const QString &text);

public slots:
    QString m_token;
    bool m_busy;
    bool m_networkEnabled;
    QNetworkAccessManager* QNAM;
    QNetworkDiskCache* QNAMCache;
    OS SFOS;
};

#endif // API_H

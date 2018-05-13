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
#include "os.h"

/* Meta data about the OS
 * This meta data includes:
 *      - release name
 *      - version
 *      - device
 *      - notifications
 *      - XDG_CACHE_HOME
 *      - XDG_CONFIG_HOME
 *      - XDG_DATA_HOME
 */
OS::OS() {
    QList<QPair<QString, QString> > dataList;
    QList<QString> directoryList({logLocation(), cacheLocation(), dataLocation()});

    // Creating default directories
    QDir directory;
    foreach (QString path, directoryList) {
        directory.setPath(path);
        directory.mkpath(path);
    }

    // Get SFOS release info
    QStringList querrySFOSList;
    querrySFOSList << "VERSION_ID" << "PRETTY_NAME";
    dataList = this->extractFileData("/etc/os-release", querrySFOSList);

    // Default unknown
    m_version = "UNKNOWN";
    m_release = "UNKNOWN";
    m_device = "UNKNOWN";

    for(int i=0; i < dataList.count(); i++) {
        if(dataList.at(i).first == "VERSION_ID") {
            m_version = dataList.at(i).second;
        }
        else if(dataList.at(i).first == "PRETTY_NAME") {
            m_release = dataList.at(i).second;
        }
    }

    // Get HW release info
    QStringList querryHWList;
    querryHWList << "NAME";
    dataList = this->extractFileData("/etc/hw-release", querryHWList);
    if(dataList.count() > 0) {
        m_device = dataList.at(0).second;
    }
}

/* Reads a file and search for the querries in the querryList using recursion.
 * The Unicode type is automatically detected by QTextStream.
 * When found, the result is appended as a QPair to a QList.
 */
QList<QPair<QString, QString>> OS::extractFileData(QString location, QStringList querryList) {

    // Init a file object, open it and connect a QTextStream to the file
    QFile file(location);
    QList<QPair<QString, QString>> dataList;

    // Return empty dataList if file couldn't be opened
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text) || !QFile::exists(location)) {
        qCritical() << "Opening file" << location << "failed";
        return dataList;
    }
    QTextStream content(&file);
    content.setAutoDetectUnicode(true);

    // Read the file using recursion and append the requested data to the dataList
    while (true) {
        QString line = content.readLine();

        if(line.isNull()) {
            break;
        }
        else {
            foreach(QString querry, querryList) {
                if(line.indexOf(querry) >= 0) {
                    QString data = line.split('=', QString::SkipEmptyParts).at(1);
                    data.remove('"'); // Clean up
                    dataList.append(qMakePair(querry, data));
                    break;
                }
            }
        }
    }

    // Return dataList and close file
    file.close();
    return dataList;
}

/* Construct a Notification object with default values.
 * Possible feedback values:
 *      - CHAT = "chat"
 *      - CHAT_EXIST = "chat_exists"
 *      - SOCIAL = "social"
 *      - EMAIL = "email"
 *      - SMS = "sms"
 *      - SMS_EXIST = "sms_exists"
 *      - CALL_EXIST = "call_exists"
 *      - CALENDAR = "calendar"
 *      - ACCESSORY_CONNECTED = "accessory_connected"
 *      - CHARGING_STARTED = "charging_started"
 *      - BATTERY_LOW = "battery_low"
 *      - BATTERY_EMPTY = "battery_empty"
 *      - GENERAL_WARNING = "general_warning"
 */

void OS::createNotification(QString title, QString text, QString feedback, QString category) {
    // Trim when too long
    const QString body = text.length() > MAX_BODY_LENGTH ? text.left(MAX_BODY_LENGTH-3) + "..." : text;
    const QString preview = text.length() > MAX_PREVIEW_LENGTH ? text.left(MAX_PREVIEW_LENGTH-3) + "..." : text;

    // Construct argument list for DBus remoteAction
    QVariantList arguments;
    arguments.append(category);

    // Build Notification object
    Notification notification;
    notification.setAppName(this->appNamePretty());
    notification.setAppIcon(this->appName());
    notification.setBody(body);
    notification.setPreviewSummary(title);
    notification.setPreviewBody(preview);
    notification.setCategory(category);
    notification.setRemoteAction(Notification::remoteAction("default", "", this->appName().replace("-","."), "/", this->appName().replace("-","."), "activate", arguments));
    notification.setHintValue("x-nemo-feedback", feedback);
    notification.setHintValue("x-nemo-priority", 120);
    notification.setHintValue("x-nemo-display-on", true);
    notification.publish();
}

/* Construct a Notification object as a Toaster. */
void OS::createToaster(QString text, QString icon, QString category) {
    // Trim when too long
    const QString preview = text.length() > MAX_PREVIEW_LENGTH ? text.left(MAX_PREVIEW_LENGTH-3) + "..." : text;

    // Build Notification object
    // See /usr/share/lipstick/notificationcatergories/x-jolla.settings.clock.conf for an example
    Notification notification;
    notification.setAppIcon(icon);
    notification.setPreviewBody(preview);
    notification.setCategory(category);
    notification.setHintValue("x-nemo-icon", icon);
    notification.setHintValue("transient", true);
    notification.publish();
}

/* Close all notifications by a given replacesId */
void OS::closeNotificationByReplacesId(QString replacesId) {
    qDebug() << "Searching for notification with replacesId: " << replacesId;
    foreach (QObject* object, Notification::notifications()) {
        Notification* n = qobject_cast<Notification*>(object);
        if (n->category() == replacesId) {
            n->close();
            qDebug() << "Closed notification with replacesId: " << n->replacesId();
        }
        n->deleteLater();
    }
}

/* Close all notifications by a given category */
void OS::closeNotificationByCategory(QString category) {
    qDebug() << "Searching for notification with category: " << category;
    foreach (QObject* object, Notification::notifications()) {
        Notification* n = qobject_cast<Notification*>(object);
        if (n->category() == category) {
            n->close();
            qDebug() << "Closed notification with category: " << category;
        }
        n->deleteLater();
    }
}

/* Close all notifications */
void OS::closeNotificationAll() {
    qDebug() << "Closing all open notifications";
    foreach (QObject* object, Notification::notifications()) {
        Notification* n = qobject_cast<Notification*>(object);
        n->close();
        n->deleteLater();
    }
}

/* Return the current SFOS release */
QString OS::release() {
    return m_release;
}

/* Return the current SFOS version ID */
QString OS::version() {
    return m_version;
}

/* Return the current device name */
QString OS::device() {
    return m_device;
}

/* Return the application name */
QString OS::appName() {
    return qApp->applicationName();
}

/* Return the application name prettified */
QString OS::appNamePretty() {
    QString pretty = qApp->applicationName().remove("harbour-");
    pretty = pretty[0].toUpper() + pretty.right(pretty.length()-1);
    return pretty;
}

/* Return the application version */
QString OS::appVersion() {
    return qApp->applicationVersion();
}

/* Return the device pixel ratio */
qreal OS::devicepixelratio() {
    return qApp->devicePixelRatio();
}

/* Return the application cache location
 * In Sailfish OS this dir is returned as /home/nemo/.cache/<APPNAME>/<APPNAME>
 * This duplicate is removed using removeDuplicates() from the QStringList class.
 */
QString OS::cacheLocation() {
    QStringList cache;
    cache = QStandardPaths::standardLocations(QStandardPaths::CacheLocation).at(0).split("/");
    cache.removeDuplicates();
    return cache.join("/");
}

/* Return the application data location
 * In Sailfish OS this dir is returned as /home/nemo/.local/share/<APPNAME>/<APPNAME>
 * This duplicate is removed using removeDuplicates() from the QStringList class.
 */
QString OS::dataLocation() {
    QStringList data;
    data = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation).at(0).split("/");
    data.removeDuplicates();
    return data.join("/");
}

/* Return the application configuration location
 * In Sailfish OS this dir is returned as /home/nemo/.config/<APPNAME>/<APPNAME>
 * This duplicate is removed using removeDuplicates() from the QStringList class.
 */
QString OS::configLocation() {
    QStringList config;
    config = QStandardPaths::standardLocations(QStandardPaths::AppConfigLocation).at(0).split("/");
    config.removeDuplicates();
    return config.join("/");
}

/* Return the default logging path */
QString OS::logLocation() {
    return cacheLocation() + "/logging";
}

/* Return the default logging file name */
QString OS::logFile() {
    return "log.txt";
}

QString OS::photoLocation() {
    QDir directory;
    directory.setPath(QStandardPaths::standardLocations(QStandardPaths::PicturesLocation).at(0) + "/" + appNamePretty());
    directory.mkpath(QStandardPaths::standardLocations(QStandardPaths::PicturesLocation).at(0) + "/" + appNamePretty());
    return directory.path();
}

QString OS::musicLocation() {
    QDir directory;
    directory.setPath(QStandardPaths::standardLocations(QStandardPaths::MusicLocation).at(0) + "/" + appNamePretty());
    directory.mkpath(QStandardPaths::standardLocations(QStandardPaths::MusicLocation).at(0) + "/" + appNamePretty());
    return directory.path();
}

QString OS::documentLocation() {
    QDir directory;
    directory.setPath(QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).at(0) + "/" + appNamePretty());
    directory.mkpath(QStandardPaths::standardLocations(QStandardPaths::DocumentsLocation).at(0) + "/" + appNamePretty());
    return directory.path();
}

QString OS::videoLocation() {
    QDir directory;
    directory.setPath(QStandardPaths::standardLocations(QStandardPaths::MoviesLocation).at(0) + "/" + appNamePretty());
    directory.mkpath(QStandardPaths::standardLocations(QStandardPaths::MoviesLocation).at(0) + "/" + appNamePretty());
    return directory.path();
}

QString OS::downloadLocation() {
    QDir directory;
    directory.setPath(QStandardPaths::standardLocations(QStandardPaths::DownloadLocation).at(0) + "/" + appNamePretty());
    directory.mkpath(QStandardPaths::standardLocations(QStandardPaths::DownloadLocation).at(0) + "/" + appNamePretty());
    return directory.path();
}

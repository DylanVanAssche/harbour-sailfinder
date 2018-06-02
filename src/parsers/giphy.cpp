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

#include "giphy.h"

Giphy::Giphy(QObject *parent) : QObject(parent)
{

}

QList<GIF *> Giphy::parseSearch(QJsonObject json)
{
    QList<GIF *> gifList = QList<GIF *>();
    QJsonArray dataArray = json["data"].toArray();
    foreach(QJsonValue item, dataArray) {
        QJsonObject gif = item.toObject();
        QString id = gif["id"].toString();
        QJsonObject images = gif["images"].toObject();
        QUrl url = images["downsized"].toObject()["url"].toString();
        gifList.append(new GIF(id, url));
    }
    qDebug() << "GIF search";
    qDebug() << "\tGIF's:" << gifList;
    return gifList;
}

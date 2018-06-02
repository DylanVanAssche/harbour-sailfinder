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

#ifndef GIPHY_H
#define GIPHY_H

#include <QDebug>
#include <QtCore/QObject>
#include <QtCore/QJsonObject>
#include <QtCore/QJsonArray>
#include <QtCore/QJsonValue>
#include "../models/gif.h"

#define GIPHY_KEY "fBEDuhnVCiP16"

class Giphy : public QObject
{
    Q_OBJECT

public:
    explicit Giphy(QObject *parent = nullptr);
    static QList<GIF *> parseSearch(QJsonObject json);
};

#endif // GIPHY_H

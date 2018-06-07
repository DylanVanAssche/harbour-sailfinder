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

#ifndef LOGIN_H
#define LOGIN_H

#include <QDebug>
#include <QtCore/QObject>
#include <QtCore/QJsonObject>
#include "../models/authentication.h"

class Login : public QObject
{
    Q_OBJECT
public:
    explicit Login(QObject *parent = nullptr);
    static Authentication* parseTinder(QJsonObject json);
};

#endif // LOGIN_H

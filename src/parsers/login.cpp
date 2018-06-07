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

#include "login.h"

Login::Login(QObject *parent) : QObject(parent)
{

}

Authentication* Login::parseTinder(QJsonObject json)
{
    Authentication *auth = new Authentication();
    QJsonObject login = json["data"].toObject();

    auth->setToken(login["api_token"].toString());
    auth->setIsNewUser(login["is_new_user"].toBool());
    auth->setIsAuthenticated(auth->token().length() > 0);

    qDebug() << "Login data:";
    qDebug() << "\tToken:" << auth->token();
    qDebug() << "\tisNewUser" << auth->isNewUser();
    qDebug() << "\tisAuthenticated" << auth->isAuthenticated();

    return auth;
}

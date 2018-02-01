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

#include "schoollistmodel.h"

SchoolListModel::SchoolListModel(QList<School *> schoolList)
{
    this->setSchoolList(schoolList);
}

SchoolListModel::SchoolListModel()
{

}

SchoolListModel::~SchoolListModel()
{
    if(!this->schoolList().isEmpty()) {
        foreach(School* item, this->schoolList()) {
            item->deleteLater();
        }
    }
}

int SchoolListModel::rowCount(const QModelIndex &) const
{
    return this->schoolList().length();
}

QHash<int, QByteArray> SchoolListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    return roles;
}

QVariant SchoolListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()) {
        return QVariant();
    }
    // Break not needed since return makes the rest unreachable.
    switch(role) {
    case IdRole:
        return QVariant(this->schoolList().at(index.row())->id());
    case NameRole:
        return QVariant(this->schoolList().at(index.row())->name());
    default:
        return QVariant();
    }
}

QList<School *> SchoolListModel::schoolList() const
{
    return m_schoolList;
}

void SchoolListModel::setSchoolList(const QList<School *> &schoolList)
{
    emit this->beginResetModel();
    m_schoolList = schoolList;
    emit this->schoolListChanged();
    emit this->endResetModel();
}

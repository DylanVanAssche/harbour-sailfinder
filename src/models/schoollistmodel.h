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

#ifndef SCHOOLLISTMODEL_H
#define SCHOOLLISTMODEL_H

#include <QtCore/QAbstractListModel>
#include <QtCore/QList>

#include "school.h"

class SchoolListModel : public QAbstractListModel
{
    Q_OBJECT

    public:
        enum Roles {
            IdRole = Qt::UserRole + 1,
            NameRole = Qt::UserRole + 2
        };

        explicit SchoolListModel(QList<School *> schoolList);
        explicit SchoolListModel();
        ~SchoolListModel();

        virtual int rowCount(const QModelIndex&) const;
        virtual QVariant data(const QModelIndex &index, int role) const;

        QList<School *> schoolList() const;
        void setSchoolList(const QList<School *> &schoolList);

protected:
        QHash<int, QByteArray> roleNames() const;

private:
        QList<School *> m_schoolList;
};

#endif // SCHOOLLISTMODEL_H

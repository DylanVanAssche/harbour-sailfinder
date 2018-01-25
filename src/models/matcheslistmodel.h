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

#ifndef MATCHLISTMODEL_H
#define MATCHLISTMODEL_H

#include <QtCore/QAbstractListModel>
#include <QtCore/QList>

#include "match.h"
#include "enum.h"

class MatchesListModel : public QAbstractListModel
{
    Q_OBJECT

    public:
        enum Roles {
            IdRole = Qt::UserRole + 1,
            NameRole = Qt::UserRole + 2,
            BirthDateRole = Qt::UserRole + 3,
            GenderRole = Qt::UserRole + 4,
            BioRole = Qt::UserRole + 5,
            PhotosRole = Qt::UserRole + 6,
            MatchIdRole = Qt::UserRole + 7,
            IsSuperlikeRole = Qt::UserRole + 8,
            IsDeadRole = Qt::UserRole + 9,
            AvatarRole = Qt::UserRole + 10,
            MessagesPreviewRole = Qt::UserRole + 11,
            UnreadCounterRole = Qt::UserRole + 12,
            ReceivedMessageRole = Qt::UserRole + 13,
            ReadMessageRole = Qt::UserRole + 14,
            MentionedRole = Qt::UserRole + 15,
            HasUnreadMessagesRole = Qt::UserRole + 16
        };

        explicit MatchesListModel(QList<Match *> matchesList);
        explicit MatchesListModel();
        ~MatchesListModel();

        virtual int rowCount(const QModelIndex&) const;
        virtual QVariant data(const QModelIndex &index, int role) const;
        QList<Match *> matchesList() const;
        void setMatchesList(const QList<Match *> &matchesList);

protected:
        QHash<int, QByteArray> roleNames() const;

signals:
        void matchesListChanged();

private:
        QList<Match *> m_matchesList = QList<Match *>();
};

#endif // MATCHLISTMODEL_H

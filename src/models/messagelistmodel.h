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

#ifndef MESSAGELISTMODEL_H
#define MESSAGELISTMODEL_H

#include <QtCore/QAbstractListModel>
#include <QtCore/QList>

#include "message.h"
#include "enum.h"

class MessageListModel : public QAbstractListModel
{
    Q_OBJECT

    public:
        enum Roles {
            IdRole = Qt::UserRole + 1,
            MessageRole = Qt::UserRole + 2,
            TimestampRole = Qt::UserRole + 3,
            AuthorRole = Qt::UserRole + 4,
            AuthorIsUserRole = Qt::UserRole + 5,
            ReadMessageRole = Qt::UserRole + 6,
            ReceivedMessageRole = Qt::UserRole + 7
        };

        explicit MessageListModel(QList<Message *> messageList, QString userId);
        explicit MessageListModel();
        ~MessageListModel();

        virtual int rowCount(const QModelIndex&) const;
        virtual QVariant data(const QModelIndex &index, int role) const;
        QList<Message *> messageList() const;
        void setMessageList(const QList<Message *> &messageList);
        QString userId() const;
        void setUserId(const QString &userId);

protected:
        QHash<int, QByteArray> roleNames() const;

signals:
        void messageListChanged();
        void userIdChanged();

private:
        QList<Message *> m_messageList = QList<Message *>();
        QString m_userId = QString();
};

#endif // MESSAGELISTMODEL_H

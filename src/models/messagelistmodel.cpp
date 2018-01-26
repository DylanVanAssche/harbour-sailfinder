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

#include "messagelistmodel.h"

MessageListModel::MessageListModel(QList<Message *> messageList, QString userId)
{
    this->setMessageList(messageList);
    this->setUserId(userId);
}

MessageListModel::MessageListModel()
{
    
}

MessageListModel::~MessageListModel()
{
    if(!this->messageList().isEmpty()) {
        foreach(Message* item, this->messageList()) {
            item->deleteLater();
        }
    }
}

int MessageListModel::rowCount(const QModelIndex &) const
{
    return this->messageList().length();
}

QHash<int, QByteArray> MessageListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[MessageRole] = "message";
    roles[TimestampRole] = "timestamp";
    roles[AuthorRole] = "author";
    roles[AuthorIsUserRole] = "authorIsUser";
    roles[ReadMessageRole] = "readMessage";
    roles[ReceivedMessageRole] = "receivedMessage";
    return roles;
}

QVariant MessageListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()) {
        return QVariant();
    }
    // Break not needed since return makes the rest unreachable.
    switch(role) {
    case IdRole:
        return QVariant(this->messageList().at(index.row())->id());
    case MessageRole:
        return QVariant(this->messageList().at(index.row())->message());
    case TimestampRole:
        return QVariant(this->messageList().at(index.row())->timestamp());
    case AuthorRole:
        return QVariant(QString(""));
    case AuthorIsUserRole:
        return QVariant(this->messageList().at(index.row())->fromPersonId() != this->userId());
    case ReceivedMessageRole:
        return QVariant(false); // Unsupported by Tinder
    case ReadMessageRole:
        return QVariant(false); // Unsupported by Tinder
    default:
        return QVariant();
    }
}

QList<Message *> MessageListModel::messageList() const
{
    return m_messageList;
}

void MessageListModel::setMessageList(const QList<Message *> &messageList)
{
    m_messageList = messageList;
    emit this->messageListChanged();
}

QString MessageListModel::userId() const
{
    return m_userId;
}

void MessageListModel::setUserId(const QString &userId)
{
    m_userId = userId;
    emit this->userIdChanged();
}

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

MessageListModel::MessageListModel(QList<Message *> messageList)
{
    this->setMessageList(messageList);
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
    roles[MatchIdRole] = "matchId";
    roles[MessageRole] = "message";
    roles[TimestampRole] = "timestamp";
    roles[FromPersonIdRole] = "fromPersonId";
    roles[ToPersonIdRole] = "toPersonId";
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
    case MatchIdRole:
        return QVariant(this->messageList().at(index.row())->matchId());
    case MessageRole:
        return QVariant(this->messageList().at(index.row())->message());
    case TimestampRole:
        return QVariant(this->messageList().at(index.row())->timestamp());
    case FromPersonIdRole:
        return QVariant(this->messageList().at(index.row())->fromPersonId());
    case ToPersonIdRole:
        return QVariant(this->messageList().at(index.row())->toPersonId());
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

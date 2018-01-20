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

#include "matcheslistmodel.h"

MatchesListModel::MatchesListModel()
{

}

MatchesListModel::MatchesListModel(QList<Match *> matchesList)
{
    this->setMatchesList(matchesList);
}

MatchesListModel::~MatchesListModel()
{
    if(!this->matchesList().isEmpty()) {
        foreach(Match* item, this->matchesList()) {
            item->deleteLater();
        }
    }
}

int MatchesListModel::rowCount(const QModelIndex &) const
{
    qDebug() << "matchesList length:" << this->matchesList().length();
    return this->matchesList().length();
}

QHash<int, QByteArray> MatchesListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    roles[BirthDateRole] = "birthDate";
    roles[GenderRole] = "gender";
    roles[BioRole] = "bio";
    roles[PhotosRole] = "photos";
    roles[MatchIdRole] = "matchId";
    roles[IsSuperlikeRole] = "isSuperlike";
    roles[IsDeadRole] = "isDead";
    roles[MessagesRole] = "messages";
    return roles;
}

QVariant MatchesListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()) {
        return QVariant();
    }
    // Break not needed since return makes the rest unreachable.
    switch(role) {
    case IdRole:
        return QVariant(this->matchesList().at(index.row())->id());
    case NameRole:
        return QVariant(this->matchesList().at(index.row())->name());
    case BirthDateRole:
        return QVariant(this->matchesList().at(index.row())->birthDate());
    case GenderRole:
        return QVariant(QVariant::fromValue(this->matchesList().at(index.row())->gender()));
    case BioRole:
        return QVariant(this->matchesList().at(index.row())->bio());
    case PhotosRole:
        return QVariant(QVariant::fromValue(this->matchesList().at(index.row())->photos()));
    case MatchIdRole:
        return QVariant(this->matchesList().at(index.row())->matchId());
    case IsSuperlikeRole:
        return QVariant(this->matchesList().at(index.row())->isSuperlike());
    case IsDeadRole:
        return QVariant(this->matchesList().at(index.row())->isDead());
    case MessagesRole:
        return QVariant(QVariant::fromValue(this->matchesList().at(index.row())->messages()));
    default:
        return QVariant();
    }
}

QList<Match *> MatchesListModel::matchesList() const
{
    return m_matchesList;
}

void MatchesListModel::setMatchesList(const QList<Match *> &matchesList)
{
    m_matchesList = matchesList;
    emit this->matchesListChanged();
}

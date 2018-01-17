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

#include "joblistmodel.h"

JobListModel::JobListModel(QList<Job *> jobList)
{
    this->setJobList(jobList);
}

JobListModel::JobListModel()
{

}

JobListModel::~JobListModel()
{
    if(!this->jobList().isEmpty()) {
        foreach(Job* item, this->jobList()) {
            item->deleteLater();
        }
    }
}

int JobListModel::rowCount(const QModelIndex &) const
{
    return this->jobList().length();
}

QHash<int, QByteArray> JobListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[NameRole] = "name";
    return roles;
}

QVariant JobListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()) {
        return QVariant();
    }
    // Break not needed since return makes the rest unreachable.
    switch(role) {
    case IdRole:
        return QVariant(this->jobList().at(index.row())->id());
    case NameRole:
        return QVariant(this->jobList().at(index.row())->name());
    default:
        return QVariant();
    }
}

QList<Job *> JobListModel::jobList() const
{
    return m_jobList;
}

void JobListModel::setJobList(const QList<Job *> &jobList)
{
    m_jobList = jobList;
    emit this->jobListChanged();
}

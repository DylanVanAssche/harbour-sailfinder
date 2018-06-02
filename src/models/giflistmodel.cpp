#include "giflistmodel.h"

GifListModel::GifListModel(QList<GIF *> gifList)
{
    this->setGifList(gifList);
}

GifListModel::GifListModel()
{

}

GifListModel::~GifListModel()
{
    if(!this->gifList().isEmpty()) {
        foreach(GIF* item, this->gifList()) {
            item->deleteLater();
        }
    }
}

int GifListModel::rowCount(const QModelIndex &) const
{
    return this->gifList().length();
}

QVariant GifListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()) {
        return QVariant();
    }
    // Break not needed since return makes the rest unreachable.
    switch(role) {
    case IdRole:
        return QVariant(this->gifList().at(index.row())->id());
    case UrlRole:
        return QVariant(this->gifList().at(index.row())->url());
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> GifListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[UrlRole] = "url";
    return roles;
}

QList<GIF *> GifListModel::gifList() const
{
    return m_gifList;
}

void GifListModel::setGifList(const QList<GIF *> &gifList)
{
    m_gifList = gifList;
    emit this->gifListChanged();
}

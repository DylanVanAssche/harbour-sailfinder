#include "photolistmodel.h"

PhotoListModel::PhotoListModel(QList<Photo *> photoList)
{
    this->setPhotoList(photoList);
}

PhotoListModel::PhotoListModel()
{

}

PhotoListModel::~PhotoListModel()
{
    if(!this->photoList().isEmpty()) {
        foreach(Photo* item, this->photoList()) {
            item->deleteLater();
        }
    }
}

Photo* PhotoListModel::getPhoto(int index)
{
    if(index < this->photoList().length() && index > 0) {
        return this->photoList().at(index);
    }
    return new Photo(QString("NA"), QUrl(""));
}

int PhotoListModel::rowCount(const QModelIndex &) const
{
    return this->photoList().length();
}

QHash<int, QByteArray> PhotoListModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[IdRole] = "id";
    roles[UrlAvatarRole] = "urlAvatar";
    roles[UrlSmallRole] = "urlSmall";
    roles[UrlMediumRole] = "urlMedium";
    roles[UrlLargeRole] = "urlLarge";
    roles[UrlFullRole] = "urlFull";
    return roles;
}

QVariant PhotoListModel::data(const QModelIndex &index, int role) const
{
    if(!index.isValid()) {
        return QVariant();
    }
    // Break not needed since return makes the rest unreachable.
    switch(role) {
    case IdRole:
        return QVariant(this->photoList().at(index.row())->id());
    case UrlAvatarRole:
        return QVariant(this->photoList().at(index.row())->getUrlWithSize(Sailfinder::Size::Avatar));
    case UrlSmallRole:
        return QVariant(this->photoList().at(index.row())->getUrlWithSize(Sailfinder::Size::Small));
    case UrlMediumRole:
        return QVariant(this->photoList().at(index.row())->getUrlWithSize(Sailfinder::Size::Medium));
    case UrlLargeRole:
        return QVariant(this->photoList().at(index.row())->getUrlWithSize(Sailfinder::Size::Large));
    case UrlFullRole:
        return QVariant(this->photoList().at(index.row())->getUrlWithSize(Sailfinder::Size::Full));
    default:
        return QVariant();
    }
}

QList<Photo *> PhotoListModel::photoList() const
{
    return m_photoList;
}

void PhotoListModel::setPhotoList(const QList<Photo *> &photoList)
{
    m_photoList = photoList;
    emit this->photoListChanged();
}

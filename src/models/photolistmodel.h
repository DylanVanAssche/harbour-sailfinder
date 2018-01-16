#ifndef PHOTOLISTMODEL_H
#define PHOTOLISTMODEL_H


#include <QtCore/QAbstractListModel>
#include <QtCore/QList>

#include "photo.h"
#include "enum.h"

class PhotoListModel : public QAbstractListModel
{
    Q_OBJECT

    public:
        enum Roles {
            IdRole = Qt::UserRole + 1,
            NameRole = Qt::UserRole + 2,
            UrlAvatarRole = Qt::UserRole + 3,
            UrlSmallRole = Qt::UserRole + 4,
            UrlMediumRole = Qt::UserRole + 5,
            UrlLargeRole = Qt::UserRole + 6,
            UrlFullRole = Qt::UserRole + 7
        };

        explicit PhotoListModel(QList<Photo *> photoList);
        explicit PhotoListModel();
        ~PhotoListModel();

        virtual int rowCount(const QModelIndex&) const;
        virtual QVariant data(const QModelIndex &index, int role) const;
        QList<Photo *> photoList() const;
        void setPhotoList(const QList<Photo *> &photoList);

protected:
        QHash<int, QByteArray> roleNames() const;

private:
        QList<Photo *> m_photoList;
};

#endif // PHOTOLISTMODEL_H

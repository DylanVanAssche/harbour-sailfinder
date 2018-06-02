#ifndef GIFLISTMODEL_H
#define GIFLISTMODEL_H

#include <QtCore/QAbstractListModel>
#include <QtCore/QList>

#include "gif.h"

class GifListModel : public QAbstractListModel
{
    Q_OBJECT

public:
    enum Roles {
        IdRole = Qt::UserRole + 1,
        UrlRole = Qt::UserRole + 2
    };

    explicit GifListModel(QList<GIF *> gifList);
    explicit GifListModel();
    ~GifListModel();

    virtual int rowCount(const QModelIndex&) const;
    virtual QVariant data(const QModelIndex &index, int role) const;
    QList<GIF *> gifList() const;
    void setGifList(const QList<GIF *> &gifList);

protected:
    QHash<int, QByteArray> roleNames() const;

signals:
    void gifListChanged();

private:
    QList<GIF *> m_gifList = QList<GIF *>();
};

#endif // GIFLISTMODEL_H

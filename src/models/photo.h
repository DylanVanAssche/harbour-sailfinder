#ifndef PHOTO_H
#define PHOTO_H

#include <QtGlobal>
#include <QtDebug>
#include <QtCore/QObject>
#include <QtCore/QString>
#include <QtCore/QUrl>
#include <QtCore/QList>

#include "enum.h"

class Photo : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QUrl url READ url NOTIFY urlChanged)

public:
    explicit Photo(QObject *parent = 0);
    explicit Photo(QString id, QUrl url);
    QString id() const;
    void setId(const QString &id);
    QUrl url() const;
    void setUrl(const QUrl &url);
    Q_INVOKABLE QUrl getUrlWithSize(Sailfinder::Size size);

signals:
    void idChanged();
    void urlChanged();

private:
    QString m_id = QString();
    QUrl m_url = QUrl();
};

#endif // PHOTO_H

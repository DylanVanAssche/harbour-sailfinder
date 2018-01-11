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
public:
    explicit Photo(QObject *parent = 0);
    explicit Photo(QString id, QUrl url, QString filename, QString extension);
    QString id() const;
    void setId(const QString &id);
    QUrl url() const;
    void setUrl(const QUrl &url);
    QString filename() const;
    void setFilename(const QString &filename);
    QString extension() const;
    void setExtension(const QString &extension);
    int width() const;
    void setWidth(int width);
    int height() const;
    void setHeight(int height);
    Q_INVOKABLE QString getUrlWithSize(Sailfinder::Size size);

signals:
    void idChanged();
    void urlChanged();
    void filenameChanged();
    void widthChanged();
    void heightChanged();
    void extensionChanged();

private:
    QString m_id;
    QUrl m_url;
    QString m_filename;
    QString m_extension;
    int m_width;
    int m_height;
};

#endif // PHOTO_H

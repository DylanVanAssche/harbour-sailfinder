#include "photo.h"

Photo::Photo(QObject *parent) : QObject(parent)
{

}

Photo::Photo(QString id, QUrl url, QString filename, QString extension)
{
    this->setId(id);
    this->setUrl(url);
    this->setFilename(filename);
    this->setExtension(extension);
}

QString Photo::id() const
{
    return m_id;
}

void Photo::setId(const QString &id)
{
    m_id = id;
    emit this->idChanged();
}

QUrl Photo::url() const
{
    return m_url;
}

void Photo::setUrl(const QUrl &url)
{
    m_url = url;
    emit this->urlChanged();
}

QString Photo::filename() const
{
    return m_filename;
}

void Photo::setFilename(const QString &filename)
{
    m_filename = filename;
    emit this->filenameChanged();
}

QString Photo::extension() const
{
    return m_extension;
}

void Photo::setExtension(const QString &extension)
{
    m_extension = extension;
    emit this->extensionChanged();
}

int Photo::width() const
{
    return m_width;
}

void Photo::setWidth(int width)
{
    m_width = width;
    emit this->widthChanged();
}

int Photo::height() const
{
    return m_height;
}

void Photo::setHeight(int height)
{
    m_height = height;
    emit this->heightChanged();
}

QString Photo::getUrlWithSize(Sailfinder::Size size)
{
    QString newUrl = this->url().toString();
    switch(size) {
    case Sailfinder::Size::Avatar:
        return newUrl.replace("1080x1080", "84x84");
    case Sailfinder::Size::Small:
        return newUrl.replace("1080x1080", "172x172");
    case Sailfinder::Size::Medium:
        return newUrl.replace("1080x1080", "320x320");
    case Sailfinder::Size::Large:
        return newUrl.replace("1080x1080", "640x640");
    default:
        qWarning() << "Unsupported size for photo";
    case Sailfinder::Size::Full:
        return newUrl;
    }

}

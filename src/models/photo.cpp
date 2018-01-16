#include "photo.h"

Photo::Photo(QObject *parent) : QObject(parent)
{

}

Photo::Photo(QString id, QUrl url)
{
    this->setId(id);
    this->setUrl(url);
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

QUrl Photo::getUrlWithSize(Sailfinder::Size size)
{
    QString newUrl = this->url().toString();
    switch(size) {
    case Sailfinder::Size::Avatar:
        return QUrl(newUrl.replace("1080x1080", "84x84"));
    case Sailfinder::Size::Small:
        return QUrl(newUrl.replace("1080x1080", "172x172"));
    case Sailfinder::Size::Medium:
        return QUrl(newUrl.replace("1080x1080", "320x320"));
    case Sailfinder::Size::Large:
        return QUrl(newUrl.replace("1080x1080", "640x640"));
    default:
        qWarning() << "Unsupported size for photo";
        Q_FALLTHROUGH();
    case Sailfinder::Size::Full:
        return QUrl(newUrl);
    }
}

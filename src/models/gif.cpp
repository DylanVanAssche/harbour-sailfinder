#include "gif.h"

GIF::GIF(QObject *parent) : QObject(parent)
{

}

GIF::GIF(QString id, QUrl url)
{
    this->setId(id);
    this->setUrl(url);
}

QString GIF::id() const
{
    return m_id;
}

void GIF::setId(const QString &id)
{
    m_id = id;
    emit this->idChanged();
}

QUrl GIF::url() const
{
    return m_url;
}

void GIF::setUrl(const QUrl &url)
{
    m_url = url;
    emit this->urlChanged();
}

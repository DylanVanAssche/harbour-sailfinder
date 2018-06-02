#ifndef GIF_H
#define GIF_H

#include <QtCore/QObject>
#include <QtCore/QUrl>

class GIF : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString id READ id WRITE setId NOTIFY idChanged)
    Q_PROPERTY(QUrl url READ url WRITE setUrl NOTIFY urlChanged)

public:
    explicit GIF(QObject *parent = nullptr);
    explicit GIF(QString id, QUrl url);
    QString id() const;
    void setId(const QString &id);
    QUrl url() const;
    void setUrl(const QUrl &url);

signals:
    void idChanged();
    void urlChanged();

private:
    QString m_id = QString();
    QUrl m_url = QUrl();
};

#endif // GIF_H

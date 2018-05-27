#ifndef GIF_H
#define GIF_H

#include <QObject>

class GIF : public QObject
{
    Q_OBJECT
public:
    explicit GIF(QObject *parent = nullptr);

private:
    QString m_id = QString();
    QUrl m_url = QUrl();
};

#endif // GIF_H

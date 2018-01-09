#ifndef API_H
#define API_H

#include <QtCore/QObject>
#include <QtCore/QString>

class API : public QObject
{
    Q_OBJECT
public:
    explicit API(QObject *parent = 0);

signals:
    void busy();

public slots:
    QString m_token;

};

#endif // API_H

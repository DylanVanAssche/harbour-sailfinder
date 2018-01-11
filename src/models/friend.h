#ifndef FRIEND_H
#define FRIEND_H

#include <QtCore/QObject>

class Friend : public QObject
{
    Q_OBJECT
public:
    explicit Friend(QObject *parent = 0);

signals:

public slots:
};

#endif // FRIEND_H
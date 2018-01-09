#ifndef PERSON_H
#define PERSON_H

#include <QtCore/QObject>

class Person : public QObject
{
    Q_OBJECT
public:
    explicit Person(QObject *parent = 0);

signals:

public slots:
};

#endif // PERSON_H
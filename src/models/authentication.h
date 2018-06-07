#ifndef AUTHENTICATION_H
#define AUTHENTICATION_H

#include <QObject>

class Authentication : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QString token READ token NOTIFY tokenChanged)
    Q_PROPERTY(bool isNewUser READ isNewUser NOTIFY isNewUserChanged)
    Q_PROPERTY(bool isAuthenticated READ isAuthenticated NOTIFY isAuthenticatedChanged)

public:
    explicit Authentication(QObject *parent = nullptr);
    QString token() const;
    bool isNewUser() const;
    bool isAuthenticated() const;
    void setToken(const QString &token);
    void setIsNewUser(bool isNewUser);
    void setIsAuthenticated(bool isAuthenticated);

signals:
    void tokenChanged();
    void isNewUserChanged();
    void isAuthenticatedChanged();

private:
    QString m_token = QString();
    bool m_isNewUser = false;
    bool m_isAuthenticated = false;
};

#endif // AUTHENTICATION_H

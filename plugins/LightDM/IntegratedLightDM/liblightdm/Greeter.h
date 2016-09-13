/*
 * Copyright (C) 2013 Canonical, Ltd.
 * Copyright (C) 2010-2011 David Edmundson.
 * Copyright (C) 2010-2011 Robert Ancell
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Author: David Edmundson <kde@davidedmundson.co.uk>
 */

#ifndef UNITY_MOCK_GREETER_H
#define UNITY_MOCK_GREETER_H

#include <QtCore/QObject>
#include <QtCore/QVariant>

/* !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 * CHANGES MADE HERE MUST BE REFLECTED ON THE MOCK LIB
 * COUNTERPART IN tests/mocks/Lightdm/liblightdm
 * !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! */

namespace QLightDM
{
    class GreeterPrivate;

class Q_DECL_EXPORT Greeter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool authenticated READ isAuthenticated ) //NOTFIY authenticationComplete
    Q_PROPERTY(QString authenticationUser READ authenticationUser )
    Q_PROPERTY(QString defaultSession READ defaultSessionHint CONSTANT)
    Q_PROPERTY(QString selectUser READ selectUserHint CONSTANT)
    Q_PROPERTY(bool selectGuest READ selectGuestHint CONSTANT)

    Q_PROPERTY(QString hostname READ hostname CONSTANT)
    Q_PROPERTY(bool hasGuestAccount READ hasGuestAccountHint CONSTANT)

    Q_ENUMS(PromptType MessageType)

public:
    enum PromptType {
        PromptTypeQuestion,
        PromptTypeSecret
    };

    enum MessageType {
        MessageTypeInfo,
        MessageTypeError
    };

    explicit Greeter(QObject* parent=0);
    virtual ~Greeter();

    QString getHint(const QString &name) const;
    QString defaultSessionHint() const;
    bool hideUsersHint() const;
    bool showManualLoginHint() const;
    bool showRemoteLoginHint() const;
    bool hasGuestAccountHint() const;
    QString selectUserHint() const;
    bool selectGuestHint() const;
    QString autologinUserHint() const;
    bool autologinGuestHint() const;
    int autologinTimeoutHint() const;

    bool inAuthentication() const;
    bool isAuthenticated() const;
    QString authenticationUser() const;
    QString hostname() const;

public Q_SLOTS:
    bool connectSync();
    void authenticate(const QString &username=QString());
    void authenticateAsGuest();
    void authenticateAutologin();
    void authenticateRemote(const QString &session=QString(), const QString &username=QString());
    void respond(const QString &response);
    void cancelAuthentication();
    void setLanguage (const QString &language);
    bool startSessionSync(const QString &session=QString());

Q_SIGNALS:
    void showMessage(QString text, QLightDM::Greeter::MessageType type);
    void showPrompt(QString text, QLightDM::Greeter::PromptType type);
    void authenticationComplete();
    void autologinTimerExpired();

protected:
    void sendAuthenticationComplete();

private:
    GreeterPrivate *d_ptr;
    Q_DECLARE_PRIVATE(Greeter)
};
}

#endif // UNITY_MOCK_GREETER_H

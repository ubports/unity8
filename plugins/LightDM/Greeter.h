/*
 * Copyright (C) 2012-2016 Canonical, Ltd.
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
 */

/* This class is a really tiny filter around QLightDM::Greeter.  There are some
   operations that we want to edit a bit for the benefit of Qml.  Specifically,
   we want to chop colons off of any password prompts.  But there may be more
   such edits in the future, and by inserting ourselves here, we have more
   control. */

#pragma once

#include <QLightDM/Greeter>
#include <QtCore/QObject>

class GreeterPrivate;
class PromptsModel;

class Greeter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool active READ isActive WRITE setIsActive NOTIFY isActiveChanged)
    Q_PROPERTY(bool authenticated READ isAuthenticated NOTIFY isAuthenticatedChanged)
    Q_PROPERTY(QString authenticationUser READ authenticationUser NOTIFY authenticationUserChanged)
    Q_PROPERTY(QString defaultSession READ defaultSessionHint CONSTANT)
    Q_PROPERTY(QString selectUser READ selectUser CONSTANT)

public:
    static Greeter *instance();
    virtual ~Greeter();

    bool isActive() const;
    bool isAuthenticated() const;
    QString authenticationUser() const;
    QString defaultSessionHint() const;
    QString selectUser() const;
    bool hasGuestAccount() const;
    bool showManualLoginHint() const;
    bool hideUsersHint() const;

    PromptsModel *promptsModel();

public Q_SLOTS:
    void authenticate(const QString &username=QString());
    void respond(const QString &response);
    bool startSessionSync(const QString &session=QString());
    void setIsActive(bool isActive);

Q_SIGNALS:
    void authenticationUserChanged();
    void isActiveChanged();
    void isAuthenticatedChanged();
    void showGreeter();
    void hideGreeter();
    void loginError(bool automatic);
    void loginSuccess(bool automatic);
    void authenticationStarted(); // useful for testing

    // This signal is emitted by external agents like indicators, and the UI
    // should switch to this user if possible.
    void requestAuthenticationUser(const QString &user);

protected:
    explicit Greeter(QObject* parent=0);

    GreeterPrivate * const d_ptr;

    Q_DECLARE_PRIVATE(Greeter)

private Q_SLOTS:
    void showMessageFilter(const QString &text, QLightDM::Greeter::MessageType type);
    void showPromptFilter(const QString &text, QLightDM::Greeter::PromptType type);
    void authenticationCompleteFilter();
    void checkAuthenticationUser();
};

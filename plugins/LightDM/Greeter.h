/*
 * Copyright (C) 2012,2013,2015 Canonical, Ltd.
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

#ifndef UNITY_GREETER_H
#define UNITY_GREETER_H

#include <QLightDM/Greeter>
#include <QtCore/QObject>

class GreeterPrivate;

class Greeter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool active READ isActive WRITE setIsActive NOTIFY isActiveChanged)
    Q_PROPERTY(bool authenticated READ isAuthenticated NOTIFY isAuthenticatedChanged)
    Q_PROPERTY(QString authenticationUser READ authenticationUser NOTIFY authenticationUserChanged)
    Q_PROPERTY(QString defaultSession READ defaultSessionHint CONSTANT)
    Q_PROPERTY(bool promptless READ promptless NOTIFY promptlessChanged)
    Q_PROPERTY(QString selectUser READ selectUser CONSTANT)

public:
    explicit Greeter(QObject* parent=0);

    bool isActive() const;
    bool isAuthenticated() const;
    QString authenticationUser() const;
    QString defaultSessionHint() const;
    bool promptless() const;
    QString selectUser() const;

public Q_SLOTS:
    void authenticate(const QString &username=QString());
    void respond(const QString &response);
    bool startSessionSync(const QString &session=QString());
    void setIsActive(bool isActive);

Q_SIGNALS:
    void showMessage(const QString &text, bool isError);
    void showPrompt(const QString &text, bool isSecret, bool isDefaultPrompt);
    void authenticationComplete();
    void authenticationUserChanged(const QString &user);
    void isActiveChanged();
    void isAuthenticatedChanged();
    void promptlessChanged();
    void showGreeter();
    void hideGreeter();

    // This signal is emitted by external agents like indicators, and the UI
    // should switch to this user if possible.
    void requestAuthenticationUser(const QString &user);

protected:
    GreeterPrivate * const d_ptr;

    Q_DECLARE_PRIVATE(Greeter)

private Q_SLOTS:
    void showMessageFilter(const QString &text, QLightDM::Greeter::MessageType type);
    void showPromptFilter(const QString &text, QLightDM::Greeter::PromptType type);
    void authenticationCompleteFilter();
};

#endif

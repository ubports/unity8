/*
 * Copyright (C) 2016 Canonical, Ltd.
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
 */

#pragma once

#include <QObject>
#include <QString>


namespace QLightDM
{
class Q_DECL_EXPORT MockController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString selectUserHint READ selectUserHint WRITE setSelectUserHint NOTIFY selectUserHintChanged)
    Q_PROPERTY(bool selectGuestHint READ selectGuestHint WRITE setSelectGuestHint NOTIFY selectGuestHintChanged)
    Q_PROPERTY(bool hasGuestAccountHint READ hasGuestAccountHint WRITE setHasGuestAccountHint NOTIFY hasGuestAccountHintChanged)
    Q_PROPERTY(bool showManualLoginHint READ showManualLoginHint WRITE setShowManualLoginHint NOTIFY showManualLoginHintChanged)
    Q_PROPERTY(bool hideUsersHint READ hideUsersHint WRITE setHideUsersHint NOTIFY hideUsersHintChanged)

    // single, single-pin, single-passphrase, full
    Q_PROPERTY(QString userMode READ userMode WRITE setUserMode NOTIFY userModeChanged)

    // single, none, full
    Q_PROPERTY(QString sessionMode READ sessionMode WRITE setSessionMode NOTIFY sessionModeChanged)

    // This would be best as a Q_INVOKABLE, but using a property allows for
    // keeping the mock cleaner
    Q_PROPERTY(QString sessionName READ sessionName WRITE setSessionName NOTIFY sessionNameChanged)
    Q_PROPERTY(QString currentUsername READ currentUsername WRITE setCurrentUsername NOTIFY currentUsernameChanged)

    Q_PROPERTY(int numAvailableSessions READ numFullSessions CONSTANT)
    Q_PROPERTY(int numSessions READ numSessions WRITE setNumSessions NOTIFY numSessionsChanged)

public:
    static MockController *instance();
    virtual ~MockController();

    Q_INVOKABLE void reset();

    QString selectUserHint() const;
    void setSelectUserHint(const QString &selectUserHint);

    bool selectGuestHint() const;
    void setSelectGuestHint(bool selectGuestHint);

    bool hasGuestAccountHint() const;
    void setHasGuestAccountHint(bool hasGuestAccountHint);

    bool showManualLoginHint() const;
    void setShowManualLoginHint(bool showManualLoginHint);

    bool hideUsersHint() const;
    void setHideUsersHint(bool hideUsersHint);

    QString userMode() const;
    void setUserMode(const QString &userMode);

    QString sessionMode() const;
    void setSessionMode(const QString &sessionMode);

    QString sessionName() const;
    void setSessionName(const QString &userIndex);

    QString currentUsername() const;
    void setCurrentUsername(const QString &username);

    class SessionItem
    {
    public:
        QString key;
        QString name;
    };
    int numFullSessions() const;
    const QList<SessionItem> &fullSessionItems() const;

    int numSessions() const;
    void setNumSessions(int numSessions);

Q_SIGNALS:
    void currentUsernameChanged();
    void selectUserHintChanged();
    void selectGuestHintChanged();
    void hasGuestAccountHintChanged();
    void showManualLoginHintChanged();
    void hideUsersHintChanged();
    void userModeChanged();
    void sessionModeChanged();
    void numSessionsChanged();
    void sessionNameChanged(const QString &sessionName, const QString &username);

private:
    explicit MockController(QObject* parent=0);

    QString m_currentUsername;
    QString m_sessionName;
    QString m_selectUserHint;
    bool m_selectGuestHint;
    bool m_hasGuestAccountHint;
    bool m_showManualLoginHint;
    bool m_hideUsersHint;
    QString m_userMode;
    QString m_sessionMode;
    QList<SessionItem> m_fullSessions;
    int m_numSessions;
};
}

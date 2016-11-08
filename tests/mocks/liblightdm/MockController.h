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

#ifndef UNITY_MOCK_LIBLIGHTDM_CONTROLLER_H
#define UNITY_MOCK_LIBLIGHTDM_CONTROLLER_H

#include <QObject>
#include <QString>


namespace QLightDM
{
class Q_DECL_EXPORT MockController : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString selectUserHint READ selectUserHint WRITE setSelectUserHint NOTIFY selectUserHintChanged)

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

    QString selectUserHint() const;
    void setSelectUserHint(const QString &selectUserHint);

    QString userMode() const;
    void setUserMode(const QString &userMode);

    QString sessionMode() const;
    void setSessionMode(const QString &sessionMode);

    QString sessionName() const;
    void setSessionName(const QString &sessionName);

    QString currentUsername() const;
    void setCurrentUsername(const QString &userIndex);

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
    void userModeChanged();
    void sessionModeChanged();
    void sessionNameChanged(const QString &sessionName, const QString &username);
    void numSessionsChanged();

private:
    explicit MockController(QObject* parent=0);

    QString m_currentUsername;
    QString m_sessionName;
    QString m_selectUserHint;
    QString m_userMode;
    QString m_sessionMode;
    QList<SessionItem> m_fullSessions;
    int m_numSessions;
};
}

#endif

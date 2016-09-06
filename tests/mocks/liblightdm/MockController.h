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
    void selectUserHintChanged();
    void userModeChanged();
    void sessionModeChanged();
    void numSessionsChanged();

private:
    explicit MockController(QObject* parent=0);

    QString m_selectUserHint;
    QString m_userMode;
    QString m_sessionMode;
    QList<SessionItem> m_fullSessions;
    int m_numSessions;
};
}

#endif

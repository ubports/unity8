/*
 * Copyright (C) 2014 Canonical, Ltd.
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
 * Authored by: Nick Dedekind <nick.dedekind@canonical.com
 */

#ifndef MOCKCALLENTRY_H
#define MOCKCALLENTRY_H

#include <QObject>

class MockCallEntry : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockCallEntry)

    Q_PROPERTY(QString phoneNumber READ phoneNumber WRITE setPhoneNumber NOTIFY phoneNumberChanged)
    Q_PROPERTY(bool isConference READ isConference WRITE setIsConference NOTIFY isConferenceChanged)
    Q_PROPERTY(int elapsedTime READ elapsedTime NOTIFY elapsedTimeChanged)

public:
    MockCallEntry(QObject *parent = 0);

    QString phoneNumber() const;
    bool isConference() const;
    int elapsedTime() const;

    void setPhoneNumber(const QString& phoneNumber);
    void setIsConference(bool isConference);

Q_SIGNALS:
    void phoneNumberChanged();
    void isConferenceChanged();
    void elapsedTimeChanged();

protected:
    void timerEvent(QTimerEvent * event);

private:
    QString m_phoneNumber;
    bool m_conference;
    int m_elapsed;
};

#endif // MOCKCALLENTRY_H

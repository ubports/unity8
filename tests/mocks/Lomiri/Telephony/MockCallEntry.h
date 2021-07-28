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
    Q_PROPERTY(int elapsedTime READ elapsedTime WRITE setElapsedTime NOTIFY elapsedTimeChanged)

    // For mock use only
    Q_PROPERTY(bool elapsedTimerRunning READ elapsedTimerRunning WRITE setSlapsedTimerRunning NOTIFY elapsedTimerRunningChanged)

public:
    MockCallEntry(QObject *parent = 0);

    QString phoneNumber() const;
    bool isConference() const;
    int elapsedTime() const;
    bool elapsedTimerRunning() const;

    void setPhoneNumber(const QString& phoneNumber);
    void setIsConference(bool isConference);
    void setElapsedTime(int elapsedTime);
    void setSlapsedTimerRunning(bool elapsedTimerRunning);

Q_SIGNALS:
    void phoneNumberChanged();
    void isConferenceChanged();
    void elapsedTimeChanged();
    void elapsedTimerRunningChanged();

protected:
    void timerEvent(QTimerEvent * event) override;

private:
    QString m_phoneNumber;
    bool m_conference;
    int m_elapsed;
    int m_timer;
};

#endif // MOCKCALLENTRY_H

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

#include "MockCallEntry.h"

MockCallEntry::MockCallEntry(QObject *parent)
    : QObject(parent)
    , m_conference(false)
    , m_elapsed(0)
{
    startTimer(1000);
}

QString MockCallEntry::phoneNumber() const
{
    return m_phoneNumber;
}

void MockCallEntry::setPhoneNumber(const QString& phoneNumber)
{
    if(m_phoneNumber != phoneNumber){
        m_phoneNumber = phoneNumber;
        Q_EMIT phoneNumberChanged();
    }
}

bool MockCallEntry::isConference() const
{
    return m_conference;
}

void MockCallEntry::setIsConference(bool isConference)
{
    if(m_conference != isConference){
        m_conference = isConference;
        Q_EMIT isConferenceChanged();
    }
}

int MockCallEntry::elapsedTime() const
{
    return m_elapsed;
}

void MockCallEntry::timerEvent(QTimerEvent * event)
{
    Q_UNUSED(event);

    m_elapsed++;
    Q_EMIT elapsedTimeChanged();
}


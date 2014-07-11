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

#include "MockContactWatcher.h"
#include "ContactWatcherData.h"

MockContactWatcher::MockContactWatcher(QObject *parent)
    : QObject(parent)
{
    connect(ContactWatcherData::instance(), &ContactWatcherData::contactDataChanged,
            this, &MockContactWatcher::aliasChanged);
}

QString MockContactWatcher::phoneNumber() const
{
    return m_phoneNumber;
}

void MockContactWatcher::setPhoneNumber(const QString& phoneNumber)
{
    if(m_phoneNumber != phoneNumber){
        m_phoneNumber = phoneNumber;
        Q_EMIT phoneNumberChanged();
        Q_EMIT aliasChanged();
    }
}

QString MockContactWatcher::alias() const
{
    QVariantMap data = ContactWatcherData::instance()->contactData().toMap();
    if (data.contains(m_phoneNumber)) {
        return data[m_phoneNumber].toMap()["alias"].toString();
    }
    return "";
}

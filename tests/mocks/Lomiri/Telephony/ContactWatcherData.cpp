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

#include "ContactWatcherData.h"

ContactWatcherData::ContactWatcherData(QObject *parent)
    : QObject(parent)
{
}

ContactWatcherData *ContactWatcherData::instance()
{
    static ContactWatcherData* contactData = new ContactWatcherData();
    return contactData;
}

QVariant ContactWatcherData::contactData() const
{
    return m_data;
}

void ContactWatcherData::setContactData(const QVariant& contactData)
{
    if(m_data != contactData){
        m_data = contactData;
        Q_EMIT contactDataChanged();
    }
}

/*
 * Copyright 2014 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#include "gsettings.h"

// This is a mock implementation to not touch GSettings for real during tests

GSettings::GSettings(QObject *parent):
    QObject(parent)
{

}

QStringList GSettings::storedApplications() const
{
    return m_entries;
}

void GSettings::setStoredApplications(const QStringList &storedApplications)
{
    m_entries = storedApplications;
}

void GSettings::simulateDConfChanged(const QStringList &storedApplications)
{
    m_entries = storedApplications;
    setStoredApplications(storedApplications);
    Q_EMIT changed();
}

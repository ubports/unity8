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

#ifndef GSETTINGS_H
#define GSETTINGS_H

#include <QObject>
#include <QStringList>

// This is a mock implementation to not touch GSettings for real during tests

class GSettings: public QObject
{
    Q_OBJECT
public:
    GSettings(QObject *parent = nullptr);

    QStringList storedApplications() const;
    void setStoredApplications(const QStringList &storedApplications);

    // Only for testing
    void simulateDConfChanged(const QStringList &storedApplications);

Q_SIGNALS:
    void changed();

private:
    QStringList m_entries;
};

#endif

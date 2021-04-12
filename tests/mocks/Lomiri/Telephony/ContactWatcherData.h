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

#ifndef CONTACTWATCHERDATA_H
#define CONTACTWATCHERDATA_H

#include <QObject>
#include <QVariant>

class ContactWatcherData : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(ContactWatcherData)
    Q_PROPERTY(QVariant contactData READ contactData WRITE setContactData NOTIFY contactDataChanged)

public:
    ContactWatcherData(QObject *parent = 0);

    static ContactWatcherData *instance();

    QVariant contactData() const;
    void setContactData(const QVariant& contactData);

Q_SIGNALS:
    void contactDataChanged();

private:
    QVariant m_data;
};

#endif // CONTACTWATCHERDATA_H

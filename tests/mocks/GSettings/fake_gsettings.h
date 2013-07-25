/*
 * Copyright (C) 2013 Canonical, Ltd.
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

#ifndef FAKE_GSETTINGS_H
#define FAKE_GSETTINGS_H

#include <QObject>

class GSettings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QObject schema READ schema NOTIFY schemaChanged)

public:
    explicit GSettings(QObject *parent = 0);

    QObject schema() const;

Q_SIGNALS:
    void schemaChanged(const QObject&);

private:
    QObject m_schema;
};

#endif // FAKE_GSETTINGS_H

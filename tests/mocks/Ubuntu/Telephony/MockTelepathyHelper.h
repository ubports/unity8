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

#ifndef MOCKTELEPATHYHELPER_H
#define MOCKTELEPATHYHELPER_H

#include <QObject>

class MockTelepathyHelper : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(MockTelepathyHelper)
public:
    MockTelepathyHelper(QObject *parent = 0);

    static MockTelepathyHelper *instance();

    Q_INVOKABLE void registerChannelObserver(const QString& name);
};

#endif // MOCKCONTACTWATCHER_H

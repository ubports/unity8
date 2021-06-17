/*
 * Copyright (C) 2021 UBports Foundation.
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
 * Authors: Alberto Mardegan <mardy@users.sourceforge.net>
 */

#ifndef LOMIRI_LOCATIONWATCHER_H
#define LOMIRI_LOCATIONWATCHER_H

#include <QObject>
#include <QScopedPointer>

class ProcessControl;

class LocationWatcherPrivate;
class LocationWatcher: public QObject
{
    Q_OBJECT

public:
    explicit LocationWatcher(ProcessControl *processControl);
    ~LocationWatcher();

private:
    Q_DECLARE_PRIVATE(LocationWatcher)
    QScopedPointer<LocationWatcherPrivate> d_ptr;
};

#endif // LOMIRI_LOCATIONWATCHER_H

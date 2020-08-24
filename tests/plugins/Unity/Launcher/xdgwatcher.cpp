/*
 * Copyright (C) 2019 UBports Foundation.
 * Author(s): Marius Gripsgard <marius@ubports.com>
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

#include "xdgwatcher.h"

XdgWatcher* XdgWatcher::s_xinstance = nullptr;

XdgWatcher::XdgWatcher(QObject* parent)
    : QObject(parent)
{
    s_xinstance = this;
}

XdgWatcher* XdgWatcher::instance()
{
    return s_xinstance;
}

void XdgWatcher::addMockApp(const QString &appId)
{
    Q_EMIT appAdded(appId);
}

void XdgWatcher::removeMockApp(const QString &appId)
{
    Q_EMIT appRemoved(appId);
}

const QString XdgWatcher::stripAppIdVersion(const QString rawAppID) {
    return rawAppID;
}

/*
 * Copyright (C) 2016 Canonical, Ltd.
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

#include "SessionBroadcast.h"

SessionBroadcast::SessionBroadcast(QObject* parent)
  : QObject(parent)
{
}

void SessionBroadcast::requestUrlStart(const QString &, const QString &url)
{
    // No user name guards, we won't worry about that aspect of the plugin here
    Q_EMIT startUrl(url);
}

void SessionBroadcast::requestHomeShown(const QString &)
{
    // No user name guards, we won't worry about that aspect of the plugin here
    Q_EMIT showHome();
}

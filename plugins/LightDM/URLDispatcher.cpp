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

#include "URLDispatcher.h"

#include <QDBusConnection>

class URLDispatcherInterface : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.URLDispatcher")

public:
    explicit URLDispatcherInterface(URLDispatcher *parent);

    Q_SCRIPTABLE void DispatchURL(const QString &url);
};

URLDispatcherInterface::URLDispatcherInterface(URLDispatcher *parent)
  : QObject(parent)
{
}

void URLDispatcherInterface::DispatchURL(const QString &url)
{
    Q_EMIT static_cast<URLDispatcher *>(parent())->dispatchURL(url);
}

URLDispatcher::URLDispatcher(QObject *parent)
  : QObject(parent)
{
    // This class also manages our url-dispatcher interception.  We intercept
    // url-dispatcher because rather than spawning the handler for the URL in
    // our own session, we want to do notify the user session to do it for us
    // (and start an unlock in the process).
    QDBusConnection connection = QDBusConnection::sessionBus();
    URLDispatcherInterface *dispatcher = new URLDispatcherInterface(this);
    connection.registerObject("/com/canonical/URLDispatcher", dispatcher, QDBusConnection::ExportScriptableContents);
    connection.registerService("com.canonical.URLDispatcher");
}

#include "URLDispatcher.moc"

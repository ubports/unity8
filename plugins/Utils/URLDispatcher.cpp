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

#include "URLDispatcher.h"

#include <QDBusConnection>

class URLDispatcherInterface : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "com.canonical.URLDispatcher")

public:
    explicit URLDispatcherInterface(URLDispatcher *parent);

    Q_SCRIPTABLE void DispatchURL(const QString &url, const QString &package);
};

URLDispatcherInterface::URLDispatcherInterface(URLDispatcher *parent)
  : QObject(parent)
{
}

void URLDispatcherInterface::DispatchURL(const QString &url, const QString &package)
{
    Q_UNUSED(package);
    Q_EMIT static_cast<URLDispatcher *>(parent())->urlRequested(url);
}

URLDispatcher::URLDispatcher(QObject *parent)
  : QObject(parent)
  , m_dispatcher(nullptr)
{
}

bool URLDispatcher::active() const
{
    return m_dispatcher != nullptr;
}

void URLDispatcher::setActive(bool value)
{
    if (value == active())
        return;

    QDBusConnection connection = QDBusConnection::sessionBus();

    if (value) {
        URLDispatcherInterface *dispatcher = new URLDispatcherInterface(this);
        connection.registerObject(QStringLiteral("/com/canonical/URLDispatcher"),
                                  dispatcher,
                                  QDBusConnection::ExportScriptableContents);
        connection.registerService(QStringLiteral("com.canonical.URLDispatcher"));
        m_dispatcher = dispatcher;
    } else {
        connection.unregisterService(QStringLiteral("com.canonical.URLDispatcher"));
        delete m_dispatcher;
        m_dispatcher = nullptr;
    }

    Q_EMIT activeChanged();
}

#include "URLDispatcher.moc"

/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the  Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * version 3 along with this program.  If not, see
 * <http://www.gnu.org/licenses/>
 *
 * Authored by: Michael Terry <michael.terry@canonical.com>
 */

#include "LightDMSessionServer.h"

LightDMSessionServer::LightDMSessionServer(LoginSessionServer *logind, QObject *parent)
    : QObject(parent),
      logind(logind)
{
}

void LightDMSessionServer::Lock()
{
    // As a side effect of locking, change Active state of logind.
    // Note that this will say Active is true while the Active property will be
    // false.  This is intentional, as we don't want to keep any state in the
    // mocks.  Having this signal side effect lets us test that lock() was
    // actually called by the plugin as well as test the changed signal itself.
    QVariantMap changes;
    changes.insert("Active", QVariant(true));
    Q_EMIT logind->PropertiesChanged("org.freedesktop.login1.Session", changes, QStringList());
}

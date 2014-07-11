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

#include "plugin.h"
#include "MockCallEntry.h"
#include "MockCallManager.h"
#include "MockContactWatcher.h"
#include "MockTelepathyHelper.h"
#include "ContactWatcherData.h"

#include <QtQml/QQmlContext>
#include <QtQml/QQmlEngine>
#include <qqml.h>

void FakeUbuntuTelephonyQmlPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    Q_ASSERT(engine);

    Q_UNUSED(uri);

    mRootContext = engine->rootContext();
    Q_ASSERT(mRootContext);

    mRootContext->setContextProperty("telepathyHelper", MockTelepathyHelper::instance());
    mRootContext->setContextProperty("callManager", MockCallManager::instance());
    mRootContext->setContextProperty("contactWactherData", ContactWatcherData::instance());
}

void FakeUbuntuTelephonyQmlPlugin::registerTypes(const char *uri)
{
    // @uri Telephony
    qmlRegisterUncreatableType<MockTelepathyHelper>(uri, 0, 1, "TelepathyHelper", "This is a singleton helper class");
    qmlRegisterUncreatableType<MockCallManager>(uri, 0, 1, "CallManager", "This is a singleton manager class");
    qmlRegisterUncreatableType<ContactWatcherData>(uri, 0, 1, "ContactWatcherData", "This is a singleton data class");
    qmlRegisterType<MockCallEntry>(uri, 0, 1, "CallEntry");
    qmlRegisterType<MockContactWatcher>(uri, 0, 1, "ContactWatcher");
}

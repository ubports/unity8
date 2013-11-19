/*
 * Copyright (C) 2012 Canonical, Ltd.
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
 * Author: Michał Sawicz <michal.sawicz@canonical.com>
 */

// Qt
#include <qqml.h>

// self
#include "plugin.h"

// local
#include "preview.h"
#include "previewaction.h"
#include "previewinfohint.h"
#include "socialpreviewcomment.h"
#include "scope.h"
#include "scopes.h"
#include "categories.h"
#include "categoryresults.h"
#include "genericoptionsmodel.h"
#include "result.h"

// libqtdee
#include "deelistmodel.h"

void UnityPlugin::registerTypes(const char *uri)
{
    Q_ASSERT(uri == QLatin1String("Unity"));
    qmlRegisterUncreatableType<Preview>(uri, 0, 1, "Preview", "Can't create Preview object in QML.");
    qmlRegisterUncreatableType<PreviewAction>(uri, 0, 1, "PreviewAction", "Can't create PreviewAction object in QML.");
    qmlRegisterUncreatableType<PreviewInfoHint>(uri, 0, 1, "PreviewInfoHint", "Can't create PreviewInfoHint object in QML.");
    qmlRegisterUncreatableType<SocialPreviewComment>(uri, 0, 1, "SocialPreviewComment", "Can't create SocialPreviewComment object in QML.");
    qmlRegisterUncreatableType<GenericOptionsModel>(uri, 0, 1, "GenericOptionsModel", "Can't create options model in QML.");
    qmlRegisterUncreatableType<Result>(uri, 0, 1, "Result", "Can't create result object in QML.");
    qmlRegisterType<Scope>(uri, 0, 1, "Scope");
    qmlRegisterType<Scopes>(uri, 0, 1, "Scopes");
    qmlRegisterType<Categories>(uri, 0, 1, "Categories");
    qmlRegisterUncreatableType<CategoryResults>(uri, 0, 1, "CategoryResults", "Can't create new Category Results in QML. Get them from Categories instance.");
    qmlRegisterType<DeeListModel>(uri, 0, 1, "DeeListModel");
}

void UnityPlugin::initializeEngine(QQmlEngine *engine, const char *uri)
{
    QQmlExtensionPlugin::initializeEngine(engine, uri);
#ifndef GLIB_VERSION_2_36
    g_type_init();
#endif
}

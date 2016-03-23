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
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

// Self
#include "fake_unity_plugin.h"

// local
#include "fake_scopes.h"
#include "fake_categories.h"
#include "fake_filters.h"
#include "fake_navigation.h"
#include "fake_optionselectoroptions.h"
#include "fake_previewmodel.h"
#include "fake_previewwidgetmodel.h"
#include "fake_resultsmodel.h"
#include "fake_settingsmodel.h"

// External
#include <glib-object.h>

#include <QtQml/qqml.h>

void FakeUnityPlugin::registerTypes(const char *uri)
{
#ifndef GLIB_VERSION_2_36
  g_type_init();
#endif

    Q_ASSERT(uri == QLatin1String("Unity"));

    qmlRegisterType<Scopes>(uri, 0, 2, "Scopes");
    qmlRegisterType<Scope>(uri, 0, 2, "MockScope");
    qmlRegisterUncreatableType<unity::shell::scopes::ScopeInterface>(uri, 0, 2, "Scope", "Can't create Scope object in QML.");
    qmlRegisterUncreatableType<unity::shell::scopes::SettingsModelInterface>(uri, 0, 2, "SettingsModel", "Can't create SettingsModel object in QML.");
    qmlRegisterUncreatableType<unity::shell::scopes::NavigationInterface>(uri, 0, 2, "Navigation", "Can't create Navigation object in QML.");
    qmlRegisterUncreatableType<unity::shell::scopes::CategoriesInterface>(uri, 0, 2, "Categories", "Can't create Categories object in QML.");
    qmlRegisterUncreatableType<unity::shell::scopes::PreviewModelInterface>(uri, 0, 2, "PreviewModel", "Can't create new PreviewModel in QML. Get them from Scope instance.");
    qmlRegisterUncreatableType<ResultsModel>(uri, 0, 2, "ResultsModel", "Can't create ResultsModel object in QML.");
    qmlRegisterType<ResultsModel>(uri, 0, 2, "FakeResultsModel");
    qmlRegisterType<PreviewModel>(uri, 0, 2, "FakePreviewModel");
    qmlRegisterUncreatableType<PreviewWidgetModel>(uri, 0, 2, "PreviewWidgetModel", "Can't create new PreviewWidgetModel in QML. Get them from PreviewModel instance.");
    qmlRegisterUncreatableType<unity::shell::scopes::FiltersInterface>(uri, 0, 2, "Filters", "Can't create Filters object in QML. Get them from Scope instance.");
    qmlRegisterUncreatableType<unity::shell::scopes::FilterBaseInterface>(uri, 0, 2, "Filter", "Can't create Filter object in QML. Get them from Scope instance.");
    qmlRegisterUncreatableType<unity::shell::scopes::OptionSelectorOptionsInterface>(uri, 0, 2, "OptionSelectorOptions", "Can't create Filters object in QML. Get them from OptionSelector instance.");
}

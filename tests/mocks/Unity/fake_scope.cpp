/*
 * Copyright (C) 2013, 2014, 2015 Canonical, Ltd.
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

#include <QDebug>
#include <QUrl>

#include "fake_scope.h"

#include "fake_filters.h"
#include "fake_navigation.h"
#include "fake_optionselectorfilter.h"
#include "fake_resultsmodel.h"
#include "fake_scopes.h"
#include "fake_settingsmodel.h"

#include <paths.h> // from unity8/include

Scope::Scope(Scopes* parent) : Scope("MockScope5", "Mock Scope", false, parent)
{
}

Scope::Scope(QString const& id, QString const& name, bool favorite, Scopes* parent, int categories, bool returnNullPreview, const QStringList primaryNavigationFilterOptionLabels)
    : unity::shell::scopes::ScopeInterface(parent)
    , m_id(id)
    , m_name(name)
    , m_searching(false)
    , m_favorite(favorite)
    , m_isActive(false)
    , m_hasNavigation(true)
    , m_hasPrimaryFilter(true)
    , m_currentNavigationId("root")
    , m_previewRendererName("preview-generic")
    , m_categories(new Categories(categories, this))
    , m_openScope(nullptr)
    , m_settings(new SettingsModel(this))
    , m_filters(new Filters(this))
    , m_returnNullPreview(returnNullPreview)
{
    m_primaryNavigationFilter = new FakeOptionSelectorFilter("OSF3", "PFTag", "Which food you like More", false, primaryNavigationFilterOptionLabels, this);
    m_filters->addFakeFilters();
    connect(m_filters, &Filters::activeFiltersCountChanged, this, &Scope::activeFiltersCountChanged);
}

QString Scope::id() const
{
    return m_id;
}

QString Scope::name() const
{
    return m_name;
}

QString Scope::searchQuery() const
{
    return m_searchQuery;
}

QString Scope::iconHint() const
{
    return m_iconHint;
}

QString Scope::description() const
{
    return m_description;
}

QString Scope::searchHint() const
{
    return QString("Search %1").arg(m_name);
}

QString Scope::shortcut() const
{
    return QString("");
}

bool Scope::searchInProgress() const
{
    return m_searching;
}

bool Scope::activationInProgress() const
{
    return false;
}

bool Scope::favorite() const
{
    return m_favorite;
}

unity::shell::scopes::CategoriesInterface* Scope::categories() const
{
    return m_categories;
}

unity::shell::scopes::SettingsModelInterface* Scope::settings() const
{
    return m_settings;
}

QString Scope::noResultsHint() const
{
    return m_noResultsHint;
}

QString Scope::formFactor() const
{
    return m_formFactor;
}

bool Scope::isActive() const
{
    return m_isActive;
}

void Scope::setSearchQuery(const QString &str)
{
    if (str != m_searchQuery) {
        m_searchQuery = str;
        Q_EMIT searchQueryChanged();
    }
}

void Scope::setFormFactor(const QString &str)
{
    if (str != m_formFactor) {
        m_formFactor = str;
        Q_EMIT formFactorChanged();
    }
}

void Scope::setActive(const bool active)
{
    if (active != m_isActive) {
        m_isActive = active;
        Q_EMIT isActiveChanged();
    }
}

void Scope::setFavorite(const bool favorite)
{
    if (favorite != m_favorite) {
        m_favorite = favorite;
        Q_EMIT favoriteChanged();
    }
}

void Scope::setId(const QString &id)
{
    if (id != m_id) {
        m_id = id;
        Q_EMIT idChanged();
    }
}

void Scope::setName(const QString &name)
{
    if (name != m_name) {
        m_name = name;
        Q_EMIT nameChanged();
    }
}

void Scope::setSearchInProgress(const bool inProg)
{
    if (inProg != m_searching) {
        m_searching = inProg;
        Q_EMIT searchInProgressChanged();
    }
}

void Scope::setNoResultsHint(const QString& str)
{
    if (str != m_noResultsHint) {
        m_noResultsHint = str;
        Q_EMIT noResultsHintChanged();
    }
}

void Scope::activate(QVariant const& result, QString const& categoryId)
{
    qDebug() << "Called activate on scope" << m_id << "with result" << result << "and category" << categoryId;
    if (result.toString() == "Result.2.2") {
        Scopes *scopes = dynamic_cast<Scopes*>(parent());
        m_openScope = scopes->getScopeFromAll("MockScope9");
        scopes->addTempScope(m_openScope);
        Q_EMIT openScope(m_openScope);
    } else {
        Q_EMIT previewRequested(result);
    }
}

PreviewModel* Scope::preview(QVariant const& result, QString const& /*categoryId*/)
{
    Q_UNUSED(result);

    if (m_returnNullPreview) {
        return nullptr;
    } else {
        return new PreviewModel(this, this);
    }
}

void Scope::cancelActivation()
{
}

void Scope::closeScope(unity::shell::scopes::ScopeInterface* scope)
{
    Scopes *scopes = dynamic_cast<Scopes*>(parent());
    if (scopes) {
        return scopes->closeScope(scope);
    }
}

QString Scope::currentNavigationId() const
{
    return m_currentNavigationId;
}

bool Scope::hasNavigation() const
{
    return m_hasNavigation;
}

void Scope::setHasNavigation(bool hasNavigation)
{
    m_hasNavigation = hasNavigation;
    Q_EMIT hasNavigationChanged();
}

Scope::Status Scope::status() const
{
    return Status::Okay;
}

QVariantMap Scope::customizations() const
{
    QVariantMap m, h;
    if (m_id == "clickscope") {
        h["foreground-color"] = "yellow";
        m["background-color"] = "red";
        m["foreground-color"] = "blue";
        m["page-header"] = h;
    } else if (m_id == "MockScope4") {
        h["navigation-background"] = QUrl(sourceDirectory() + "/tests/qmltests/Dash/artwork/background.png");
        m["page-header"] = h;
    } else if (m_id == "MockScope5") {
        h["background"] = "gradient:///lightgrey/grey";
        h["logo"] = QUrl(sourceDirectory() + "/tests/qmltests/Dash/tst_PageHeader/logo-ubuntu-orange.svg");
        h["divider-color"] = "red";
        h["navigation-background"] = "color:///black";
        m["page-header"] = h;
    } else if (m_id == "MockScope6") {
        h["navigation-background"] = "gradient:///blue/red";
        m["page-header"] = h;
    }
    return m;
}

void Scope::refresh()
{
    Q_EMIT refreshed();
}

void Scope::resetFilters()
{
    qWarning() << "Scope::resetFilters is unimplemented";
}

void Scope::activateAction(QVariant const& /*result*/, QString const& /*categoryId*/, QString const& /*actionId*/)
{
    qFatal("Using Scope::activateAction");
}

unity::shell::scopes::NavigationInterface* Scope::getNavigation(const QString& id)
{
    if (id.isEmpty())
        return nullptr;

    QString parentId;
    QString parentLabel;
    if (id.startsWith("middle")) {
        parentId = "root";
        parentLabel = "root";
    } else if (id.startsWith("child")) {
        parentId = id.mid(5, 7);
        parentLabel = parentId;
    }
    return new Navigation(id, id, "all"+id, parentId, parentLabel, this);
}

void Scope::setNavigationState(const QString &navigationId)
{
    m_currentNavigationId = navigationId;
    Q_EMIT currentNavigationIdChanged();
    Q_EMIT primaryNavigationTagChanged();
}

unity::shell::scopes::FilterBaseInterface* Scope::primaryNavigationFilter() const
{
    return m_hasPrimaryFilter ? m_primaryNavigationFilter : nullptr;
}

unity::shell::scopes::FiltersInterface* Scope::filters() const
{
    return m_filters;
}

QString Scope::primaryNavigationTag() const
{
    if (m_currentNavigationId == "root")
        return QString();
    else
        return const_cast<Scope*>(this)->getNavigation(m_currentNavigationId)->label();
}

int Scope::activeFiltersCount() const
{
    return m_filters->activeFiltersCount();
}

void Scope::resetPrimaryNavigationTag()
{
    if (m_currentNavigationId != "root") {
        setNavigationState("root");
    }
}

void Scope::setHasPrimaryFilter(bool hasPrimaryFilter)
{
    m_hasPrimaryFilter = hasPrimaryFilter;
    Q_EMIT primaryNavigationFilterChanged();
}

void Scope::performQuery(const QString& query)
{
    Q_EMIT queryPerformed(query);
    if (query.startsWith("scopes://")) {
        QString scopeId = query.mid(9);
        Q_EMIT gotoScope(scopeId);
    }
}

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
 */

#include "fake_scopesoverview.h"

#include "fake_scopes.h"

#include <paths.h>

ScopesOverview::ScopesOverview(Scopes* parent)
 : Scope("scopesOverview", "Scopes Overview", false, parent)
{
    delete m_categories; // delete the usual categories, we're not going to use it
    m_scopesOverviewCategories = new ScopesOverviewCategories(parent, this);
    m_searchCategories = new ScopesOverviewSearchCategories(parent, this);
    m_categories = m_scopesOverviewCategories;
}

void ScopesOverview::setSearchQuery(const QString& search_query)
{
    Scope::setSearchQuery(search_query);

    auto origCategories = m_categories;
    if (search_query.isEmpty()) m_categories = m_scopesOverviewCategories;
    else m_categories = m_searchCategories;

    if (m_categories != origCategories)
        Q_EMIT categoriesChanged();
}

Q_INVOKABLE void ScopesOverview::activate(QVariant const& result, QString const& /*categoryId*/)
{
    Scopes *scopes = dynamic_cast<Scopes*>(parent());
    if (scopes->getScope(result.toString())) {
        Q_EMIT gotoScope(result.toString());
    } else {
        m_openScope = scopes->getScopeFromAll(result.toString());
        scopes->addTempScope(m_openScope);
        Q_EMIT openScope(m_openScope);
    }
}

void ScopesOverview::setFavorite(Scope *scope, bool favorite)
{
    m_scopesOverviewCategories->setFavorite(scope, favorite);
}

void ScopesOverview::moveFavoriteTo(Scope *scope, int index)
{
    m_scopesOverviewCategories->moveFavoriteTo(scope, index);
}

ScopesOverviewCategories::ScopesOverviewCategories(Scopes *scopes, QObject* parent)
    : unity::shell::scopes::CategoriesInterface(parent)
    , m_scopes(scopes)
{
}

int ScopesOverviewCategories::rowCount(const QModelIndex& /*parent*/) const
{
    return 2;
}

bool ScopesOverviewCategories::overrideCategoryJson(QString const& /* categoryId */, QString const& /* json */)
{
    qFatal("Using un-implemented ScopesOverviewCategories::overrideCategoryJson");
}

void ScopesOverviewCategories::setFavorite(Scope *scope, bool favorite)
{
    if (m_resultsModels.value(0)) {
        if (favorite) {
            m_resultsModels[0]->appendScope(scope);
        } else {
            m_resultsModels[0]->removeScope(scope);
        }
    }
    if (m_resultsModels.value(1)) {
        if (favorite) {
            m_resultsModels[1]->removeScope(scope);
        } else {
            m_resultsModels[1]->appendScope(scope);
        }
    }
}

void ScopesOverviewCategories::moveFavoriteTo(Scope *scope, int index)
{
    m_resultsModels[0]->moveScopeTo(scope, index);
}

QVariant ScopesOverviewCategories::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    const QString categoryId = index.row() == 0 ? "favorites" : "other";

    ScopesOverviewResultsModel *resultsModel = m_resultsModels[index.row()];
    if (!resultsModel) {
        QObject *that = const_cast<ScopesOverviewCategories*>(this);
        QList<Scope*> scopes = index.row() == 0 ? m_scopes->favScopes() : m_scopes->nonFavScopes();
        resultsModel = new ScopesOverviewResultsModel(scopes, categoryId, that);
        m_resultsModels[index.row()] = resultsModel;
    }
    switch (role) {
        case RoleCategoryId:
            return categoryId;
        case RoleName:
            return index.row() == 0 ? "Favorites" : "Non Favorites";
        case RoleIcon:
            return QVariant();
        case RoleRawRendererTemplate:
            qFatal("Using un-implemented RoleRawRendererTemplate Categories role");
            return QVariant();
        case RoleRenderer:
        {
            QVariantMap map;
            map["category-layout"] = "grid";
            map["card-size"] = "small";
            map["overlay"] = true;
            return map;
        }
        case RoleComponents:
        {
            QVariantMap map, artMap, attributesMap;
            artMap["aspect-ratio"] = "0.5";
            artMap["field"] = "art";
            map["art"] = artMap;
            map["title"] = "HOLA";
            map["attributes"] = attributesMap;
            return map;
        }
        case RoleResults:
            return QVariant::fromValue(resultsModel);
        case RoleCount:
            return resultsModel->rowCount();
        case RoleHeaderLink:
            return QString();
        default:
            qFatal("Using un-implemented Categories role");
            return QVariant();
    }
}



ScopesOverviewSearchCategories::ScopesOverviewSearchCategories(Scopes *scopes, QObject* parent)
    : unity::shell::scopes::CategoriesInterface(parent)
    , m_scopes(scopes)
{
}

int ScopesOverviewSearchCategories::rowCount(const QModelIndex& /*parent*/) const
{
    return 2;
}

bool ScopesOverviewSearchCategories::overrideCategoryJson(QString const& /* categoryId */, QString const& /* json */)
{
    qFatal("Using un-implemented ScopesOverviewSearchCategories::overrideCategoryJson");
}

QVariant
ScopesOverviewSearchCategories::data(const QModelIndex& index, int role) const
{
    if (!index.isValid()) {
        return QVariant();
    }

    const QString categoryId = index.row() == 0 ? "searchA" : "searchB";

    ScopesOverviewResultsModel *resultsModel = m_resultsModels[index.row()];
    if (!resultsModel) {
        QObject *that = const_cast<ScopesOverviewSearchCategories*>(this);
        QList<Scope *> scopes;
        if (index.row() == 0) {
            scopes << m_scopes->getScopeFromAll("clickscope") << nullptr << m_scopes->getScopeFromAll("MockScope2");
        } else {
            scopes << nullptr << m_scopes->getScopeFromAll("MockScope7") << nullptr << m_scopes->getScopeFromAll("MockScope1");
        }
        resultsModel = new ScopesOverviewResultsModel(scopes, categoryId, that);
        m_resultsModels[index.row()] = resultsModel;
    }
    switch (role) {
        case RoleCategoryId:
            return categoryId;
        case RoleName:
            return index.row() == 0 ? "SearchA" : "SearchB";
        case RoleIcon:
            return QVariant();
        case RoleRawRendererTemplate:
            qFatal("Using un-implemented RoleRawRendererTemplate Categories role");
            return QVariant();
        case RoleRenderer:
        {
            QVariantMap map;
            map["category-layout"] = "grid";
            map["card-size"] = "small";
            map["overlay"] = true;
            return map;
        }
        case RoleComponents:
        {
            QVariantMap map, artMap, attributesMap;
            artMap["aspect-ratio"] = "1";
            artMap["field"] = "art";
            map["art"] = artMap;
            map["title"] = "HOLA";
            map["attributes"] = attributesMap;
            return map;
        }
        case RoleResults:
            return QVariant::fromValue(resultsModel);
        case RoleCount:
            return resultsModel->rowCount();
        case RoleHeaderLink:
            return QString();
        default:
            qFatal("Using un-implemented Categories role");
            return QVariant();
    }
}


ScopesOverviewResultsModel::ScopesOverviewResultsModel(const QList<Scope *> &scopes, const QString &categoryId, QObject* parent)
    : unity::shell::scopes::ResultsModelInterface(parent)
    , m_scopes(scopes)
    , m_categoryId(categoryId)
{
}

QString ScopesOverviewResultsModel::categoryId() const
{
    return m_categoryId;
}

void ScopesOverviewResultsModel::setCategoryId(QString const& /*id*/)
{
    qFatal("Calling un-implemented ScopesOverviewResultsModel::setCategoryId");
}

int ScopesOverviewResultsModel::scopeIndex(QString const& id) const
{
    const int scopeCount = count();
    for (int i = 0; i < scopeCount; ++i) {
        if (m_scopes[i]->id() == id)
            return i;
    }
    return -1;
}

QHash<int, QByteArray> ScopesOverviewResultsModel::roleNames() const
{
    QHash<int, QByteArray> roles = unity::shell::scopes::ResultsModelInterface::roleNames();
    roles[RoleBackground + 1] = "scopeId";
    return roles;
}

int ScopesOverviewResultsModel::rowCount(const QModelIndex& parent) const
{
    Q_UNUSED(parent);

    return m_scopes.count();
}

int ScopesOverviewResultsModel::count() const
{
    return rowCount();
}

QVariant ScopesOverviewResultsModel::data(const QModelIndex& index, int role) const
{
    unity::shell::scopes::ScopeInterface *scope = m_scopes[index.row()];
    switch (role) {
        case RoleUri:
        case RoleCategoryId:
        case RoleDndUri:
            return QString();
        case RoleResult:
            return scope ? scope->id() : QString("Result.%1.%2").arg(categoryId()).arg(index.row());
        case RoleTitle:
            return scope ? scope->name() : QString("Title.%1.%2").arg(categoryId()).arg(index.row());
        case RoleSubtitle:
            return scope && scope->name() == "Videos this is long ab cd ef gh ij kl" ? "tube, movies, cinema, pictures, art, moving images, magic in a box" : QString();
        case RoleArt:
            return QString(qmlDirectory() + "/graphics/applicationIcons/dash.png");
        case RoleMascot:
        case RoleEmblem:
        case RoleSummary:
        case RoleBackground + 1: // scopeId
            return scope ? scope->id() : nullptr;
            break;
        default:
            return QVariant();
    }
}

void ScopesOverviewResultsModel::appendScope(Scope *scope)
{
    Q_ASSERT(!m_scopes.contains(scope));
    const int index = rowCount();
    beginInsertRows(QModelIndex(), index, index);
    m_scopes << scope;
    endInsertRows();
    Q_EMIT countChanged();
}

void ScopesOverviewResultsModel::removeScope(Scope *scope)
{
    const int index = m_scopes.indexOf(scope);
    Q_ASSERT(index != -1);
    beginRemoveRows(QModelIndex(), index, index);
    m_scopes.removeAt(index);
    endRemoveRows();
    Q_EMIT countChanged();
}

void ScopesOverviewResultsModel::moveScopeTo(Scope *scope, int to)
{
    const int from = m_scopes.indexOf(scope);
    Q_ASSERT(from!= -1);
    beginMoveRows(QModelIndex(), from, from, QModelIndex(), to + (to > from ? 1 : 0));
    m_scopes.move(from, to);
    endMoveRows();
}

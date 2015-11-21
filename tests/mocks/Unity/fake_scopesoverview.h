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

#ifndef FAKE_SCOPESOVERVIEW_H
#define FAKE_SCOPESOVERVIEW_H

#include "fake_scope.h"
#include <unity/shell/scopes/ResultsModelInterface.h>

class Scopes;
class ScopesOverviewCategories;
class ScopesOverviewResultsModel;

class ScopesOverview : public Scope
{
    Q_OBJECT

public:
    ScopesOverview(Scopes* parent = 0);

    void setSearchQuery(const QString& search_query) override;
    Q_INVOKABLE void activate(QVariant const& result, QString const& categoryId) override;

    // This is implementation detail
    void setFavorite(Scope *scope, bool favorite);
    void moveFavoriteTo(Scope *scope, int index);

private:
    ScopesOverviewCategories *m_scopesOverviewCategories;
    unity::shell::scopes::CategoriesInterface *m_searchCategories;
};

class ScopesOverviewCategories : public unity::shell::scopes::CategoriesInterface
{
    Q_OBJECT

public:
    ScopesOverviewCategories(Scopes *scopes, QObject* parent = 0);

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    Q_INVOKABLE bool overrideCategoryJson(QString const& categoryId, QString const& json) override;

    // This is implementation detail
    void setFavorite(Scope *scope, bool favorite);
    void moveFavoriteTo(Scope *scope, int index);

private:
    mutable QHash<int, ScopesOverviewResultsModel*> m_resultsModels;

    Scopes *m_scopes;
};

class ScopesOverviewSearchCategories : public unity::shell::scopes::CategoriesInterface
{
    Q_OBJECT

public:
    ScopesOverviewSearchCategories(Scopes *scopes, QObject* parent = 0);

    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;
    int rowCount(const QModelIndex& parent = QModelIndex()) const override;

    Q_INVOKABLE bool overrideCategoryJson(QString const& categoryId, QString const& json) override;

private:
    mutable QHash<int, ScopesOverviewResultsModel*> m_resultsModels;

    Scopes *m_scopes;
};

class ScopesOverviewResultsModel : public unity::shell::scopes::ResultsModelInterface
{
    Q_OBJECT

public:
    explicit ScopesOverviewResultsModel(const QList<Scope *> &scopes, const QString &categoryId, QObject* parent = 0);

    int rowCount(const QModelIndex& parent = QModelIndex()) const override;
    QVariant data(const QModelIndex& index, int role = Qt::DisplayRole) const override;

    /* getters */
    QString categoryId() const override;
    int count() const override;

    /* setters */
    void setCategoryId(QString const& id) override;

    /* Special API */
    Q_INVOKABLE int scopeIndex(QString const& id) const;
    QHash<int, QByteArray> roleNames() const override;

    // This is implementation detail
    void appendScope(Scope *scope);
    void removeScope(Scope *scope);
    void moveScopeTo(Scope *scope, int index);

private:
    QList<Scope *> m_scopes;
    QString m_categoryId;
};

#endif // FAKE_SCOPESOVERVIEW_H

/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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

#ifndef SCOPE_H
#define SCOPE_H

// Qt
#include <QObject>
#include <QString>
#include <QMetaType>

// libunity-core
#include <UnityCore/Scope.h>
#include <UnityCore/Results.h>

// dee-qt
#include "deelistmodel.h"

class Categories;

class Scope : public QObject
{
    Q_OBJECT
    Q_ENUMS(ViewType)

    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString iconHint READ iconHint NOTIFY iconHintChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QString searchHint READ searchHint NOTIFY searchHintChanged)
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
    Q_PROPERTY(QString shortcut READ shortcut NOTIFY shortcutChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(DeeListModel* results READ results NOTIFY resultsChanged)
    Q_PROPERTY(Categories* categories READ categories NOTIFY categoriesChanged)
    Q_PROPERTY(ViewType viewType READ viewType WRITE setViewType NOTIFY viewTypeChanged)

    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(QString noResultsHint READ noResultsHint WRITE setNoResultsHint NOTIFY noResultsHintChanged)

public:
    explicit Scope(QObject *parent = 0);

    enum ViewType {
        Hidden,
        HomeView,
        ScopeView
    };

    /* getters */
    QString id() const;
    QString name() const;
    QString iconHint() const;
    QString description() const;
    QString searchHint() const;
    bool visible() const;
    QString shortcut() const;
    bool connected() const;
    DeeListModel* results() const;
    DeeListModel* globalResults() const;
    Categories* categories() const;
    ViewType viewType() const;
    QString searchQuery() const;
    QString noResultsHint() const;

    /* setters */
    void setViewType(const ViewType& viewType);
    void setSearchQuery(const QString& search_query);
    void setNoResultsHint(const QString& hint);

    Q_INVOKABLE void activate(const QString& uri);
    void setUnityScope(const unity::dash::Scope::Ptr& scope);
    unity::dash::Scope::Ptr unityScope() const;

Q_SIGNALS:
    void idChanged(const std::string&);
    void dbusNameChanged(const std::string&);
    void dbusPathChanged(const std::string&);
    void nameChanged(const std::string&);
    void iconHintChanged(const std::string&);
    void descriptionChanged(const std::string&);
    void searchHintChanged(const std::string&);
    void visibleChanged(bool);
    void shortcutChanged(const std::string&);
    void connectedChanged(bool);
    void resultsChanged();
    void categoriesChanged();
    void viewTypeChanged(ViewType);
    void searchFinished(const std::string&, unity::glib::HintsMap const&, unity::glib::Error const&);
    void searchQueryChanged();
    void noResultsHintChanged();

private Q_SLOTS:
    void synchronizeStates();
    void onSearchFinished(const std::string &, unity::glib::HintsMap const &);

private:
    void onResultsSwarmNameChanged(const std::string&);
    void onResultsChanged(const unity::dash::Results::Ptr&);
    void onResultsModelChanged(unity::glib::Object<DeeModel>);
    void onCategoriesSwarmNameChanged(const std::string&);
    void onCategoriesModelChanged(unity::glib::Object<DeeModel>);
    void onCategoriesChanged(const unity::dash::Categories::Ptr&);
    void onViewTypeChanged(unity::dash::ScopeViewType);

    void onActivated(unity::dash::LocalResult const& result, unity::dash::ScopeHandledType type, unity::glib::HintsMap const&);
    void fallbackActivate(const QString& uri);

    unity::dash::Scope::Ptr m_unityScope;
    DeeListModel* m_results;
    Categories* m_categories;
    QString m_searchQuery;
    QString m_noResultsHint;
};

Q_DECLARE_METATYPE(Scope*)

#endif // SCOPE_H

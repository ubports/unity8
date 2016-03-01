/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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

#ifndef FAKE_SCOPE_H
#define FAKE_SCOPE_H

#include <unity/shell/scopes/ScopeInterface.h>

#include "fake_categories.h"
#include "fake_previewstack.h"

#include <QTimer>

class Scopes;

class Scope : public unity::shell::scopes::ScopeInterface
{
    Q_OBJECT

public:
    Scope(Scopes* parent = 0);
    Scope(QString const& id, QString const& name, bool favorite, Scopes* parent = 0, int categories = 20, bool returnNullPreview = false);

    /* getters */
    QString id() const override;
    QString name() const override;
    QString iconHint() const override;
    QString description() const override;
    QString searchHint() const override;
    QString shortcut() const override;
    bool searchInProgress() const override;
    bool activationInProgress() const override;
    bool favorite() const override;
    unity::shell::scopes::CategoriesInterface* categories() const override;
    QString searchQuery() const override;
    QString noResultsHint() const override;
    QString formFactor() const override;
    bool isActive() const override;
    unity::shell::scopes::SettingsModelInterface* settings() const override;

    /* setters */
    void setSearchQuery(const QString& search_query) override;
    void setNoResultsHint(const QString& hint) override;
    void setFormFactor(const QString& form_factor) override;
    void setActive(const bool) override;
    void setFavorite(const bool) override;
    Q_INVOKABLE void setId(const QString &id); // This is not invokable in the Interface, here for testing benefits
    Q_INVOKABLE void setName(const QString &name); // This is not invokable in the Interface, here for testing benefits
    Q_INVOKABLE void setSearchInProgress(const bool inProg); // This is not invokable in the Interface, here for testing benefits

    Q_INVOKABLE void activate(QVariant const& result, QString const& categoryId) override;
    Q_INVOKABLE PreviewStack* preview(QVariant const& result, QString const& categoryId) override;
    Q_INVOKABLE void cancelActivation() override;
    Q_INVOKABLE void closeScope(unity::shell::scopes::ScopeInterface* scope) override;

    QString currentNavigationId() const  override;
    bool hasNavigation() const  override;
    QString currentAltNavigationId() const  override;
    bool hasAltNavigation() const  override;
    Q_INVOKABLE unity::shell::scopes::NavigationInterface* getNavigation(QString const& navigationId) override;
    Q_INVOKABLE unity::shell::scopes::NavigationInterface* getAltNavigation(QString const& altNavigationId) override;
    Q_INVOKABLE void setNavigationState(const QString &navigationId, bool isAltNavigation) override;
    void performQuery(const QString& query) override;

    Status status() const override;
    QVariantMap customizations() const override;

    Q_INVOKABLE void refresh() override;

    Q_INVOKABLE virtual void activateAction(QVariant const& result, QString const& categoryId, QString const& actionId) override;

Q_SIGNALS:
    // These are not in the Interface, here for testing benefits
    void refreshed();
    void queryPerformed(const QString& query);

protected:

    QString m_id;
    QString m_iconHint;
    QString m_description;
    QString m_name;
    QString m_searchQuery;
    QString m_noResultsHint;
    QString m_formFactor;
    bool m_searching;
    bool m_favorite;
    bool m_isActive;
    QString m_currentNavigationId;
    QString m_currentAltNavigationId;

    QString m_previewRendererName;

    unity::shell::scopes::CategoriesInterface* m_categories;
    unity::shell::scopes::ScopeInterface* m_openScope;
    unity::shell::scopes::SettingsModelInterface* m_settings;

    bool m_returnNullPreview;
};

#endif // FAKE_SCOPE_H

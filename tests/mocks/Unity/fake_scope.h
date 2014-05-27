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

class Department;
class Preview;

class Scope : public unity::shell::scopes::ScopeInterface
{
// TODO
    Q_OBJECT

    Q_PROPERTY(QString currentDepartment READ currentDepartment NOTIFY currentDepartmentChanged)
    Q_PROPERTY(bool hasDepartments READ hasDepartments NOTIFY hasDepartmentsChanged)
// END TODO

public:
    Scope(QObject* parent = 0);
    Scope(QString const& id, QString const& name, bool visible, QObject* parent = 0);

    /* getters */
    QString id() const override;
    QString name() const override;
    QString iconHint() const override;
    QString description() const override;
    QString searchHint() const override;
    bool visible() const override;
    QString shortcut() const override;
    bool searchInProgress() const override;
    unity::shell::scopes::CategoriesInterface* categories() const override;
    QString searchQuery() const override;
    QString noResultsHint() const override;
    QString formFactor() const override;
    bool isActive() const override;

    /* setters */
    void setSearchQuery(const QString& search_query) override;
    void setNoResultsHint(const QString& hint) override;
    void setFormFactor(const QString& form_factor) override;
    void setActive(const bool) override;
    Q_INVOKABLE void setSearchInProgress(const bool inProg); // This is not invokable in the Interface, here for testing benefits

    Q_INVOKABLE void activate(QVariant const& result) override;
    Q_INVOKABLE PreviewStack* preview(QVariant const& result) override;
    Q_INVOKABLE void cancelActivation() override;
    Q_INVOKABLE void closeScope(unity::shell::scopes::ScopeInterface* scope) override;

    // TODO this will go to unity-api eventually
    QString currentDepartment() const;
    bool hasDepartments() const;
    Q_INVOKABLE Department *getDepartment(const QString& id); // returns a Department with lazy-loaded children
    Q_INVOKABLE void loadDepartment(const QString& id); // loads results for the department
    // END TODO

Q_SIGNALS:
    // TODO this will go to unity-api eventually
    void currentDepartmentChanged(const QString&);
    void hasDepartmentsChanged(bool);
    // END TODO

protected:

    QString m_id;
    QString m_iconHint;
    QString m_description;
    QString m_name;
    QString m_searchQuery;
    QString m_noResultsHint;
    QString m_formFactor;
    bool m_visible;
    bool m_searching;
    bool m_isActive;
    QString m_currentDeparment;

    QString m_previewRendererName;

    Categories* m_categories;
};

#endif // FAKE_SCOPE_H

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

#ifndef FAKE_NAVIGATION_H
#define FAKE_NAVIGATION_H

#include <unity/shell/scopes/NavigationInterface.h>

class Scope;

class Navigation : public unity::shell::scopes::NavigationInterface
{
    Q_OBJECT

public:
    Navigation(const QString& navigationId, const QString& label, const QString& allLabel, const QString& parentId, const QString& parentLabel, Scope* scope);

    QString navigationId() const override;
    QString label() const override;
    QString allLabel() const override;
    QString parentNavigationId() const override;
    QString parentLabel() const override;
    bool loaded() const override;
    bool isRoot() const override;
    bool hidden() const override;
    int count() const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;

public Q_SLOTS:
    void slotCurrentNavigationChanged();

private Q_SLOTS:
    void slotLoaded();

private:
    QString m_navigationId;
    QString m_label;
    QString m_allLabel;
    QString m_parentId;
    QString m_parentLabel;
    bool m_loaded;
    QString m_currentNavigation;
    Scope *m_scope;
};

#endif // FAKE_NAVIGATION_H

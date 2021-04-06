/*
 * Copyright (C) 2016 Canonical, Ltd.
 * Copyright (C) 2020 UBports Foundation.
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

#include <lomiri/shell/launcher/AppDrawerModelInterface.h>

#include "MockLauncherItem.h"

class MockAppDrawerModel: public AppDrawerModelInterface
{
    Q_OBJECT
    // TODO: Add this to AppDrawerModelInterface in unity-api.
    // Or, better yet, remove AppDrawerModelInterface from unity-api.
    Q_PROPERTY(bool refreshing READ refreshing NOTIFY refreshingChanged)
public:
    MockAppDrawerModel(QObject* parent = nullptr);

    int rowCount(const QModelIndex &parent) const override;
    QVariant data(const QModelIndex &index, int role) const override;

    bool refreshing();
    Q_INVOKABLE void refresh();

Q_SIGNALS:
    void refreshingChanged();

private:
    QList<MockLauncherItem*> m_list;
    bool m_refresing;
};

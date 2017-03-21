/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Michael Zanetti <michael.zanetti@canonical.com>
 */

#ifndef MOCKQUICKLISTMODEL_H
#define MOCKQUICKLISTMODEL_H

#include <unity/shell/launcher/QuickListModelInterface.h>

using namespace unity::shell::launcher;

class MockQuickListModel: public QuickListModelInterface
{
    Q_OBJECT
    Q_PROPERTY(int count READ rowCount)

public:
    MockQuickListModel(QObject *parent = 0);

    QVariant data(const QModelIndex &index, int role) const override;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
};

#endif // MOCKQUICKLISTMODEL_H

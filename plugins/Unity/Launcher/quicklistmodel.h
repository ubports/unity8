/*
 * Copyright 201, 2015 Canonical Ltd.
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

#ifndef QUICKLISTMODEL_H
#define QUICKLISTMODEL_H

#include "quicklistentry.h"

#include <unity/shell/launcher/QuickListModelInterface.h>

using namespace unity::shell::launcher;

class QuickListModel: public QuickListModelInterface
{
    Q_OBJECT

public:
    explicit QuickListModel(QObject *parent = 0);

    ~QuickListModel();

    void appendAction(const QuickListEntry &entry);
    void insertAction(const QuickListEntry &entry, int index);

    /**
     * @brief Update an existing action
     * @param entry The new, updated entry
     *
     * This will only do something if entry.actionId is found in the model.
     * To add a new entry, use appendAction().
     */
    void updateAction(const QuickListEntry &entry);

    void removeAction(const QuickListEntry &entry);

    QuickListEntry get(int index) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role) const override;

private:
    QList<QuickListEntry> m_list;
};

#endif // QUICKLISTMODEL_H

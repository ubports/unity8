/* Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Michael Zanetti <michael.zanetti@canonical.com>
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

#ifndef QUICKLISTMODEL_H
#define QUICKLISTMODEL_H

#include "common/quicklistentry.h"

#include <unity/shell/launcher/QuickListModelInterface.h>

using namespace unity::shell::launcher;

class QuickListModel: public QuickListModelInterface
{
    Q_OBJECT

public:
    explicit QuickListModel(QObject *parent = 0);

    ~QuickListModel();

    void appendAction(const QuickListEntry &entry);
    QuickListEntry get(int index) const;

    int rowCount(const QModelIndex &parent = QModelIndex()) const;
    QVariant data(const QModelIndex &index, int role) const;

private:
    QList<QuickListEntry> m_list;
};

#endif // QUICKLISTMODEL_H

/*
 * Copyright (C) 2017 Canonical, Ltd.
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

#include <QSortFilterProxyModel>

#include <unity/shell/launcher/QuickListModelInterface.h>

using namespace unity::shell::launcher;

class QuickListProxyModel: public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QAbstractItemModel* source READ source WRITE setSource NOTIFY sourceChanged)
    Q_PROPERTY(bool privateMode READ privateMode WRITE setPrivateMode NOTIFY privateModeChanged)
    Q_PROPERTY(int count READ count NOTIFY countChanged)

public:
    QuickListProxyModel(QObject* parent = nullptr);

    QAbstractItemModel* source() const;
    void setSource(QAbstractItemModel* source);

    bool privateMode() const;
    void setPrivateMode(bool privateMode);

    int count() const;

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;

Q_SIGNALS:
    void sourceChanged();
    void privateModeChanged();
    void countChanged();

private:
    QAbstractItemModel* m_source = nullptr;
    bool m_privateMode = false;
};

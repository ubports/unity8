/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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
 *
 * Authors:
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef VISIBLEINDICATORSMODEL_H
#define VISIBLEINDICATORSMODEL_H

#include <QIdentityProxyModel>

class VisibleIndicatorsModel : public QIdentityProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel* model READ sourceModel WRITE setSourceModel NOTIFY modelChanged)
    Q_PROPERTY(QVariantMap visible READ visible WRITE setVisible NOTIFY visibleChanged)

public:
    explicit VisibleIndicatorsModel(QObject *parent = 0);

    virtual void setSourceModel(QAbstractItemModel *model);
    virtual QHash<int, QByteArray> roleNames() const;
    virtual QVariant data(const QModelIndex &index, int role) const;

    QVariantMap visible() const;
    void setVisible(const QVariantMap& visible);

public Q_SLOTS:
    void onBeginRowInserted(const QModelIndex&, int start, int end);
    void onRowInserted(const QModelIndex&, int start, int end);

Q_SIGNALS:
    void totalCountChanged();
    void modelChanged();
    void visibleChanged();

private:
    QVariantMap m_visible;
    bool m_inserting;
};

#endif // VISIBLEINDICATORSMODEL_H

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
#include <QPersistentModelIndex>

class RootActionState;
class IndicatorsModel;

class VisibleIndicatorsModel : public QIdentityProxyModel
{
    Q_OBJECT

    Q_PROPERTY(IndicatorsModel* model READ model WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)
    Q_PROPERTY(QByteArray profile READ profile WRITE setProfile NOTIFY profileChanged)

public:
    explicit VisibleIndicatorsModel(QObject *parent = 0);
    ~VisibleIndicatorsModel();

    /* getters */
    QHash<int, QByteArray> roleNames() const;
    QByteArray profile() const;
    IndicatorsModel* model() const;

    /* setters */
    void setModel(IndicatorsModel *model);
    void setProfile(const QByteArray& profile);

    virtual QVariant data(const QModelIndex &index, int role) const;

Q_SIGNALS:
    void totalCountChanged();
    void countChanged();
    void modelChanged();
    void profileChanged();

private Q_SLOTS:
    void sourceRowsInserted(const QModelIndex &parent, int start, int end);
    void sourceRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end);
    void sourceDataChanged(const QModelIndex& topRight, const QModelIndex& bottomRight);

    void onActionStateUpdated();

private:
    IndicatorsModel* m_model;
    QList<RootActionState*> m_rootActions;
    QList<bool> m_visible;
    QByteArray m_profile;
};

#endif // VISIBLEINDICATORSMODEL_H

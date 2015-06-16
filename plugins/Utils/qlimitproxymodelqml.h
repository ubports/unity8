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
 */

#ifndef QLIMITPROXYMODELQML_H
#define QLIMITPROXYMODELQML_H

#include <QIdentityProxyModel>

class QLimitProxyModelQML : public QIdentityProxyModel
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel* model READ sourceModel WRITE setModel NOTIFY modelChanged)
    Q_PROPERTY(int limit READ limit WRITE setLimit NOTIFY limitChanged)
    Q_PROPERTY(int count READ rowCount NOTIFY countChanged)

public:
    explicit QLimitProxyModelQML(QObject *parent = 0);

    /* getters */
    int limit() const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    /* setters */
    void setModel(QAbstractItemModel *model);
    void setLimit(int limit);

Q_SIGNALS:
    void limitChanged();
    void totalCountChanged();
    void countChanged();
    void modelChanged();

private Q_SLOTS:
    void sourceRowsAboutToBeInserted(const QModelIndex &parent, int start, int end);
    void sourceRowsAboutToBeRemoved(const QModelIndex &parent, int start, int end);
    void sourceRowsInserted(const QModelIndex &parent, int start, int end);
    void sourceRowsRemoved(const QModelIndex &parent, int start, int end);

private:
    int m_limit;
    bool m_sourceInserting;
    bool m_sourceRemoving;
    int m_dataChangedBegin;
    int m_dataChangedEnd;
};

#endif // QLIMITPROXYMODELQML_H

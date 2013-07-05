/*
 * Copyright 2012 Canonical Ltd.
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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef MODELPRINTER_H
#define MODELPRINTER_H

#include <QSortFilterProxyModel>

// This class acts as a namespace only, with the addition that its enums
// are registered to be exposed on the QML side.
class ModelPrinter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QAbstractItemModel* model READ sourceModel WRITE setSourceModel NOTIFY modelChanged)
public:
    ModelPrinter(QObject* parent=0);

    void setSourceModel(QAbstractItemModel* sourceModel);
    QAbstractItemModel* sourceModel() const;

    Q_INVOKABLE QString getString(const QModelIndex& index = QModelIndex()) const;

Q_SIGNALS:
    void sourceChanged();
    void modelChanged();

private:
  QString recurse_string(const QModelIndex& index, int level) const;
  QAbstractItemModel* m_model;
};

#endif // MODELPRINTER_H


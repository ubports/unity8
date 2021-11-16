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
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef MODELPRINTER_H
#define MODELPRINTER_H

#include <QSortFilterProxyModel>
class AyatanaMenuModel;

// This class acts as a namespace only, with the addition that its enums
// are registered to be exposed on the QML side.
class ModelPrinter : public QObject
{
    Q_OBJECT

    Q_PROPERTY(AyatanaMenuModel* model READ sourceModel WRITE setSourceModel NOTIFY modelChanged)
    Q_PROPERTY(QString text READ text NOTIFY textChanged)
public:
    ModelPrinter(QObject* parent=nullptr);

    void setSourceModel(AyatanaMenuModel* sourceModel);
    AyatanaMenuModel* sourceModel() const;

    Q_INVOKABLE QString text();

Q_SIGNALS:
    void modelChanged();
    void textChanged();

private:
    QString getModelDataString(AyatanaMenuModel* sourceModel, int level);
    QString getRowSring(AyatanaMenuModel* sourceModel, int index, int depth) const;
    QString getVariantString(const QString& roleName, const QVariant &vData, int depth) const;
    QString getVariantString(const QVariant&) const;

    AyatanaMenuModel* m_model;
    QList<AyatanaMenuModel*> m_children;
};

#endif // MODELPRINTER_H

/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the QtGui module of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

/*
 A simple model that uses a QVariantList as its data source.
 */

// LightDM currently is Qt4 compatible, and so doesn't define setRoleNames.
// To use the same method of setting role name that it does, we
// set our compatibility to Qt4 here too.
#define QT_DISABLE_DEPRECATED_BEFORE QT_VERSION_CHECK(4, 0, 0)

#include "qvariantlistmodel.h"

#include <QtCore/qvector.h>

/*!
 \class QVariantListModel
 \brief The QVariantListModel class provides a model that supplies variants to views.

 QVariantListModel is an editable model that can be used for simple
 cases where you need to display a number of variants in a view.

 The model provides all the standard functions of an editable
 model, representing the data in the variant list as a model with
 one column and a number of rows equal to the number of items in
 the list.

 Model indexes corresponding to items are obtained with the
 \l{QAbstractListModel::index()}{index()} function.  Item data is
 read with the data() function and written with setData().
 The number of rows (and number of items in the variant list)
 can be found with the rowCount() function.

 The model can be constructed with an existing variant list, or
 variants can be set later with the setVariantList() convenience
 function. Variants can also be inserted in the usual way with the
 insertRows() function, and removed with removeRows(). The contents
 of the variant list can be retrieved with the variantList()
 convenience function.

 \sa QAbstractListModel, QAbstractItemModel, {Model Classes}
 */

/*!
 Constructs a variant list model with the given \a parent.
 */

QVariantListModel::QVariantListModel(QObject *parent) :
        QAbstractListModel(parent)
{
    QHash<int, QByteArray> roles(roleNames());
    roles[Qt::DisplayRole] = "modelData";
    setRoleNames(roles);
}

/*!
 Constructs a variant list model containing the specified \a list
 with the given \a parent.
 */

QVariantListModel::QVariantListModel(const QVariantList &list, QObject *parent) :
        QAbstractListModel(parent), lst(list)
{
    QHash<int, QByteArray> roles(roleNames());
    roles[Qt::DisplayRole] = "modelData";
    setRoleNames(roles);
}

QVariantListModel::~QVariantListModel() {
}

/*!
 Returns the number of rows in the model. This value corresponds to the
 number of items in the model's internal variant list.

 The optional \a parent argument is in most models used to specify
 the parent of the rows to be counted. Because this is a list if a
 valid parent is specified, the result will always be 0.

 \sa insertRows(), removeRows(), QAbstractItemModel::rowCount()
 */

int QVariantListModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;

    return lst.count();
}

/*!
 \reimp
 */
QModelIndex QVariantListModel::sibling(int row, int column,
        const QModelIndex &idx) const
{
    if (!idx.isValid() || column != 0 || row >= lst.count())
        return QModelIndex();

    return createIndex(row, 0);
}

/*!
 Returns data for the specified \a role, from the item with the
 given \a index.

 If the view requests an invalid index, an invalid variant is returned.

 \sa setData()
 */

QVariant QVariantListModel::data(const QModelIndex &index, int role) const
{
    if (index.row() < 0 || index.row() >= lst.size())
        return QVariant();

    if (role == Qt::DisplayRole || role == Qt::EditRole)
        return lst.at(index.row());

    return QVariant();
}

/*!
 Sets the data for the specified \a role in the item with the given
 \a index in the model, to the provided \a value.

 The dataChanged() signal is emitted if the item is changed.

 \sa Qt::ItemDataRole, data()
 */

bool QVariantListModel::setData(const QModelIndex &index, const QVariant &value,
        int role)
{
    if (index.row() >= 0 && index.row() < lst.size()
            && (role == Qt::EditRole || role == Qt::DisplayRole))
    {
        lst.replace(index.row(), value);
        dataChanged(index, index, QVector<int>() << role);
        return true;
    }
    return false;
}

/*!
 Inserts \a count rows into the model, beginning at the given \a row.

 The \a parent index of the rows is optional and is only used for
 consistency with QAbstractItemModel. By default, a null index is
 specified, indicating that the rows are inserted in the top level of
 the model.

 \sa QAbstractItemModel::insertRows()
 */

bool QVariantListModel::insertRows(int row, int count,
        const QModelIndex &parent)
{
    if (count < 1 || row < 0 || row > rowCount(parent))
        return false;

    beginInsertRows(QModelIndex(), row, row + count - 1);

    for (int r = 0; r < count; ++r)
        lst.insert(row, QVariant());

    endInsertRows();

    return true;
}

/*!
 Removes \a count rows from the model, beginning at the given \a row.

 The \a parent index of the rows is optional and is only used for
 consistency with QAbstractItemModel. By default, a null index is
 specified, indicating that the rows are removed in the top level of
 the model.

 \sa QAbstractItemModel::removeRows()
 */

bool QVariantListModel::removeRows(int row, int count,
        const QModelIndex &parent)
{
    if (count <= 0 || row < 0 || (row + count) > rowCount(parent))
        return false;

    beginRemoveRows(QModelIndex(), row, row + count - 1);

    for (int r = 0; r < count; ++r)
        lst.removeAt(row);

    endRemoveRows();

    return true;
}

/*!
 Returns the variant list used by the model to store data.
 */
QVariantList QVariantListModel::variantList() const
{
    return lst;
}

/*!
 Sets the model's internal variant list to \a list. The model will
 notify any attached views that its underlying data has changed.

 \sa dataChanged()
 */
void QVariantListModel::setVariantList(const QVariantList &list)
{
    int size = lst.size();
    bool sameSize = list.size() == size;
    if (!sameSize)
    {
        beginResetModel();
    }
    lst = list;
    if (!sameSize)
    {
        endResetModel();
    } else
    {
        dataChanged(QAbstractListModel::index(0),
                QAbstractListModel::index(size - 1));
    }
}

/*
 * Copyright (C) 2012 Canonical, Ltd.
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

// self
#include "modelprinter.h"

// Qt
#include <QDebug>

ModelPrinter::ModelPrinter(QObject *parent)
    : QObject(parent)
    , m_model(NULL)
{
}

void ModelPrinter::setSourceModel(QAbstractItemModel * sourceModel)
{
    if (m_model != NULL) {
        disconnect(m_model, SIGNAL(modelReset()), this, SIGNAL(sourceChanged()));
        disconnect(m_model, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SIGNAL(sourceChanged()));
        disconnect(m_model, SIGNAL(rowsRemoved(QModelIndex,int,int)), this, SIGNAL(sourceChanged()));
    }
    if (m_model != sourceModel) {
        m_model = sourceModel;
        Q_EMIT modelChanged();
        Q_EMIT sourceChanged();
    }
    if (m_model != NULL) {
        connect(m_model, SIGNAL(modelReset()), this, SIGNAL(sourceChanged()));
        connect(m_model, SIGNAL(rowsInserted(QModelIndex,int,int)), this, SIGNAL(sourceChanged()));
        connect(m_model, SIGNAL(rowsRemoved(QModelIndex,int,int)), this, SIGNAL(sourceChanged()));
    }
}

QAbstractItemModel* ModelPrinter::sourceModel() const
{
    return m_model;
}

QString ModelPrinter::getString(const QModelIndex& index) const
{
    return recurse_string(index, 0);
}

QString tabify(int level) {    QString str;
    for (int i = 0; i < level; i++) {
        str += "   ";
    }
    return str;
}

QString ModelPrinter::recurse_string(const QModelIndex& index, int level) const
{
    QString str;
    QTextStream stream(&str);

    QHash<int, QByteArray> roleNames = m_model->roleNames();
    QList<int> roles = roleNames.keys();
    qSort(roles);
    Q_FOREACH(int role, roles) {
        QVariant vData = m_model->data(index, role);
        if (vData.canConvert(QMetaType::QVariantMap)) {
            QMapIterator<QString, QVariant> iter(vData.toMap());
            while (iter.hasNext()) {
                iter.next();
                stream << tabify(level) << roleNames[role] << "." << iter.key() << ": " << iter.value().toString() << endl;
            }
        }
        else {
            stream << tabify(level) << roleNames[role] << ": " << vData.toString() << endl;
        }
    }

    int rowCount = m_model->rowCount(index);
    stream << tabify(level) << "child count" << ": " << rowCount << endl;
    for (int i = 0; i < rowCount; i++) {
        QModelIndex child = m_model->index(i, 0, index);
        str += recurse_string(child, level+1);
    }
    return str;
}

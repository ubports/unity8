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

// self
#include "modelprinter.h"

#include <ayatanamenumodel.h>

// Qt
#include <QTextStream>

ModelPrinter::ModelPrinter(QObject *parent)
    : QObject(parent)
    , m_model(nullptr)
{
}

void ModelPrinter::setSourceModel(AyatanaMenuModel * sourceModel)
{
    if (m_model != nullptr) {
        disconnect(m_model);
    }
    if (m_model != sourceModel) {
        m_model = sourceModel;
        Q_EMIT modelChanged();
        Q_EMIT textChanged();
    }
    if (m_model != nullptr) {
        connect(m_model, &AyatanaMenuModel::rowsInserted, this, &ModelPrinter::textChanged);
        connect(m_model, &AyatanaMenuModel::rowsRemoved, this, &ModelPrinter::textChanged);
        connect(m_model, &AyatanaMenuModel::dataChanged, this, &ModelPrinter::textChanged);
    }
}

AyatanaMenuModel* ModelPrinter::sourceModel() const
{
    return m_model;
}

QString ModelPrinter::text()
{
    return getModelDataString(m_model, 0);
}

QString tabify(int level) {    QString str;
    for (int i = 0; i < level; i++) {
        str += QLatin1String("      ");
    }
    return str;
}

QString ModelPrinter::getModelDataString(AyatanaMenuModel* sourceModel, int level)
{
    if (!sourceModel)
        return QLatin1String("");

    QString str;
    QTextStream stream(&str);

    int rowCount = sourceModel->rowCount();
    for (int row = 0; row < rowCount; row++) {

#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0)
        stream << getRowSring(sourceModel, row, level) << Qt::endl;
#else
        stream << getRowSring(sourceModel, row, level) << endl;
#endif

        AyatanaMenuModel* childMenuModel = qobject_cast<AyatanaMenuModel*>(sourceModel->submenu(row));
        if (childMenuModel) {

            if (!m_children.contains(childMenuModel)) {
                m_children << childMenuModel;
                connect(childMenuModel, &AyatanaMenuModel::rowsInserted, this, &ModelPrinter::textChanged);
                connect(childMenuModel, &AyatanaMenuModel::rowsRemoved, this, &ModelPrinter::textChanged);
                connect(childMenuModel, &AyatanaMenuModel::dataChanged, this, &ModelPrinter::textChanged);
            }
            stream << getModelDataString(childMenuModel, level+1);
        }
    }
    return str;
}

QString ModelPrinter::getRowSring(AyatanaMenuModel* sourceModel, int row, int depth) const
{
    QString str;
    QTextStream stream(&str);

    // Print out this row
    QHash<int, QByteArray> roleNames = sourceModel->roleNames();
    QList<int> roles = roleNames.keys();
    qSort(roles);

    Q_FOREACH(int role, roles) {
        const QByteArray& roleName = roleNames[role];
        stream << getVariantString(roleName, sourceModel->get(row, roleName), depth);
    }
    return str;
}

QString ModelPrinter::getVariantString(const QVariant& vData) const
{
    if (vData.type() == QVariant::List) {
        QStringList strList;
        for (const auto& v : vData.toList())
            strList.append(getVariantString(v));

        return '[' + strList.join(", ") + ']';
    }

    return vData.toString();
}

QString ModelPrinter::getVariantString(const QString& roleName, const QVariant &vData, int depth) const
{
    QString str;
    QTextStream stream(&str);

    if (vData.canConvert(QMetaType::QVariantMap)) {
        QMapIterator<QString, QVariant> iter(vData.toMap());
        while (iter.hasNext()) {
            iter.next();
            stream << tabify(depth);
            stream << roleName
                << "."
                << iter.key()
                << ": "
                << getVariantString(iter.value())
#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0)
                << Qt::endl;
#else
                << endl;
#endif
        }
    }
    else {
            stream << tabify(depth);
            stream << roleName
                << ": "
                << getVariantString(vData)
#if QT_VERSION >= QT_VERSION_CHECK(5, 14, 0)
                << Qt::endl;
#else
                << endl;
#endif
    }
    return str;
}

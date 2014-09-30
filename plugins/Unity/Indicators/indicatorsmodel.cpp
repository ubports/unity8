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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

#include "indicatorsmodel.h"
#include "indicatorsmanager.h"
#include "indicator.h"
#include "indicators.h"

#include <paths.h>

#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>

/*!
    \qmltype IndicatorsModel
    \inherits QAbstractListModel

    \brief The IndicatorsModel class defines the list model for indicators

    \b {This component is under heavy development.}

    This class expose the available indicators.

    \code
    IndicatorsModel {
        id: menuModel
    }

    ListView {
        id: view
        model: menuModel
        Component.onCompleted: menuModel.load()
    }
    \endcode
*/
IndicatorsModel::IndicatorsModel(QObject *parent)
    : QAbstractListModel(parent)
{
    m_manager = new IndicatorsManager(this);
    QObject::connect(m_manager, SIGNAL(indicatorLoaded(const QString&)), this, SLOT(onIndicatorLoaded(const QString&)));
    QObject::connect(m_manager, SIGNAL(indicatorAboutToBeUnloaded(const QString&)), this, SLOT(onIndicatorAboutToBeUnloaded(const QString&)));

    QObject::connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));
}

/*! \internal */
IndicatorsModel::~IndicatorsModel()
{
    disconnect(m_manager, 0, 0, 0);
    m_manager->deleteLater();
}

/*!
    \qmlproperty IndicatorsModel::count
    The number of data entries in the model.

    \b Note: methods should only be called after the Component has completed.
*/
int IndicatorsModel::count() const
{
    return rowCount();
}

/*!
    \qmlmethod IndicatorsModel::unload()

    Load all indicators.
*/
void IndicatorsModel::load(const QString& profile)
{
    m_indicators.clear();
    m_manager->load(profile);
}

/*!
    \qmlmethod IndicatorsModel::unload()

    Unload all indicators.
*/
void IndicatorsModel::unload()
{
    m_manager->unload();
}

/*! \internal */
void IndicatorsModel::onIndicatorLoaded(const QString& indicator_name)
{
    Indicator::Ptr indicator = m_manager->indicator(indicator_name);
    if (!indicator)
    {
        return;
    }

    if (m_indicators.indexOf(indicator) >= 0)
    {
        return;
    }

    // find the insert position
    int pos = 0;
    while (pos < count())
    {
        // keep going while the existing position is greater. (put lower position on end)
        if (indicator->position() >= data(index(pos), IndicatorsModelRole::Position).toInt())
            break;
        pos++;
    }

    QObject::connect(indicator.data(), SIGNAL(identifierChanged(const QString&)), this, SLOT(onIdentifierChanged()));
    QObject::connect(indicator.data(), SIGNAL(indicatorPropertiesChanged(const QVariant&)), this, SLOT(onIndicatorPropertiesChanged()));

    beginInsertRows(QModelIndex(), pos, pos);

    m_indicators.insert(pos, indicator);
    endInsertRows();
}

/*! \internal */
void IndicatorsModel::onIndicatorAboutToBeUnloaded(const QString& indicator_name)
{
    Indicator::Ptr indicator = m_manager->indicator(indicator_name);
    if (!indicator)
    {
        return;
    }

    int i = 0;
    QMutableListIterator<Indicator::Ptr> iter(m_indicators);
    while(iter.hasNext())
    {
        if (indicator == iter.next())
        {
            beginRemoveRows(QModelIndex(), i, i);
            iter.remove();
            endRemoveRows();
            break;
        }
        i++;
    }

}

/*! \internal */
void IndicatorsModel::onIdentifierChanged()
{
    notifyDataChanged(QObject::sender(), IndicatorsModelRole::Identifier);
}

/*! \internal */
void IndicatorsModel::onIndicatorPropertiesChanged()
{
    notifyDataChanged(QObject::sender(), IndicatorsModelRole::IndicatorProperties);
}

/*! \internal */
void IndicatorsModel::notifyDataChanged(QObject *sender, int role)
{
    Indicator* indicator = qobject_cast<Indicator*>(sender);
    if (!indicator)
    {
        return;
    }

    int index = 0;
    QMutableListIterator<Indicator::Ptr> iter(m_indicators);
    while(iter.hasNext())
    {
        if (indicator == iter.next())
        {
            QModelIndex changedIndex = this->index(index);
            dataChanged(changedIndex, changedIndex, QVector<int>() << role);
            break;
        }
        index++;
    }
}

/*! \internal */
QHash<int, QByteArray> IndicatorsModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty())
    {
        roles[IndicatorsModelRole::Identifier] = "identifier";
        roles[IndicatorsModelRole::Position] = "position";
        roles[IndicatorsModelRole::WidgetSource] = "widgetSource";
        roles[IndicatorsModelRole::PageSource] = "pageSource";
        roles[IndicatorsModelRole::IndicatorProperties] = "indicatorProperties";
    }
    return roles;
}

/*! \internal */
int IndicatorsModel::columnCount(const QModelIndex &) const
{
    return 1;
}

Q_INVOKABLE QVariant IndicatorsModel::data(int row, int role) const
{
    return data(index(row, 0), role);
}

/*! \internal */
QVariant IndicatorsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_indicators.size())
        return QVariant();

    Indicator::Ptr indicator = m_indicators[index.row()];

    switch (role)
    {
        case IndicatorsModelRole::Identifier:
            if (indicator)
            {
                return QVariant(indicator->identifier());
            }
            break;
        case IndicatorsModelRole::Position:
            if (indicator)
            {
                return QVariant(indicator->position());
            }
            break;
        case IndicatorsModelRole::IndicatorProperties:
            if (indicator)
            {
                return QVariant(indicator->indicatorProperties());
            }
            break;
        case IndicatorsModelRole::WidgetSource:
            return "";
        case IndicatorsModelRole::PageSource:
            return "";
        default:
            break;
    }
    return QVariant();
}

/*! \internal */
QModelIndex IndicatorsModel::parent(const QModelIndex&) const
{
    return QModelIndex();
}

/*! \internal */
int IndicatorsModel::rowCount(const QModelIndex&) const
{
    return m_indicators.count();
}

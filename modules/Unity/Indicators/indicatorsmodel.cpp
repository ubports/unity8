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
#include "paths.h"

#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>

/*!
    \qmltype IndicatorsModel
    \inherits QAbstractListModel

    \brief The IndicatorsModel class defines the list model for indicators plugins

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
    \qmlmethod IndicatorsModel::get(int)

    Returns the item at index in the model. This allows the item data to be accessed from JavaScript:
    \b Note: methods should only be called after the Component has completed.
*/
QVariantMap IndicatorsModel::get(int row) const
{
    QVariantMap result;

    QModelIndex index = this->index(row);
    if (index.isValid()) {
        QMap<int, QVariant> data = itemData(index);
        const QHash<int, QByteArray> roleNames = this->roleNames();
        Q_FOREACH(int i, roleNames.keys()) {
            result.insert(roleNames[i], data[i]);
        }
    }
    return result;
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

    Load all plugins.
*/
void IndicatorsModel::load()
{
    m_plugins.clear();
    m_manager->load();
}

/*!
    \qmlmethod IndicatorsModel::unload()

    Unload all plugins.
*/
void IndicatorsModel::unload()
{
    m_manager->unload();
}

/*! \internal */
void IndicatorsModel::onIndicatorLoaded(const QString& indicator)
{
    Indicator::Ptr plugin = m_manager->indicator(indicator);
    if (!plugin)
        return;

    if (m_plugins.indexOf(plugin) >= 0)
        return;

    // find the insert position
    int pos = 0;
    while (pos < count()) {
        // keep going while the existing priority is less.
        if (indicatorData(plugin, Priority).toInt() < data(index(pos), Priority).toInt())
            break;
        pos++;
    }

    QObject::connect(plugin.data(), SIGNAL(identifierChanged(const QString&)), this, SLOT(onIdentifierChanged()));
    QObject::connect(plugin.data(), SIGNAL(indicatorPropertiesChanged(const QVariant&)), this, SLOT(onIndicatorPropertiesChanged()));

    beginInsertRows(QModelIndex(), pos, pos);

    m_plugins.insert(pos, plugin);
    endInsertRows();
}

/*! \internal */
void IndicatorsModel::onIndicatorAboutToBeUnloaded(const QString& indicator)
{
    Indicator::Ptr plugin = m_manager->indicator(indicator);
    if (!plugin)
        return;

    int i = 0;
    QMutableListIterator<Indicator::Ptr> iter(m_plugins);
    while(iter.hasNext())
    {
        if (plugin == iter.next())
        {
            beginRemoveRows(QModelIndex(), i, i);
            iter.remove();
            endRemoveRows();
        }
        i++;
    }

}

/*! \internal */
void IndicatorsModel::onIdentifierChanged()
{
    notifyDataChanged(QObject::sender(), Identifier);
}

/*! \internal */
void IndicatorsModel::onIndicatorPropertiesChanged()
{
    notifyDataChanged(QObject::sender(), IndicatorProperties);
}

/*! \internal */
void IndicatorsModel::notifyDataChanged(QObject *sender, int role)
{
    Indicator* plugin = qobject_cast<Indicator*>(sender);
    if (!plugin)
        return;

    int index = 0;
    QMutableListIterator<Indicator::Ptr> iter(m_plugins);
    while(iter.hasNext())
    {
        if (iter.next().data() == plugin)
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
        roles[Identifier] = "identifier";
        roles[Priority] = "priority";
        roles[Title] = "title";
        roles[Description] = "description";
        roles[WidgetSource] = "widgetSource";
        roles[PageSource] = "pageSource";
        roles[IndicatorProperties] = "indicatorProperties";
        roles[IsValid] = "isValid";
    }
    return roles;
}

/*! \internal */
int IndicatorsModel::columnCount(const QModelIndex &) const
{
    return 1;
}

/*! \internal */
QVariant IndicatorsModel::defaultData(Indicator::Ptr plugin, int role)
{
    switch (role)
    {
        case Priority:
            return 0;
        case Title:
            return plugin ? plugin->identifier() : "Unknown";
        case Description:
            return "";
        case WidgetSource:
            return shellAppDirectory()+"/Panel/Indicators/DefaultIndicatorWidget.qml";
        case PageSource:
            return shellAppDirectory()+"/Panel/Indicators/DefaultIndicatorPage.qml";
    }
    return QVariant();
}

/*! \internal */
QVariant IndicatorsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_plugins.size())
        return QVariant();

    Indicator::Ptr plugin = m_plugins[index.row()];

    switch (role)
    {
        case Identifier:
            if (plugin)
            {
                return QVariant(plugin->identifier());
            }
            break;
        case IndicatorProperties:
            if (plugin)
            {
                return QVariant(plugin->indicatorProperties());
            }
            break;
        case IsValid:
            return (plugin ? true : false);
        case Priority:
        case Title:
        case Description:
        case WidgetSource:
        case PageSource:
            return indicatorData(plugin, role);
        default:
            break;
    }
    return QVariant();
}

QVariant IndicatorsModel::indicatorData(const Indicator::Ptr& plugin, int role) const
{
    if (plugin && m_parsed_indicator_data.contains(plugin->identifier()))
    {
        QVariantMap data = m_parsed_indicator_data[plugin->identifier()];
        return data.value(roleNames()[role], QVariant());
    }
    return defaultData(plugin, role);
}

/*! \internal */
QModelIndex IndicatorsModel::parent(const QModelIndex&) const
{
    return QModelIndex();
}

/*! \internal */
int IndicatorsModel::rowCount(const QModelIndex&) const
{
    return m_plugins.count();
}

void IndicatorsModel::setIndicatorData(const QVariant& data)
{
    m_indicator_data = data;

    m_parsed_indicator_data.clear();
    QMap<QString, QVariant> map = data.toMap();
    QMapIterator<QString, QVariant> iter(map);
    while(iter.hasNext())
    {
        iter.next();
        m_parsed_indicator_data[iter.key()] = iter.value().toMap();
    }

    Q_EMIT indicatorDataChanged(m_indicator_data);
}

QVariant IndicatorsModel::indicatorData() const
{
    return m_indicator_data;
}

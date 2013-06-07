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
#include "indicatorclientinterface.h"

#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>


static bool comparePlugins(const IndicatorClientInterface::Ptr obj1, const IndicatorClientInterface::Ptr obj2)
{
    return obj1->priority() < obj2->priority();
}

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
    IndicatorClientInterface::Ptr plugin = m_manager->indicator(indicator);
    if (!plugin)
        return;

    QList<IndicatorClientInterface::Ptr>::iterator i = qLowerBound(m_plugins.begin(), m_plugins.end(), plugin, comparePlugins);
    int insert_pos = qMin(i - m_plugins.begin(), m_plugins.count());

    beginInsertRows(QModelIndex(), insert_pos, insert_pos);

    QObject* obj = dynamic_cast<QObject*>(plugin.get());
    if (obj)
    {
        QObject::connect(obj, SIGNAL(identifierChanged(const QString&)), this, SLOT(onIdentifierChanged()));
        QObject::connect(obj, SIGNAL(iconChanged(const QUrl&)), this, SLOT(onIconChanged()));
        QObject::connect(obj, SIGNAL(titleChanged(const QString&)), this, SLOT(onTitleChanged()));
        QObject::connect(obj, SIGNAL(labelChanged(const QString&)), this, SLOT(onLabelChanged()));
    }

    m_plugins.insert(i, plugin);

    endInsertRows();
}

/*! \internal */
void IndicatorsModel::onIndicatorAboutToBeUnloaded(const QString& indicator)
{
    IndicatorClientInterface::Ptr plugin = m_manager->indicator(indicator);
    if (!plugin)
        return;

    int i = 0;
    QMutableListIterator<IndicatorClientInterface::Ptr> iter(m_plugins);
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
void IndicatorsModel::onIconChanged()
{
    notifyDataChanged(QObject::sender(), IconSource);
}

/*! \internal */
void IndicatorsModel::onTitleChanged()
{
    notifyDataChanged(QObject::sender(), Title);
}

/*! \internal */
void IndicatorsModel::onLabelChanged()
{
    notifyDataChanged(QObject::sender(), Label);
}

/*! \internal */
void IndicatorsModel::notifyDataChanged(QObject *sender, int role)
{
    IndicatorClientInterface* plugin = dynamic_cast<IndicatorClientInterface*>(sender);
    if (!plugin)
        return;

    int index = 0;
    QMutableListIterator<IndicatorClientInterface::Ptr> iter(m_plugins);
    while(iter.hasNext())
    {
        if (iter.next().get() == plugin)
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
    if (roles.isEmpty()) {
        roles[Identifier] = "identifier";
        roles[Title] = "title";
        roles[IconSource] = "iconSource";
        roles[Label] = "label";
        roles[Description] = "description";
        roles[QMLComponent] = "component";
        roles[InitialProperties] = "initialProperties";
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
QVariant IndicatorsModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_plugins.size())
        return QVariant();

    QVariant attribute;

    IndicatorClientInterface::Ptr plugin = m_plugins[index.row()];

    switch (role) {
    case Identifier:
        if (plugin) {
            attribute = QVariant(plugin->identifier());
        }
        break;
    case Title:
        if (plugin) {
            attribute = QVariant(plugin->title());
        }
        break;
    case IconSource:
        if (plugin) {
            return plugin->icon().toString();
        } else {
            attribute = QVariant("No plugin");
        }
        break;
    case Label:
        if (plugin) {
            attribute = QVariant(plugin->label());
        }
        break;
    case Description:
    {
        if (plugin) {
            attribute = QVariant(plugin->description());
        }
        break;
    }
    case QMLComponent:
        if (plugin) {
            return plugin->componentSource();
        }
        break;
    case InitialProperties:
        if (plugin) {
            attribute = plugin->initialProperties();
        }
        break;
    case IsValid:
        attribute = QVariant(plugin != 0);
        break;
    default:
        break;
    }
    return attribute;
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

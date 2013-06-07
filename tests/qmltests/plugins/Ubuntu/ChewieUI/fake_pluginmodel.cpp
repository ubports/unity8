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

#include "fake_pluginmodel.h"
#include "paths.h"

#include <QQmlContext>
#include <QQmlEngine>
#include <QDebug>
#include <QQmlComponent>

struct Indicator {
    Indicator(QString const& title, QString iconSource, QString label, QString description, QString componentSource)
    : title(title)
    , iconSource(iconSource)
    , label(label)
    , description(description)
    , componentSource(componentSource)
    , isValid(true)
    {}

    QString title;
    QString iconSource;
    QString label;
    QString description;
    QString componentSource;
    QMap<QString, QVariant> initialProperties;
    bool isValid;
};

const QList<Indicator> indicator_list = QList<Indicator>()
    << Indicator("Menu1",   sourceDirectory()+"Panel/graphics/Battery@18.png",      "",     "",     sourceDirectory()+"tests/qmltests/Panel/qml/fake_menu_plugin1.qml")
    << Indicator("Menu2",   sourceDirectory()+"Panel/graphics/Bluetooth@18.png",    "",     "",     sourceDirectory()+"tests/qmltests/Panel/qml/fake_menu_plugin2.qml")
    << Indicator("Menu3",   sourceDirectory()+"Panel/graphics/Clock@18.png",        "",     "",     sourceDirectory()+"tests/qmltests/Panel/qml/fake_menu_plugin3.qml")
    << Indicator("Menu4",   sourceDirectory()+"Panel/graphics/Location@18.png",     "",     "",     sourceDirectory()+"tests/qmltests/Panel/qml/fake_menu_plugin4.qml")
    << Indicator("Menu5",   sourceDirectory()+"Panel/graphics/Network@18.png",      "",     "",     sourceDirectory()+"tests/qmltests/Panel/qml/fake_menu_plugin5.qml");


PluginModel::PluginModel(QObject *parent)
    : QAbstractListModel(parent)
{
    QObject::connect(this, SIGNAL(rowsInserted(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(rowsRemoved(const QModelIndex &, int, int)), this, SIGNAL(countChanged()));
    QObject::connect(this, SIGNAL(modelReset()), this, SIGNAL(countChanged()));
}

/*! \internal */
PluginModel::~PluginModel()
{
}

/*!
    \qmlmethod PluginModel::get(int)

    Returns the item at index in the model. This allows the item data to be accessed from JavaScript:
    \b Note: methods should only be called after the Component has completed.
*/
QVariantMap PluginModel::get(int row) const
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
    \qmlproperty PluginModel::count
    The number of data entries in the model.

    \b Note: methods should only be called after the Component has completed.
*/
int PluginModel::count() const
{
    return rowCount();
}

/*!
    \qmlmethod PluginModel::load()

    Load all plugin information available on baseDir.
*/
void PluginModel::load()
{

}

/*!
    \qmlmethod PluginModel::unload()

    Unload all plugins.
*/
void PluginModel::unload()
{
}

/*! \internal */
QHash<int, QByteArray> PluginModel::roleNames() const
{
    static QHash<int, QByteArray> roles;
    if (roles.isEmpty()) {
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
int PluginModel::columnCount(const QModelIndex &) const
{
    return 1;
}

/*! \internal */
QVariant PluginModel::data(const QModelIndex &index, int role) const
{
    QVariant attribute;

    if ((index.row() >= 0) && (index.row() < indicator_list.size())) {
        Indicator indicator = (indicator_list[index.row()]);

        switch (role) {
        case Title:
            attribute = indicator.title;
            break;
        case IconSource:
            attribute = indicator.iconSource;
            break;
        case Label:
            attribute = indicator.label;
            break;
        case Description:
            attribute = indicator.description;
            break;
        case QMLComponent:
        {
            QQmlContext *context = QQmlEngine::contextForObject(this);
            if (context) {
                QQmlComponent* component = new QQmlComponent(context->parentContext()->engine(), QUrl(indicator.componentSource), NULL);
                attribute = QVariant::fromValue<QQmlComponent*>(component);
            }
        }   break;
        case InitialProperties:
            attribute = indicator.initialProperties;
            break;
        case IsValid:
            attribute = indicator.isValid;
            break;
        default:
            break;
        }
    }
    return attribute;
}

/*! \internal */
QModelIndex PluginModel::parent(const QModelIndex&) const
{
    return QModelIndex();
}

/*! \internal */
int PluginModel::rowCount(const QModelIndex &) const
{
    return indicator_list.size();
}

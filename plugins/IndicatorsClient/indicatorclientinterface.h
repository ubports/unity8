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
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 */

#ifndef INDICATORCLIENTININTERFACE_H
#define INDICATORCLIENTININTERFACE_H

#include <QMap>
#include <QString>
#include <QUrl>
#include <QObject>
#include <QQmlComponent>
#include <QQmlEngine>
#include <QSettings>

#include <memory>

class IndicatorClientInterface
{
public:
    typedef QMap<QString, QVariant> PropertiesMap;
    typedef QMap<QString, QUrl> WidgetsMap;

    typedef std::shared_ptr<IndicatorClientInterface> Ptr;

    enum IndicatorPriority {
        MESSAGING   = 0,
        SOUND       = 10,
        NETWORK     = 20,
        POWER       = 30,
        DATETIME    = 100
    };
    /**
     * @brief This fuction will be called by PluginManager after create the plugin object
     * @param config The dbus configuration used by this plugin
     */
    virtual void init(const QSettings& settings) = 0;

    /**
     * @brief This function will be called by PluginManager before destroy the plugin
     */
    virtual void shutdown() = 0;

    /**
     * @brief Used to retrieve the current plugin icon
     * @return The icon url
     *
     * This function can be used to retrieve the indicator icon which will appear on the panel
     */
    virtual QUrl icon() const = 0;


    /**
     * @brief Used to retrieve the current plugin title
     * @return The title
     *
     * This function can be used to retrieve the indicator title which can be used as plugin name on the menu
     */
    virtual QString title() const = 0;

    /**
     * @brief Used to retrieve the current plugin label
     * @return The label
     *
     * This function can be used to retrieve the indicator label which can appear in the panel
     */
    virtual QString label() const = 0;

    /**
     * @brief Used to retrieve the current plugin label
     * @return The label
     *
     * This function can be used to retrieve the indicator description which can appear in the panel
     */
    virtual QString description() const = 0;

    /**
     * @brief Used to retrieve the current plugin visibility
     * @return The visibility
     *
     * This function can be used to retrieve the indicator is visible on the panel or not
     */
    virtual bool visible() const = 0;

    /**
     * @brief Used to retrieve the current plugin accessible name
     * @return The accessible name is plugin name as seen by assistive technologies
     */
    virtual QString accessibleName() const = 0;


    /**
     * @brief Used to retrieve the current plugin priority
     * @return The priorty value for the plugin, this will be used to arrange the plugin on the indicator panel
     */
    virtual int priority() const = 0;


    /**
     * @brief Used to retrieve the plugin initial component
     * @param engine The current \l QDeclarativeEngine used to parse the componente code
     * @param parent The parent of the returned object
     * @return A new \l QDeclarativeComponent with the initial plugin view
     */
    virtual QQmlComponent *component(QQmlEngine *engine, QObject *parent=0) = 0;

    /**
     * @brief Used during the plugin Component instanciation to set the initial properties
     * @return The map with the initial property and value:  {'property-name' : property-value}
     */

    virtual PropertiesMap initialProperties() = 0;

    /**
     * @brief The plugin should implement this function to return the custom widgets
     * implemente by the plugin
     * @return The map with the widget name and url: {'WifiAccessPointItem' : 'wifi-widget.qml'}
     */
    virtual WidgetsMap widgets() = 0;
};

#endif

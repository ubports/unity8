/*
 * Copyright (C) 2013 Canonical, Ltd.
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
 *
 * Author: Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef MENUCONTENTACTIVATOR_H
#define MENUCONTENTACTIVATOR_H

#include "unityindicatorsglobal.h"

#include <QObject>
#include <QTimer>
#include <QQmlListProperty>


namespace UnityIndicators {
/* Defines an interface for a Timer. */
class UNITYINDICATORS_EXPORT AbstractTimer : public QObject {
    Q_OBJECT
public:
    AbstractTimer(QObject *parent) : QObject(parent), m_isRunning(false) {}
    virtual int interval() const = 0;
    virtual void setInterval(int msecs) = 0;
    virtual void start() { m_isRunning = true; }
    virtual void stop() { m_isRunning = false; }
    bool isRunning() const { return m_isRunning; }
Q_SIGNALS:
    void timeout();
private:
    bool m_isRunning;
};
}

/* Defines a object to express the active state of a menu. */
class UNITYINDICATORS_EXPORT MenuContentState : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool active READ isActive NOTIFY activeChanged)
public:
    MenuContentState(bool active);

    bool isActive() const;
    void setActive(bool active);

Q_SIGNALS:
    void activeChanged();
private:
    bool m_active;
};

class MenuContentActivatorPrivate;

class UNITYINDICATORS_EXPORT MenuContentActivator : public QObject
{
    Q_OBJECT
    Q_PROPERTY(int baseIndex READ baseIndex WRITE setBaseIndex NOTIFY baseIndexChanged)
    Q_PROPERTY(bool running READ isRunning WRITE setRunning NOTIFY runningChanged)
    Q_PROPERTY(int count READ count WRITE setCount NOTIFY countChanged)
    Q_PROPERTY(QQmlListProperty<MenuContentState> content READ content NOTIFY contentChanged DESIGNABLE false)
public:
    MenuContentActivator(QObject* parent = nullptr);
    ~MenuContentActivator();

    Q_INVOKABLE void restart();
    Q_INVOKABLE void stop();
    Q_INVOKABLE void clear();
    Q_INVOKABLE bool isMenuContentActive(int index) const;

    void setRunning(bool running);
    bool isRunning() const;

    void setBaseIndex(int index);
    int baseIndex() const;

    void setCount(int index);
    int count() const;

    void setDelta(int index);
    int delta() const;

    QQmlListProperty<MenuContentState> content();

    // Replaces the existing Timer with the given one.
    //
    // Useful for providing a fake timer when testing.
    void setContentTimer(UnityIndicators::AbstractTimer *timer);
    void setMenuContentState(int index, bool active);

Q_SIGNALS:
    void baseIndexChanged(int baseIndex);
    void deltaChanged(int delta);
    void runningChanged(bool running);
    void countChanged(int count);
    void contentChanged();

private Q_SLOTS:
    void onTimeout();

private:
    MenuContentActivatorPrivate* d;
    friend class MenuContentActivatorPrivate;
};

#endif // MENUCONTENTACTIVATOR_H

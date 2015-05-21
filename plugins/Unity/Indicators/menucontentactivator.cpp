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

 #include "menucontentactivator.h"

// Essentially a QTimer wrapper
class ContentTimer : public UnityIndicators::AbstractTimer
{
    Q_OBJECT
public:
    ContentTimer(QObject *parent) : UnityIndicators::AbstractTimer(parent) {
        m_timer.setSingleShot(false);
        connect(&m_timer, &QTimer::timeout,
                this, &UnityIndicators::AbstractTimer::timeout);
    }
    int interval() const override { return m_timer.interval(); }
    void setInterval(int msecs) override { m_timer.setInterval(msecs); }
    void start() override { m_timer.start(); UnityIndicators::AbstractTimer::start(); }
    void stop() override { m_timer.stop(); UnityIndicators::AbstractTimer::stop(); }
private:
    QTimer m_timer;
};

class MenuContentActivatorPrivate : public QObject
{
    Q_OBJECT
public:
    MenuContentActivatorPrivate(MenuContentActivator* parent)
    :   m_running(false),
        m_baseIndex(0),
        m_delta(0),
        m_count(0),
        m_timer(nullptr),
        q(parent)
    {}

    ~MenuContentActivatorPrivate()
    {
        qDeleteAll(m_content);
        m_content.clear();
    }

    int findNextInactiveDelta(bool* finished = nullptr);

    static int content_count(QQmlListProperty<MenuContentState> *prop);
    static MenuContentState* content_at(QQmlListProperty<MenuContentState> *prop, int index);

    bool m_running;
    int m_baseIndex;
    int m_delta;
    int m_count;
    UnityIndicators::AbstractTimer* m_timer;
    QMap<int, MenuContentState*> m_content;
    MenuContentActivator* q;
};

MenuContentActivator::MenuContentActivator(QObject* parent)
    :   QObject(parent),
        d(new MenuContentActivatorPrivate(this))
{
    qRegisterMetaType<QQmlListProperty<MenuContentState> > ("QQmlListProperty<MenuContentState>");

    setContentTimer(new ContentTimer(this));
    d->m_timer->setInterval(75);
}

MenuContentActivator::~MenuContentActivator()
{
    delete d;
}

void MenuContentActivator::restart()
{
    // when we start, make sure we have the base index in the list.
    setMenuContentState(d->m_baseIndex, true);
    setDelta(0);

    // check if we've finished before starting the timer.
    bool finished = false;
    d->findNextInactiveDelta(&finished);
    if (!finished) {
        d->m_timer->start();
    } else {
        d->m_timer->stop();
    }

    if (!d->m_running) {
        d->m_running = true;
        Q_EMIT runningChanged(true);
    }
}

void MenuContentActivator::stop()
{
    d->m_timer->stop();
    if (!d->m_running) {
        d->m_running = false;
        Q_EMIT runningChanged(false);
    }
}

void MenuContentActivator::clear()
{
    qDeleteAll(d->m_content);
    d->m_content.clear();

    setDelta(0);
    d->m_timer->stop();

    Q_EMIT contentChanged();
}

bool MenuContentActivator::isMenuContentActive(int index) const
{
    if (d->m_content.contains(index))
        return d->m_content[index]->isActive();
    return false;
}

void MenuContentActivator::setRunning(bool running)
{
    if (running) {
        restart();
    } else {
        stop();
    }
}

bool MenuContentActivator::isRunning() const
{
    return d->m_running;
}

void MenuContentActivator::setBaseIndex(int index)
{
    if (d->m_baseIndex != index) {
        d->m_baseIndex = index;

        if (isRunning()) {
            restart();
        }

        Q_EMIT baseIndexChanged(index);
    }
}

int MenuContentActivator::baseIndex() const
{
    return d->m_baseIndex;
}

void MenuContentActivator::setCount(int count)
{
    if (d->m_count != count) {
        d->m_count = count;
        Q_EMIT countChanged(count);

        if (isRunning()) {
            restart();
        }
    }
}

int MenuContentActivator::count() const
{
    return d->m_count;
}

void MenuContentActivator::setDelta(int delta)
{
    if (d->m_delta != delta) {
        d->m_delta = delta;
        Q_EMIT deltaChanged(d->m_delta);
    }
}

int MenuContentActivator::delta() const
{
    return d->m_delta;
}

QQmlListProperty<MenuContentState> MenuContentActivator::content()
{
    return QQmlListProperty<MenuContentState>(this,
                                            0,
                                            MenuContentActivatorPrivate::content_count,
                                            MenuContentActivatorPrivate::content_at);
}

void MenuContentActivator::onTimeout()
{
    bool finished = false;
    int tempDelta = d->findNextInactiveDelta(&finished);
    if (!finished) {
        setMenuContentState(d->m_baseIndex + tempDelta, true);
        setDelta(tempDelta);
    }

    if (finished) {
        d->m_timer->stop();
    }
}

void MenuContentActivator::setContentTimer(UnityIndicators::AbstractTimer *timer)
{
    int interval = 0;
    bool timerWasRunning = false;

    // can be null when called from the constructor
    if (d->m_timer) {
        interval = d->m_timer->interval();
        timerWasRunning = d->m_timer->isRunning();
        if (d->m_timer->parent() == this) {
            delete d->m_timer;
        }
    }

    d->m_timer = timer;
    timer->setInterval(interval);
    connect(timer, &UnityIndicators::AbstractTimer::timeout,
            this, &MenuContentActivator::onTimeout);
    if (timerWasRunning) {
        d->m_timer->start();
    }
}

void MenuContentActivator::setMenuContentState(int index, bool active)
{
    if (d->m_content.contains(index)) {
        d->m_content[index]->setActive(active);
    } else {
        d->m_content[index] = new MenuContentState(active);
        Q_EMIT contentChanged();
    }
}

int MenuContentActivatorPrivate::findNextInactiveDelta(bool* finished)
{
    if (m_count == 0 || m_baseIndex >= m_count) {
        if (finished) *finished = true;
        return 0;
    }

    int tmpDelta = m_delta;
    bool topReached = false, bottomReached = false;
    while(true) {

        // prechecks for bottom and top limits.
        if (tmpDelta > 0 && bottomReached) tmpDelta = -tmpDelta;
        if (tmpDelta < 0 && topReached) tmpDelta = (-tmpDelta) + 1;

        if (tmpDelta > 0) {
            // negative of baseIndex
            tmpDelta = -tmpDelta;
            // reached the bottom?
            if (m_baseIndex + tmpDelta < 0) {
                bottomReached = true;
                // if we've reached the top as well, then we know we're done.
                if (topReached) {
                    if (finished) *finished = true;
                    return 0;
                }
                continue;
            }
        } else {
            // positive of baseIndex
            tmpDelta = (-tmpDelta) + 1;
            // reached the top?
            if (m_baseIndex + tmpDelta >= m_count) {
                topReached = true;
                // if we've reached the bottom as well, then we know we're done.
                if (bottomReached) {
                    if (finished) *finished = true;
                    return 0;
                }
                continue;
            }
        }

        if (q->isMenuContentActive(m_baseIndex + tmpDelta)) {
            continue;
        }
        break;
    }
    if (finished) *finished = false;
    return tmpDelta;
}

int MenuContentActivatorPrivate::content_count(QQmlListProperty<MenuContentState> *prop)
{
    MenuContentActivator *p = qobject_cast<MenuContentActivator*>(prop->object);
    // we'll create MenuContentState on demand.
    return p->count();
}

MenuContentState* MenuContentActivatorPrivate::content_at(QQmlListProperty<MenuContentState> *prop, int index)
{
    MenuContentActivator *p = qobject_cast<MenuContentActivator*>(prop->object);
    MenuContentActivatorPrivate *d = p->d;

    if (!d->m_content.contains(index)) {
        MenuContentState* content = new MenuContentState(false);
        d->m_content[index] = content;
        return content;
    }

    return d->m_content[index];
}

MenuContentState::MenuContentState(bool active)
    :   m_active(active)
{
}

bool MenuContentState::isActive() const
{
    return m_active;
}

void MenuContentState::setActive(bool active)
{
    if (m_active != active) {
        m_active = active;
        Q_EMIT activeChanged();
    }
}

// Because we are defining a new QObject-based class (ContentTimer) here.
#include "menucontentactivator.moc"

/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "Screens.h"
#include "ScreensConfiguration.h"
#include "Screen.h"
#include "WorkspaceManager.h"

// qtmirserver
#include <qtmir/screens.h>
#include <QGuiApplication>
#include <QQmlEngine>

// Qt
#include <QScreen>
#include <QWindow>

ConcreteScreens* ConcreteScreens::m_self{nullptr};

Screens::Screens(const QSharedPointer<qtmir::Screens>& model)
    : m_wrapped(model)
{
}

Screens::~Screens()
{
    qDeleteAll(m_screens);
    m_screens.clear();
}

QHash<int, QByteArray> Screens::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ScreenRole] = "screen";
    return roles;
}

QVariant Screens::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_screens.size()) {
        return QVariant();
    }

    switch(role) {
    case ScreenRole:
        return QVariant::fromValue(m_screens.at(index.row()));
    } // switch

    return QVariant();
}

int Screens::rowCount(const QModelIndex &) const
{
    return count();
}

int Screens::indexOf(Screen *screen) const
{
    return m_screens.indexOf(screen);
}

Screen *Screens::get(int index) const
{
    return m_screens.at(index);
}

int Screens::count() const
{
    return m_screens.size();
}

QVariant Screens::activeScreen() const
{
    for (int i = 0; i < m_screens.count(); i++) {
        if (m_screens[i]->isActive()) return i;
    }
    return QVariant();
}

void Screens::activateScreen(const QVariant& vindex)
{
    bool ok = false;
    int index = vindex.toInt(&ok);
    if (!ok || index < 0 || m_screens.count() <= index) return;

    auto screen = m_screens.at(index);
    screen->setActive(true);
}


ConcreteScreens::ConcreteScreens(const QSharedPointer<qtmir::Screens> &model, ScreensConfiguration* config)
    : Screens(model)
    , m_config(config)
{
    m_self = this;
    connect(m_wrapped.data(), &qtmir::Screens::screenAdded, this, &ConcreteScreens::onScreenAdded);
    connect(m_wrapped.data(), &qtmir::Screens::screenRemoved, this, &ConcreteScreens::onScreenRemoved);
    connect(m_wrapped.data(), &qtmir::Screens::activeScreenChanged, this, &ConcreteScreens::activeScreenChanged);

    Q_FOREACH(qtmir::Screen* screen, m_wrapped->screens()) {
        auto screenWrapper(new ConcreteScreen(screen));
        m_config->load(screenWrapper);

        QQmlEngine::setObjectOwnership(screenWrapper, QQmlEngine::CppOwnership);
        m_screens.push_back(screenWrapper);
    }
}

ConcreteScreens::~ConcreteScreens()
{
    Q_FOREACH(Screen* screen, m_screens) {
        m_config->save(screen);
    }
    delete m_config;
}

ConcreteScreens *ConcreteScreens::self()
{
    return ConcreteScreens::m_self;
}

ProxyScreens *ConcreteScreens::createProxy()
{
    return new ProxyScreens(this);
}

void ConcreteScreens::sync(ProxyScreens *proxy)
{
    if (!proxy) return;
    proxy->setSyncing(true);

    const auto& proxyList = proxy->list();
    for (int i = 0; i < m_screens.count() && i < proxyList.count(); ++i) {
        m_screens[i]->sync(proxyList[i]);
    }

    proxy->setSyncing(false);
}

void ConcreteScreens::onScreenAdded(qtmir::Screen *added)
{
    Q_FOREACH(auto screenWrapper, m_screens) {
        if (screenWrapper->wrapped() == added) return;
    }

    beginInsertRows(QModelIndex(), count(), count());
    auto screenWrapper(new ConcreteScreen(added));
    m_config->load(screenWrapper);

    QQmlEngine::setObjectOwnership(screenWrapper, QQmlEngine::CppOwnership);
    m_screens.push_back(screenWrapper);
    endInsertRows();
    Q_EMIT screenAdded(screenWrapper);
    Q_EMIT countChanged();
}

void ConcreteScreens::onScreenRemoved(qtmir::Screen *removed)
{
    int index = 0;
    QMutableVectorIterator<Screen*> iter(m_screens);
    while(iter.hasNext()) {
        auto screenWrapper = iter.next();
        if (screenWrapper->wrapped() == removed) {
            m_config->save(screenWrapper);

            beginRemoveRows(QModelIndex(), index, index);
            iter.remove();
            endRemoveRows();

            Q_EMIT screenRemoved(screenWrapper);
            Q_EMIT countChanged();

            screenWrapper->deleteLater();
            break;
        }
        index++;
    }
}


ProxyScreens::ProxyScreens(Screens * const screens)
    : Screens(screens->m_wrapped)
    , m_original(screens)
    , m_syncing(false)
{
    connect(screens, &Screens::screenAdded, this, [this](Screen *added) {
        Q_FOREACH(auto screen, m_screens) {
            auto proxy = static_cast<ProxyScreen*>(screen);
            if (proxy->proxyObject() == added) return;
        }

        beginInsertRows(QModelIndex(), count(), count());
        auto screenWrapper(new ProxyScreen(added, this));
        QQmlEngine::setObjectOwnership(screenWrapper, QQmlEngine::CppOwnership);
        m_screens.push_back(screenWrapper);
        endInsertRows();
        Q_EMIT screenAdded(screenWrapper);
        Q_EMIT countChanged();
    });

    connect(screens, &Screens::screenRemoved, this, [this](Screen *removed) {
        int index = 0;
        QMutableVectorIterator<Screen*> iter(m_screens);
        while(iter.hasNext()) {
            auto proxy = static_cast<ProxyScreen*>(iter.next());
            if (proxy->proxyObject() == removed) {

                beginRemoveRows(QModelIndex(), index, index);
                iter.remove();
                endRemoveRows();

                Q_EMIT screenRemoved(proxy);
                Q_EMIT countChanged();

                delete proxy;
                break;
            }
            index++;
        }
    });

    Q_FOREACH(Screen* screen, screens->list()) {
        auto screenWrapper(new ProxyScreen(screen, this));
        QQmlEngine::setObjectOwnership(screenWrapper, QQmlEngine::CppOwnership);
        m_screens.push_back(screenWrapper);
    }
}

void ProxyScreens::setSyncing(bool syncing)
{
    m_syncing = syncing;
}

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
#include "Screen.h"
#include "WorkspaceManager.h"

// qtmirserver
#include <qtmir/screens.h>
#include <QGuiApplication>

// Qt
#include <QScreen>
#include <QWindow>

Screens::Screens(const QSharedPointer<qtmir::Screens>& model)
    : m_wrapped(model)
{
    connect(m_wrapped.data(), &qtmir::Screens::screenAdded, this, &Screens::onScreenAdded);
    connect(m_wrapped.data(), &qtmir::Screens::screenRemoved, this, &Screens::onScreenRemoved);
    connect(m_wrapped.data(), &qtmir::Screens::activeScreenChanged, this, &Screens::activeScreenChanged);

    Q_FOREACH(qtmir::Screen* screen, m_wrapped->screens()) {
        m_screens.push_back(new Screen(screen));
    }
}

Screens::~Screens()
{
    qDeleteAll(m_screens);
    m_screens.clear();
}

Screens::Screens(const Screens &other)
    : QAbstractListModel(nullptr)
    , m_wrapped(other.m_wrapped)
{
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

ScreensProxy *Screens::createProxy()
{
    return new ScreensProxy(this);
}

void Screens::sync(Screens *proxy)
{
    if (!proxy) return;

    const auto& proxyList = proxy->list();
    for (int i = 0; i < m_screens.count() && i < proxyList.count(); ++i) {
        m_screens[i]->sync(proxyList[i]);
    }

    // need to clean up all the workspaces we unassigned.
    WorkspaceManager::instance()->destroyFloatingWorkspaces();
}

void Screens::activateScreen(const QVariant& vindex)
{
    bool ok = false;
    int index = vindex.toInt(&ok);
    if (!ok || index < 0 || m_screens.count() <= index) return;

    auto screen = m_screens.at(index);
    screen->setActive(true);
}

void Screens::onScreenAdded(qtmir::Screen *added)
{
    Q_FOREACH(auto screenWrapper, m_screens) {
        if (screenWrapper->wrapped() == added) return;
    }

    beginInsertRows(QModelIndex(), count(), count());
    auto screenWrapper(new Screen(added));
    m_screens.push_back(screenWrapper);
    endInsertRows();
    Q_EMIT screenAdded(screenWrapper);
    Q_EMIT countChanged();
}

void Screens::onScreenRemoved(qtmir::Screen *removed)
{
    int index = 0;
    QMutableVectorIterator<Screen*> iter(m_screens);
    while(iter.hasNext()) {
        auto screenWrapper = iter.next();
        if (screenWrapper->wrapped() == removed) {

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

ScreensProxy::ScreensProxy(Screens * const screens)
    : Screens(*screens)
    , m_original(screens)
{
    connect(screens, &Screens::screenAdded, this, [this](Screen *added) {
        Q_FOREACH(auto screen, m_screens) {
            auto proxy = static_cast<ScreenProxy*>(screen);
            if (proxy->proxyObject() == added) return;
        }

        beginInsertRows(QModelIndex(), count(), count());
        auto screenWrapper(new ScreenProxy(added));
        m_screens.push_back(screenWrapper);
        endInsertRows();
        Q_EMIT screenAdded(screenWrapper);
        Q_EMIT countChanged();
    });

    connect(screens, &Screens::screenAdded, this, [this](Screen *removed) {
        int index = 0;
        QMutableVectorIterator<Screen*> iter(m_screens);
        while(iter.hasNext()) {
            auto proxy = static_cast<ScreenProxy*>(iter.next());
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
        m_screens.push_back(new ScreenProxy(screen));
    }
}

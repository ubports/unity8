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

// qtmirserver
#include <qtmir/qtmir.h>
#include <qtmir/screens.h>
#include <QGuiApplication>

// Qt
#include <QScreen>
#include <QWindow>

Screens::Screens(QObject *parent)
    : QAbstractListModel(parent)
    , m_wrapped(qtmir::get_screen_model())
{
    if (qGuiApp->platformName() != QLatin1String("mirserver")) {
        qCritical("Not using 'mirserver' QPA plugin. Using qGuiApp may produce unknown results.");
    }

    connect(m_wrapped.data(), &qtmir::Screens::screenAdded, this, &Screens::onScreenAdded);
    connect(m_wrapped.data(), &qtmir::Screens::screenRemoved, this, &Screens::onScreenRemoved);
    connect(qGuiApp, &QGuiApplication::focusWindowChanged, this, &Screens::activeScreenChanged);

    Q_FOREACH(qtmir::Screen* screen, m_wrapped->screens()) {
        m_screenList.push_back(new Screen(screen));
    }
}

QHash<int, QByteArray> Screens::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[ScreenRole] = "screen";
    return roles;
}

QVariant Screens::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_screenList.size()) {
        return QVariant();
    }

    switch(role) {
    case ScreenRole:
        return QVariant::fromValue(m_screenList.at(index.row()));
    } // switch

    return QVariant();
}

int Screens::rowCount(const QModelIndex &) const
{
    return count();
}

int Screens::count() const
{
    return m_screenList.size();
}

QVariant Screens::activeScreen() const
{
    for (int i = 0; i < m_screenList.count(); i++) {
        if (m_screenList[i]->isActive()) return i;
    }
    return QVariant();
}

void Screens::activateScreen(const QVariant& vindex)
{
    bool ok = false;
    int index = vindex.toInt(&ok);
    if (!ok || index < 0 || m_screenList.count() <= index) return;

    auto screen = m_screenList.at(index);
    screen->setActive(true);
}

void Screens::onScreenAdded(qtmir::Screen *screen)
{
    Q_FOREACH(auto screenWrapper, m_screenList) {
        if (screenWrapper->wrapped() == screen) return;
    }

    beginInsertRows(QModelIndex(), count(), count());
    auto screenWrapper(new Screen(screen));
    m_screenList.push_back(screenWrapper);
    endInsertRows();
    Q_EMIT screenAdded(screenWrapper);
    Q_EMIT countChanged();
}

void Screens::onScreenRemoved(qtmir::Screen *screen)
{
    int index = 0;
    QMutableListIterator<Screen*> iter(m_screenList);
    while(iter.hasNext()) {
        auto screenWrapper = iter.next();
        if (screenWrapper->wrapped() == screen) {

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

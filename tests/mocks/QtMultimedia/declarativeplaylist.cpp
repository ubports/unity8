/*
 * Copyright (C) 2015 Canonical, Ltd.
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
 */

#include "declarativeplaylist.h"

DeclarativePlaylist::DeclarativePlaylist(QObject *parent)
    : QObject(parent)
    , m_currentIndex(-1)
{
}

QUrl DeclarativePlaylist::currentItemSource() const
{
    return itemSource(currentIndex());
}

int DeclarativePlaylist::currentIndex() const
{
    return m_currentIndex;
}

void DeclarativePlaylist::setCurrentIndex(int index)
{
    if (currentIndex() == index)
        return;

    m_currentIndex = index;
    Q_EMIT currentIndexChanged();
    Q_EMIT currentItemSourceChanged();
}

QUrl DeclarativePlaylist::itemSource(int index) const
{
    if (index < 0 || index >= m_medias.count())
        return QUrl();
    return m_medias[index];
}

bool DeclarativePlaylist::addItem(const QUrl &source)
{
    m_medias << source;
    setCurrentIndex(0);
    return true;
}

bool DeclarativePlaylist::addItems(const QList<QUrl> &sources)
{
    m_medias << sources;
    if (!sources.isEmpty())
        setCurrentIndex(0);
    return true;
}

bool DeclarativePlaylist::clear()
{
    m_medias.clear();
    setCurrentIndex(-1);
    return true;
}

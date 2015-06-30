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

QUrl DeclarativePlaylist::currentSource() const
{
    return source(currentIndex());
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
}

QUrl DeclarativePlaylist::source(int index) const
{
    return m_medias[index];
}

bool DeclarativePlaylist::addSource(const QUrl &source)
{
    m_medias << source;
    return true;
}


bool DeclarativePlaylist::clear()
{
    m_medias.clear();
    return true;
}

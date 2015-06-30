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

#ifndef DECLARATIVEPLAYLIST_H
#define DECLARATIVEPLAYLIST_H

#include <QObject>
#include <QUrl>

class DeclarativePlaylist : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl currentSource READ currentSource NOTIFY currentSourceChanged)
    Q_PROPERTY(int currentIndex READ currentIndex WRITE setCurrentIndex NOTIFY currentIndexChanged)

public:
    DeclarativePlaylist(QObject *parent = 0);

    QUrl currentSource() const;
    int currentIndex() const;
    void setCurrentIndex(int currentIndex);

public Q_SLOTS:
    QUrl source(int index) const;
    bool addSource(const QUrl &source);
    bool clear();

Q_SIGNALS:
    void currentSourceChanged();
    void currentIndexChanged();

private:
    Q_DISABLE_COPY(DeclarativePlaylist)

    int m_currentIndex;
    QList<QUrl> m_medias;
};

#endif
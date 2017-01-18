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
 * Author: Pete Woods <pete.woods@canonical.com>
 */

#include "ColorTheme.h"

#include <QtCore/QDir>
#include <QtCore/QString>
#include <QtGui/QIcon>
#include <QMultiMap>

using namespace UserMetricsOutput;

namespace UserMetricsOutput
{

class ColorThemePrivate: QObject
{
    Q_OBJECT

public:
    explicit ColorThemePrivate(ColorTheme *parent = 0);

    ColorThemePrivate(const QColor &start, const QColor &main,
            const QColor &end, ColorTheme *parent = 0);

    ~ColorThemePrivate();

    ColorTheme * const q_ptr;

    QColor m_start;

    QColor m_main;

    QColor m_end;

protected:
    int calculateLength();

private:
    Q_DECLARE_PUBLIC(ColorTheme)
};

}

ColorThemePrivate::ColorThemePrivate(
        ColorTheme *parent) :
        q_ptr(parent)
{
}

ColorThemePrivate::ColorThemePrivate(const QColor &start,
        const QColor &main, const QColor &end, ColorTheme *parent) :
        q_ptr(parent), m_start(start), m_main(main), m_end(end)
{
}

ColorThemePrivate::~ColorThemePrivate()
{
}

ColorTheme::ColorTheme(QObject *parent) :
        QObject(parent), d_ptr(new ColorThemePrivate(this))
{
}

ColorTheme::ColorTheme(QColor &first, QColor &main,
        QColor &end, QObject *parent) :
        QObject(parent), d_ptr(
                new ColorThemePrivate(first, main, end, this))
{

}

ColorTheme & ColorTheme::operator=(
        const ColorTheme & other)
{
    if (d_ptr->m_start != other.d_ptr->m_start)
    {
        d_ptr->m_start = other.d_ptr->m_start;
        startChanged(d_ptr->m_start);
    }
    if (d_ptr->m_main != other.d_ptr->m_main)
    {
        d_ptr->m_main = other.d_ptr->m_main;
        mainChanged(d_ptr->m_main);
    }

    if (d_ptr->m_end != other.d_ptr->m_end)
    {
        d_ptr->m_end = other.d_ptr->m_end;
        endChanged(d_ptr->m_end);
    }

    return *this;
}

ColorTheme::~ColorTheme()
{
    delete d_ptr;
}

QColor ColorTheme::start() const
{
    return d_ptr->m_start;
}

QColor ColorTheme::main() const
{
    return d_ptr->m_main;
}

QColor ColorTheme::end() const
{
    return d_ptr->m_end;
}

#include "ColorTheme.moc"

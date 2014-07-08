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
 * Authored by: Nick Dedekind <nick.dedekind@canonical.com>
 */


#ifndef APPLICATION_ARGUMENTS_H
#define APPLICATION_ARGUMENTS_H

#include <QObject>
#include <QSize>
#include <QStringList>

class ApplicationArguments : public QObject
{
    Q_OBJECT
public:
    // Not exposed to the app as setSize isn't invokable
    void setSize(int width, int height) {
        m_size.rwidth()  = width;
        m_size.rheight() = height;
    }

    Q_INVOKABLE bool hasGeometry() const { return m_size.isValid(); }
    Q_INVOKABLE int width() const { return m_size.width(); }
    Q_INVOKABLE int height() const { return m_size.height(); }

private:
  QSize m_size;
};

#endif // APPLICATION_ARGUMENTS_H

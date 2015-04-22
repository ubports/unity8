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

#ifndef UNITY_MOCK_COLORTHEME_H
#define UNITY_MOCK_COLORTHEME_H

#include <QObject>
#include <QColor>

namespace UserMetricsOutput
{
class ColorThemePrivate;

class Q_DECL_EXPORT ColorTheme: public QObject
{
Q_OBJECT

Q_PROPERTY(QColor start READ start NOTIFY startChanged FINAL)
Q_PROPERTY(QColor main READ main NOTIFY mainChanged FINAL)
Q_PROPERTY(QColor end READ end NOTIFY endChanged FINAL)

public:
    explicit ColorTheme(QObject *parent = 0);

    explicit ColorTheme(QColor &first, QColor &main, QColor &end,
            QObject *parent = 0);

    ColorTheme & operator=(const ColorTheme & other);

    ~ColorTheme();

    QColor start() const;

    QColor main() const;

    QColor end() const;

Q_SIGNALS:
    void startChanged(const QColor &color);

    void mainChanged(const QColor &color);

    void endChanged(const QColor &color);

protected:
    ColorThemePrivate * const d_ptr;

    Q_DECLARE_PRIVATE(ColorTheme)

};

}

#endif // UNITY_MOCK_COLORTHEME_H

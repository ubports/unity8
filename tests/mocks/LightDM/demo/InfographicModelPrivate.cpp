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

#include "../InfographicModelPrivate.h"

namespace QLightDM
{

void InfographicModelPrivate::generateFakeData()
{
    std::default_random_engine generator;
    std::normal_distribution<qreal> distribution(0.5, 0.2);
    auto rand = std::bind(distribution, generator);

    QColor orange(QColor::fromRgbF(0.9, 0.3, 0.1, 1.0));
    QColor yellow(QColor::fromRgbF(1.0, 0.6, 0.0, 1.0));
    QColor red(QColor::fromRgbF(0.8, 0.0, 0.0, 1.0));
    QColor darkPurple(QColor::fromRgbF(0.5, 0.2, 0.3, 1.0));
    QColor lightPurple(QColor::fromRgbF(0.8, 0.1, 0.8, 1.0));
    QColor pink(QColor::fromRgbF(0.75, 0.13, 0.75));

    InfographicColorTheme orangeTheme(yellow, orange, red);
    InfographicColorTheme yellowTheme(orange, yellow, orange);
    InfographicColorTheme redTheme(red, red, red);
    InfographicColorTheme darkPurpleTheme(lightPurple, darkPurple, pink);
    InfographicColorTheme lightPurpleTheme(lightPurple, lightPurple,
            lightPurple);
    InfographicColorTheme pinkTheme(lightPurple, pink, darkPurple);

    {
        QVariantList firstMonth;
        while (firstMonth.size() < 17)
            firstMonth.push_back(QVariant(rand()));
        while (firstMonth.size() < 31)
            firstMonth.push_back(QVariant());
        QVariantList secondMonth;
        while (secondMonth.size() < 31)
            secondMonth.push_back(QVariant(rand()));
        QSharedPointer<InfographicData> data(
                new InfographicData("<b>52km</b> travelled", yellowTheme, firstMonth,
                        orangeTheme, secondMonth, this));
        m_fakeData.insert("guest", data);
    }

    {
        QVariantList firstMonth;
        while (firstMonth.size() < 17)
            firstMonth.push_back(QVariant(rand()));
        while (firstMonth.size() < 31)
            firstMonth.push_back(QVariant());
        QVariantList secondMonth;
        while (secondMonth.size() < 31)
            secondMonth.push_back(QVariant(rand()));
        QSharedPointer<InfographicData> data(
                new InfographicData("<b>33</b> messages today", pinkTheme,
                        firstMonth, orangeTheme, secondMonth, this));
        m_fakeData.insert("guest", data);
    }

    {
        QVariantList firstMonth;
        while (firstMonth.size() < 17)
            firstMonth.push_back(QVariant(rand()));
        while (firstMonth.size() < 31)
            firstMonth.push_back(QVariant());
        QVariantList secondMonth;
        while (secondMonth.size() < 31)
            secondMonth.push_back(QVariant(rand()));
        QSharedPointer<InfographicData> data(
                new InfographicData("<b>69</b> minutes talk time", darkPurpleTheme,
                        firstMonth, redTheme, secondMonth, this));
        m_fakeData.insert("guest", data);
    }
}

}

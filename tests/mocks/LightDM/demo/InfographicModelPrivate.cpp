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

    QVector<QColor> colours;
    colours.push_back(QColor::fromRgbF(0.3, 0.27, 0.32));
    colours.push_back(QColor::fromRgbF(0.83, 0.49, 0.58));
    colours.push_back(QColor::fromRgbF(0.63, 0.51, 0.59));

    colours.push_back(QColor::fromRgbF(0.28, 0.26, 0.4));
    colours.push_back(QColor::fromRgbF(0.47, 0.38, 0.56));
    colours.push_back(QColor::fromRgbF(0.69, 0.65, 0.78));

    colours.push_back(QColor::fromRgbF(0.32, 0.21, 0.16));
    colours.push_back(QColor::fromRgbF(0.55, 0.45, 0.32));
    colours.push_back(QColor::fromRgbF(0.85, 0.74, 0.53));

    colours.push_back(QColor::fromRgbF(0.25, 0.31, 0.19));
    colours.push_back(QColor::fromRgbF(0.63, 0.53, 0.3));
    colours.push_back(QColor::fromRgbF(0.89, 0.56, 0.31));

    InfographicColorTheme first(colours[0], colours[1], colours[2]);
    InfographicColorTheme second(colours[3], colours[4], colours[5]);
    InfographicColorTheme eighth(colours[6], colours[7], colours[8]);
    InfographicColorTheme ninth(colours[9], colours[10], colours[11]);

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
                new InfographicData("<b>52km</b> travelled", first, firstMonth,
                        ninth, secondMonth, this));
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
                new InfographicData("<b>33</b> messages today", second,
                        firstMonth, eighth, secondMonth, this));
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
                new InfographicData("<b>69</b> minutes talk time", eighth,
                        firstMonth, second, secondMonth, this));
        m_fakeData.insert("guest", data);
    }
}

}

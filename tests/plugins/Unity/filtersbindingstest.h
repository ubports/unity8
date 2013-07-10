/*
 * Copyright (C) 2013 Canonical, Ltd.
 *
 * Authors:
 *  Pawel Stolowski <pawel.stolowski@canonical.com>
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
 */

#ifndef FILTERSBINDINGSTEST_H
#define FILTERSBINDINGSTEST_H

#include <QObject>
#include <dee.h>

class FiltersBindingsTest : public QObject
{
    Q_OBJECT

    private Q_SLOTS:
        void initTestCase();
        void testMultiRangeFilter();
        void testCheckOptionFilter();
        void testRadioOptionFilter();

    private:
        DeeModel* createFilterModel();
        GVariant* createOptions(int numOfOptions);
        void createMultiRangeFilter(DeeModel *model, const std::string &id, const std::string &name, int optionCount);
        void createCheckOptionFilter(DeeModel *model, const std::string &id, const std::string &name, int optionCount);
        void createRadioOptionFilter(DeeModel *model, const std::string &id, const std::string &name, int optionCount);
        void createFilter(DeeModel *model, const std::string &renderer, const std::string &id, const std::string &name, int optionCount);
};

#endif

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

#include "filtersbindingstest.h"

// libunity-core
#include <UnityCore/Filter.h>
#include <UnityCore/MultiRangeFilter.h>

// Qt
#include <QTest>
#include <QSignalSpy>

// libunity
#include <unity.h>

// local
#include "filter.h"
#include "multirangefilter.h"
#include "checkoptionfilter.h"
#include "radiooptionfilter.h"
#include "ratingsfilter.h"
#include "ratingfilteroption.h"
#include "genericoptionsmodel.h"

void FiltersBindingsTest::initTestCase()
{
}

GVariant* FiltersBindingsTest::createOptions(int numOfOptions)
{
    auto vtype = g_variant_type_new("a(sssb)");
    auto vb = g_variant_builder_new(vtype);
    for (int i = 0; i<numOfOptions; i++) {
        const std::string optId = "opt" + std::to_string(i);
        const std::string optName = "Option " + std::to_string(i);
        g_variant_builder_add(vb, "(sssb)", optId.c_str(), optName.c_str(), "", false);
    }
    return g_variant_builder_end(vb);
}

DeeModel* FiltersBindingsTest::createFilterModel()
{
    const char* filter_schema[8] = {"s", "s", "s", "s", "a{sv}", "b", "b", "b"};
    auto model = dee_sequence_model_new();
    dee_model_set_schema_full (DEE_MODEL(model), filter_schema, 8);
    return model;
}

void FiltersBindingsTest::createMultiRangeFilter(DeeModel *model, const std::string &id, const std::string &name, int optionCount)
{
    createFilter(model, "filter-multirange", id, name, optionCount);
}

void FiltersBindingsTest::createRadioOptionFilter(DeeModel *model, const std::string &id, const std::string &name, int optionCount)
{
    createFilter(model, "filter-radiooption", id, name, optionCount);
}

void FiltersBindingsTest::createCheckOptionFilter(DeeModel *model, const std::string &id, const std::string &name, int optionCount)
{
    createFilter(model, "filter-checkoption", id, name, optionCount);
}

void FiltersBindingsTest::createRatingsFilter(DeeModel *model, const std::string &id, const std::string &name)
{
    GVariant* row[8];

    row[0] = g_variant_new_string(id.c_str());
    row[1] = g_variant_new_string(name.c_str());
    row[2] = g_variant_new_string(""); // icon hint
    row[3] = g_variant_new_string("filter-ratings");

    GVariant *children[2];
    GVariant *key1 = g_variant_new_string("show-all-button");
    GVariant *key2 = g_variant_new_string("rating");
    children[0] = g_variant_new_dict_entry(key1, g_variant_new_variant(g_variant_new_boolean(false)));
    children[1] = g_variant_new_dict_entry(key2, g_variant_new_variant(g_variant_new_double(0.0f)));
    auto fhints = g_variant_new_array(G_VARIANT_TYPE("{sv}"), children, 2);

    row[4] = fhints;
    row[5] = g_variant_new_boolean(true);  // visible
    row[6] = g_variant_new_boolean(false); // collapsed
    row[7] = g_variant_new_boolean(false); // filtering

    dee_model_append_row(model, row);
}

void FiltersBindingsTest::createFilter(DeeModel *model, const std::string &renderer, const std::string &id, const std::string &name, int optionCount)
{
    GVariant* row[8];

    row[0] = g_variant_new_string(id.c_str());
    row[1] = g_variant_new_string(name.c_str());
    row[2] = g_variant_new_string(""); // icon hint
    row[3] = g_variant_new_string(renderer.c_str()); // renderer

    GVariant *children[2];
    GVariant *key1 = g_variant_new_string("show-all-button");
    GVariant *key2 = g_variant_new_string("options");
    children[0] = g_variant_new_dict_entry(key1, g_variant_new_variant(g_variant_new_boolean(false)));
    children[1] = g_variant_new_dict_entry(key2, g_variant_new_variant(createOptions(optionCount)));
    auto fhints = g_variant_new_array(G_VARIANT_TYPE("{sv}"), children, 2);

    row[4] = fhints;
    row[5] = g_variant_new_boolean(true);  // visible
    row[6] = g_variant_new_boolean(false); // collapsed
    row[7] = g_variant_new_boolean(false); // filtering

    dee_model_append_row(model, row);
}

void FiltersBindingsTest::testMultiRangeFilter()
{
    auto model = createFilterModel();

    createMultiRangeFilter(model, "f1", "Filter1", 1);
    createMultiRangeFilter(model, "f2", "Filter2", 2);
    createMultiRangeFilter(model, "f3", "Filter3", 3);

    // create filter out of 1st row
    auto iter = dee_model_get_first_iter(DEE_MODEL(model));
    {
        auto core_filter = unity::dash::Filter::FilterFromIter(model, iter);
        QVERIFY(core_filter != nullptr);
        auto bind_filter = Filter::newFromUnityFilter(core_filter);
        auto multi_filter = dynamic_cast<MultiRangeFilter*>(bind_filter);
        QVERIFY(multi_filter != nullptr);
        auto options = multi_filter->options();
        QCOMPARE(options->rowCount(), 1);

        auto idx = options->index(0);
        QVariant id_var = options->data(idx, GenericOptionsModel::RoleId);
        QVariant name_var = options->data(idx, GenericOptionsModel::RoleName);
        QVariant icon_var = options->data(idx, GenericOptionsModel::RoleIconHint);
        QVariant active_var = options->data(idx, GenericOptionsModel::RoleActive);

        QCOMPARE(id_var.toString(), QString("opt0"));
        QCOMPARE(name_var.toString(), QString("Option 0"));
        QCOMPARE(icon_var.toString(), QString(""));
        QCOMPARE(active_var.toBool(), false);

        delete multi_filter;
     }

    // create filter out of 2nd row
    iter = dee_model_next(DEE_MODEL(model), iter);
    {
        auto core_filter = unity::dash::Filter::FilterFromIter(model, iter);
        QVERIFY(core_filter != nullptr);
        auto bind_filter = Filter::newFromUnityFilter(core_filter);
        auto multi_filter = dynamic_cast<MultiRangeFilter*>(bind_filter);
        QVERIFY(multi_filter != nullptr);
        auto options = multi_filter->options();
        QCOMPARE(options->rowCount(), 2);

        auto idx = options->index(0);
        QVariant id_var = options->data(idx, GenericOptionsModel::RoleId);
        QVariant name_var = options->data(idx, GenericOptionsModel::RoleName);
        QVariant icon_var = options->data(idx, GenericOptionsModel::RoleIconHint);
        QVariant active_var = options->data(idx, GenericOptionsModel::RoleActive);

        QCOMPARE(id_var.toString(), QString("opt0"));
        QCOMPARE(name_var.toString(), QString("Option 0"));
        QCOMPARE(icon_var.toString(), QString(""));
        QCOMPARE(active_var.toBool(), false);

        AbstractFilterOption* opt1 = options->getRawOption(0);
        QCOMPARE(opt1->id(), QString("opt0"));

        AbstractFilterOption* opt2 = options->getRawOption(1);
        QCOMPARE(opt2->id(), QString("opt1"));

        delete multi_filter;
    }

    // create filter out of 3nd row
    iter = dee_model_next(DEE_MODEL(model), iter);
    {
        auto core_filter = unity::dash::Filter::FilterFromIter(model, iter);
        QVERIFY(core_filter != nullptr);
        auto bind_filter = Filter::newFromUnityFilter(core_filter);
        auto multi_filter = dynamic_cast<MultiRangeFilter*>(bind_filter);
        QVERIFY(multi_filter != nullptr);
        auto options = multi_filter->options();
        QCOMPARE(options->rowCount(), 3);

        AbstractFilterOption* opt0 = options->getRawOption(0);
        QCOMPARE(opt0->id(), QString("opt0"));

        AbstractFilterOption* opt1 = options->getRawOption(1);
        QCOMPARE(opt1->id(), QString("opt1"));

        AbstractFilterOption* opt2 = options->getRawOption(2);
        QCOMPARE(opt2->id(), QString("opt2"));

        // verify combined filter options are bound to correct underlying unity options
        auto core_multi_filter = std::dynamic_pointer_cast<unity::dash::MultiRangeFilter>(core_filter);
        QCOMPARE(QString::fromStdString(core_multi_filter->options()[0]->id()), QString("opt0"));
        QCOMPARE(QString::fromStdString(core_multi_filter->options()[1]->id()), QString("opt1"));
        QCOMPARE(QString::fromStdString(core_multi_filter->options()[2]->id()), QString("opt2"));

        QSignalSpy opt0spy(opt0, SIGNAL(activeChanged(bool)));
        QSignalSpy opt1spy(opt1, SIGNAL(activeChanged(bool)));
        QSignalSpy opt2spy(opt2, SIGNAL(activeChanged(bool)));

        // test active property changes
        QCOMPARE(opt0->active(), false);

        opt0->setActive(true);  // activate 1st option
        QCOMPARE(opt0spy.count(), 1);
        QCOMPARE(opt1spy.count(), 0);
        QCOMPARE(opt2spy.count(), 0);
        QCOMPARE(opt0->active(), true);
        QCOMPARE(opt1->active(), false);
        QCOMPARE(opt2->active(), false);

        opt1->setActive(true);
        QCOMPARE(opt0spy.count(), 2);
        QCOMPARE(opt1spy.count(), 1);
        QCOMPARE(opt2spy.count(), 0);
        QCOMPARE(opt0->active(), false); //1st combined option gets deactivated
        QCOMPARE(opt1->active(), true);
        QCOMPARE(opt2->active(), false);

        opt1->setActive(false);  // and de-activate it
        QCOMPARE(opt0spy.count(), 2);
        QCOMPARE(opt1spy.count(), 2);
        QCOMPARE(opt2spy.count(), 0);
        QCOMPARE(opt0->active(), false);
        QCOMPARE(opt1->active(), false);
        QCOMPARE(opt2->active(), false);

        opt2->setActive(true);  // activate another combined option
        QCOMPARE(opt0spy.count(), 2);
        QCOMPARE(opt1spy.count(), 2);
        QCOMPARE(opt2spy.count(), 1);
        QCOMPARE(opt0->active(), false);
        QCOMPARE(opt1->active(), false);
        QCOMPARE(opt2->active(), true);

        delete multi_filter;
    }
}

void FiltersBindingsTest::testCheckOptionFilter()
{
    auto model = createFilterModel();

    createCheckOptionFilter(model, "f1", "Filter1", 3);

    // create filter out of 1st row
    auto iter = dee_model_get_first_iter(DEE_MODEL(model));
    {
        auto core_filter = unity::dash::Filter::FilterFromIter(model, iter);
        QVERIFY(core_filter != nullptr);
        auto bind_filter = Filter::newFromUnityFilter(core_filter);
        auto check_filter = dynamic_cast<CheckOptionFilter*>(bind_filter);
        QVERIFY(check_filter != nullptr);
        auto options = check_filter->options();
        QCOMPARE(options->rowCount(), 3);

        QCOMPARE(check_filter->id(), QString("f1"));
        QCOMPARE(check_filter->name(), QString("Filter1"));
        QCOMPARE(check_filter->iconHint(), QString(""));
        QCOMPARE(check_filter->rendererName(), QString("filter-checkoption"));
        QCOMPARE(check_filter->visible(), true);
        QCOMPARE(check_filter->collapsed(), false);
        QCOMPARE(check_filter->filtering(), false);

        auto idx = options->index(0);
        QVariant id_var = options->data(idx, GenericOptionsModel::RoleId);
        QVariant name_var = options->data(idx, GenericOptionsModel::RoleName);
        QVariant icon_var = options->data(idx, GenericOptionsModel::RoleIconHint);
        QVariant active_var = options->data(idx, GenericOptionsModel::RoleActive);

        QCOMPARE(id_var.toString(), QString("opt0"));
        QCOMPARE(name_var.toString(), QString("Option 0"));
        QCOMPARE(icon_var.toString(), QString(""));
        QCOMPARE(active_var.toBool(), false);

        idx = options->index(1);
        id_var = options->data(idx, GenericOptionsModel::RoleId);
        name_var = options->data(idx, GenericOptionsModel::RoleName);
        icon_var = options->data(idx, GenericOptionsModel::RoleIconHint);
        active_var = options->data(idx, GenericOptionsModel::RoleActive);

        QCOMPARE(id_var.toString(), QString("opt1"));
        QCOMPARE(name_var.toString(), QString("Option 1"));
        QCOMPARE(icon_var.toString(), QString(""));
        QCOMPARE(active_var.toBool(), false);

        AbstractFilterOption* opt0 = options->getRawOption(0);
        AbstractFilterOption* opt1 = options->getRawOption(1);
        AbstractFilterOption* opt2 = options->getRawOption(2);

        QSignalSpy opt0spy(opt0, SIGNAL(activeChanged(bool)));
        QSignalSpy opt1spy(opt1, SIGNAL(activeChanged(bool)));
        QSignalSpy opt2spy(opt2, SIGNAL(activeChanged(bool)));

        // test active property changes
        QCOMPARE(opt0->active(), false);
        QCOMPARE(opt1->active(), false);
        QCOMPARE(opt2->active(), false);

        opt0->setActive(true);
        QCOMPARE(opt0spy.count(), 1);
        QCOMPARE(opt1spy.count(), 0);
        QCOMPARE(opt2spy.count(), 0);
        QCOMPARE(opt0->active(), true);
        QCOMPARE(opt1->active(), false);
        QCOMPARE(opt2->active(), false);

        opt1->setActive(true);
        QCOMPARE(opt0spy.count(), 2);
        QCOMPARE(opt1spy.count(), 1);
        QCOMPARE(opt2spy.count(), 0);
        QCOMPARE(opt0->active(), false);
        QCOMPARE(opt1->active(), true);
        QCOMPARE(opt2->active(), false);

        delete check_filter;
    }
}

void FiltersBindingsTest::testRadioOptionFilter()
{
    auto model = createFilterModel();

    createRadioOptionFilter(model, "f1", "Filter1", 3);

    // create filter out of 1st row
    auto iter = dee_model_get_first_iter(DEE_MODEL(model));
    {
        auto core_filter = unity::dash::Filter::FilterFromIter(model, iter);
        QVERIFY(core_filter != nullptr);
        auto bind_filter = Filter::newFromUnityFilter(core_filter);
        auto radio_filter = dynamic_cast<RadioOptionFilter*>(bind_filter);
        QVERIFY(radio_filter != nullptr);
        auto options = radio_filter->options();
        QCOMPARE(options->rowCount(), 3);

        auto idx = options->index(0);
        QVariant id_var = options->data(idx, GenericOptionsModel::RoleId);
        QVariant name_var = options->data(idx, GenericOptionsModel::RoleName);
        QVariant icon_var = options->data(idx, GenericOptionsModel::RoleIconHint);
        QVariant active_var = options->data(idx, GenericOptionsModel::RoleActive);

        QCOMPARE(id_var.toString(), QString("opt0"));
        QCOMPARE(name_var.toString(), QString("Option 0"));
        QCOMPARE(icon_var.toString(), QString(""));
        QCOMPARE(active_var.toBool(), false);

        idx = options->index(1);
        id_var = options->data(idx, GenericOptionsModel::RoleId);
        name_var = options->data(idx, GenericOptionsModel::RoleName);
        icon_var = options->data(idx, GenericOptionsModel::RoleIconHint);
        active_var = options->data(idx, GenericOptionsModel::RoleActive);

        QCOMPARE(id_var.toString(), QString("opt1"));
        QCOMPARE(name_var.toString(), QString("Option 1"));
        QCOMPARE(icon_var.toString(), QString(""));
        QCOMPARE(active_var.toBool(), false);

        AbstractFilterOption* opt0 = options->getRawOption(0);
        AbstractFilterOption* opt1 = options->getRawOption(1);
        AbstractFilterOption* opt2 = options->getRawOption(2);

        QSignalSpy opt0spy(opt0, SIGNAL(activeChanged(bool)));
        QSignalSpy opt1spy(opt1, SIGNAL(activeChanged(bool)));
        QSignalSpy opt2spy(opt2, SIGNAL(activeChanged(bool)));

        // test active property changes
        QCOMPARE(opt0->active(), false);
        QCOMPARE(opt1->active(), false);
        QCOMPARE(opt2->active(), false);

        opt0->setActive(true);
        QCOMPARE(opt0spy.count(), 1);
        QCOMPARE(opt1spy.count(), 0);
        QCOMPARE(opt2spy.count(), 0);
        QCOMPARE(opt0->active(), true);
        QCOMPARE(opt1->active(), false);
        QCOMPARE(opt2->active(), false);

        opt1->setActive(true);
        QCOMPARE(opt0spy.count(), 2);
        QCOMPARE(opt1spy.count(), 1);
        QCOMPARE(opt2spy.count(), 0);
        QCOMPARE(opt0->active(), false);
        QCOMPARE(opt1->active(), true);
        QCOMPARE(opt2->active(), false);

        delete radio_filter;
    }
}

void FiltersBindingsTest::testRatingsFilter()
{
    auto model = createFilterModel();

    createRatingsFilter(model, "f1", "Filter1");

    // create filter out of 1st row
    auto iter = dee_model_get_first_iter(DEE_MODEL(model));
    {
        auto core_filter = unity::dash::Filter::FilterFromIter(model, iter);
        QVERIFY(core_filter != nullptr);
        auto bind_filter = Filter::newFromUnityFilter(core_filter);
        auto rating_filter = dynamic_cast<RatingsFilter*>(bind_filter);
        QVERIFY(rating_filter != nullptr);
        auto options = rating_filter->options();
        QCOMPARE(options->rowCount(), 5);

        RatingFilterOption* opt[5];
        for (int i = 0; i<5; i++) {
            opt[i] = dynamic_cast<RatingFilterOption *>(options->getRawOption(i));
        }

        QSignalSpy opt0spy(opt[0], SIGNAL(activeChanged(bool)));
        QSignalSpy opt4spy(opt[4], SIGNAL(activeChanged(bool)));

        QVERIFY(qAbs(opt[0]->value() - 0.2f) <= 0.0001f);
        QVERIFY(qAbs(opt[1]->value() - 0.4f) <= 0.0001f);
        QVERIFY(qAbs(opt[2]->value() - 0.6f) <= 0.0001f);
        QVERIFY(qAbs(opt[3]->value() - 0.8f) <= 0.0001f);
        QVERIFY(qAbs(opt[4]->value() - 1.0f) <= 0.0001f);

        QVERIFY(rating_filter->rating() <= 0.0001f); // rating equals zero

        // all options initially inactive
        for (int i=0; i<5; i++) {
            QCOMPARE(opt[i]->active(), false);
        }

        // verify activation for all options
        for (int i=0; i<5; i++) {
            opt[i]->setActive(true);
            QCOMPARE(opt[i]->active(), true);
            QVERIFY(rating_filter->rating() - ((i+1)*0.2f) <= 0.0001f);

            // verify that all other options are inactive
            for (int j=0; j<5; j++) {
                if (i != j) {
                    QCOMPARE(opt[j]->active(), false);
                }
            }
        }

        QCOMPARE(opt0spy.count(), 2);
        QCOMPARE(opt4spy.count(), 1);

        opt[4]->setActive(false);
        QVERIFY(rating_filter->rating() <= 0.0001f); // rating equals zero
        QCOMPARE(opt4spy.count(), 2);
    }
}

QTEST_MAIN(FiltersBindingsTest)

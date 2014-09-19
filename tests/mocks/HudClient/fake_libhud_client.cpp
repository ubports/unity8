/*
 * Copyright (C) 2012, 2013 Canonical, Ltd.
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

#include <hud-client.h>

#include "libhud_client_stub.h"

/* Schema that is used in the DeeModel representing
   the results */
static const gchar * results_model_schema[] = {
    "v", /* Command ID */
    "s", /* Command Name */
    "a(ii)", /* Highlights in command name */
    "s", /* Description */
    "a(ii)", /* Highlights in description */
    "s", /* Shortcut */
    "u", /* Distance */
    "b", /* Parameterized */
};

DeeModel *resultsModel = 0;
GMenuModel *parametrizedActionModel = 0;
GActionGroup *parametrizedActionGroup = 0;

static void hud_client_query_class_init(HudClientQueryClass *klass);
static void hud_client_query_init(HudClientQuery *self);
G_DEFINE_TYPE(HudClientQuery, hud_client_query, G_TYPE_OBJECT)

static void hud_client_query_init(HudClientQuery * /*self*/)
{
}
static void hud_client_query_class_init(HudClientQueryClass * /*klass*/)
{
    HudClientStub::m_querySignalToolbarUpdated = g_signal_new (HUD_CLIENT_QUERY_SIGNAL_TOOLBAR_UPDATED,
                                           HUD_CLIENT_TYPE_QUERY,
                                           G_SIGNAL_RUN_LAST,
                                           0, /* offset */
                                           nullptr, nullptr, /* Accumulator */
                                           g_cclosure_marshal_VOID__VOID,
                                           G_TYPE_NONE, 0, G_TYPE_NONE);
}

HudClientQuery *hud_client_query_new(const gchar *query)
{
    HudClientStub::m_lastSetQuery = QString::fromUtf8(query);
    HudClientStub::m_query = HUD_CLIENT_QUERY(g_object_new(HUD_CLIENT_TYPE_QUERY, nullptr));
    return HudClientStub::m_query;
}

DeeModel *hud_client_query_get_results_model(HudClientQuery *cquery)
{
    Q_ASSERT(cquery == HudClientStub::m_query);
    Q_UNUSED(cquery);
    if (!resultsModel) {
        resultsModel = dee_sequence_model_new();
        dee_model_set_schema_full(resultsModel, results_model_schema, G_N_ELEMENTS(results_model_schema));

        GVariant * columns[G_N_ELEMENTS(results_model_schema) + 1];
        columns[0] = g_variant_new_variant(g_variant_new_uint64(0));
        columns[1] = g_variant_new_string("Help");
        columns[2] = g_variant_new_array(G_VARIANT_TYPE("(ii)"), nullptr, 0);
        columns[3] = g_variant_new_string("Get Help");
        columns[4] = g_variant_new_array(G_VARIANT_TYPE("(ii)"), nullptr, 0);
        columns[5] = g_variant_new_string("");
        columns[6] = g_variant_new_uint32(3);
        columns[7] = g_variant_new_boolean(false);
        columns[8] = nullptr;
        dee_model_append_row(resultsModel, columns);

        columns[0] = g_variant_new_variant(g_variant_new_uint64(1));
        columns[1] = g_variant_new_string("About");
        columns[3] = g_variant_new_string("Show About");
        dee_model_append_row(resultsModel, columns);

        columns[0] = g_variant_new_variant(g_variant_new_uint64(2));
        columns[1] = g_variant_new_string("Foo");
        columns[3] = g_variant_new_string("Show Foo");
        columns[7] = g_variant_new_boolean(true);
        dee_model_append_row(resultsModel, columns);

        columns[0] = g_variant_new_variant(g_variant_new_uint64(3));
        columns[1] = g_variant_new_string("Bar");
        columns[3] = g_variant_new_string("Show Bar");
        columns[7] = g_variant_new_boolean(false);
        dee_model_append_row(resultsModel, columns);

        columns[0] = g_variant_new_variant(g_variant_new_uint64(4));
        columns[1] = g_variant_new_string("FooBar");
        columns[3] = g_variant_new_string("Show FooBar");
        dee_model_append_row(resultsModel, columns);

        columns[0] = g_variant_new_variant(g_variant_new_uint64(5));
        columns[1] = g_variant_new_string("UltraFooBar");
        columns[3] = g_variant_new_string("Show UltraFooBar");
        dee_model_append_row(resultsModel, columns);
    }
    return resultsModel;
}

void hud_client_query_execute_toolbar_item(HudClientQuery *cquery, HudClientQueryToolbarItems item, guint timestamp)
{
    Q_ASSERT(cquery == HudClientStub::m_query);
    Q_UNUSED(timestamp);
    Q_UNUSED(cquery);
    HudClientStub::m_lastExecutedToolbarItem = item;
}

void hud_client_query_set_query(HudClientQuery *cquery, const char *query)
{
    Q_ASSERT(cquery == HudClientStub::m_query);
    Q_UNUSED(cquery);
    HudClientStub::m_lastSetQuery = QString::fromUtf8(query);
}

void hud_client_query_execute_command(HudClientQuery *cquery, GVariant *command_key, guint timestamp)
{
    Q_ASSERT(cquery == HudClientStub::m_query);
    Q_UNUSED(cquery);
    Q_UNUSED(timestamp);
    for (uint i = 0; i < dee_model_get_n_rows(resultsModel); ++i) {
        DeeModelIter *iter = dee_model_get_iter_at_row(resultsModel, i);
        if (!dee_model_get_bool(resultsModel, iter, 7)) {
            GVariant *it_command = dee_model_get_value(resultsModel, iter, 0);
            if (g_variant_equal (command_key, it_command)) {
                HudClientStub::m_lastExecutedCommandRow = i;
                g_variant_unref(it_command);
                return;
            }
            g_variant_unref(it_command);
        }
    }
    HudClientStub::m_lastExecutedCommandRow = -1;
}

HudClientParam *hud_client_query_execute_param_command(HudClientQuery *cquery, GVariant *command_key, guint timestamp)
{
    Q_ASSERT(cquery == HudClientStub::m_query);
    Q_UNUSED(cquery);
    Q_UNUSED(timestamp);
    for (uint i = 0; i < dee_model_get_n_rows(resultsModel); ++i) {
        DeeModelIter *iter = dee_model_get_iter_at_row(resultsModel, i);
        if (dee_model_get_bool(resultsModel, iter, 7)) {
            GVariant *it_command = dee_model_get_value(resultsModel, iter, 0);
            if (g_variant_equal (command_key, it_command)) {
                HudClientStub::m_lastExecutedParametrizedCommandRow = i;
                g_variant_unref(it_command);
                // No need to create a real HudClientParam since it's always passed down to us
                return (HudClientParam *)g_object_new(G_TYPE_OBJECT, nullptr);
            }
            g_variant_unref(it_command);
        }
    }
    HudClientStub::m_lastExecutedParametrizedCommandRow = -1;
    return nullptr;
}

void hud_client_query_voice_query(HudClientQuery *cquery)
{
    Q_ASSERT(cquery == HudClientStub::m_query);
    Q_UNUSED(cquery);
    // TODO We are not testing voice queries yet
}

gboolean hud_client_query_toolbar_item_active(HudClientQuery *cquery, HudClientQueryToolbarItems item)
{
    Q_ASSERT(cquery == HudClientStub::m_query);
    Q_UNUSED(cquery);
    if (item == HUD_CLIENT_QUERY_TOOLBAR_HELP)
        return HudClientStub::m_helpToolbarItemEnabled;

    return true;
}

GMenuModel *hud_client_param_get_model(HudClientParam *param)
{
    Q_UNUSED(param);

    if (!parametrizedActionModel) {
        GMenu *menu = g_menu_new();
        GMenuItem *item = g_menu_item_new("Item1Label", nullptr);
        g_menu_item_set_attribute_value(item, "parameter-type", g_variant_new_string("slider"));
        g_menu_item_set_attribute_value(item, "min", g_variant_new_double(10));
        g_menu_item_set_attribute_value(item, "max", g_variant_new_double(80));
        g_menu_item_set_attribute_value(item, "live", g_variant_new_boolean(true));
        g_menu_item_set_attribute_value(item, "value", g_variant_new_double(75));
        g_menu_item_set_attribute_value(item, "action", g_variant_new_string("costAction"));
        g_menu_append_item (menu, item);

        parametrizedActionModel = G_MENU_MODEL(menu);
    }

    return parametrizedActionModel;
}

void hud_client_param_send_cancel(HudClientParam *param)
{
    Q_UNUSED(param);
    g_clear_object(&parametrizedActionModel);
    parametrizedActionModel = 0;
    HudClientStub::m_lastParametrizedCommandCommited = false;
}

static void on_signal_activated (GSimpleAction *action, GVariant *parameter,  gpointer /*user_data*/)
{
    // Only double for the moment
    HudClientStub::m_activatedActions.insert(g_action_get_name(G_ACTION(action)), QVariant(g_variant_get_double(parameter)));
}

GActionGroup *hud_client_param_get_actions(HudClientParam *param)
{
    Q_UNUSED(param);
    if (!parametrizedActionGroup) {
        GSimpleActionGroup *actionGroup = g_simple_action_group_new();
        GSimpleAction *action = g_simple_action_new("costAction", G_VARIANT_TYPE_DOUBLE);
        g_action_map_add_action(G_ACTION_MAP(actionGroup), G_ACTION(action));

        g_signal_connect (action, "activate", G_CALLBACK (on_signal_activated), nullptr);


        parametrizedActionGroup = G_ACTION_GROUP(actionGroup);
    }

    return parametrizedActionGroup;
}

void hud_client_param_send_commit(HudClientParam *param)
{
    Q_UNUSED(param);
    g_object_unref(parametrizedActionGroup);
    parametrizedActionGroup = 0;
    g_clear_object(&parametrizedActionModel);
    parametrizedActionModel = 0;
    HudClientStub::m_lastParametrizedCommandCommited = true;
}

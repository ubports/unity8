/*
 * Copyright (C) 2015 Canonical Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 3, as published
 * by the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranties of
 * MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR
 * PURPOSE.  See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along
 * with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
#include <gio/gio.h>
#include <stdio.h>
#include <stdlib.h>

G_DEFINE_QUARK (SLIDER_VALUE, slider_value)

typedef struct
{
    GSimpleActionGroup *actions;
    GMenu *menu;

    guint actions_export_id;
    guint menu_export_id;
    int action_delay;
    int change_interval;
} IndicatorTestService;

typedef struct
{
    GSimpleAction *action;
    GVariant* value;
} Action;

static void
bus_acquired (GDBusConnection *connection,
              const gchar     *name,
              gpointer         user_data)
{
    (void) name;
    IndicatorTestService *indicator = user_data;
    GError *error = NULL;

    indicator->actions_export_id = g_dbus_connection_export_action_group (connection,
                                                                          "/com/canonical/indicator/mock",
                                                                          G_ACTION_GROUP (indicator->actions),
                                                                          &error);
    if (indicator->actions_export_id == 0)
    {
        g_warning ("cannot export action group: %s", error->message);
        g_error_free (error);
        return;
    }

    indicator->menu_export_id = g_dbus_connection_export_menu_model (connection,
                                                                     "/com/canonical/indicator/mock/desktop",
                                                                     G_MENU_MODEL (indicator->menu),
                                                                     &error);
    if (indicator->menu_export_id == 0)
    {
        g_warning ("cannot export menu: %s", error->message);
        g_error_free (error);
        return;
    }
}

static void
name_lost (GDBusConnection *connection,
           const gchar     *name,
           gpointer         user_data)
{
    (void) name;
    IndicatorTestService *indicator = user_data;

    if (indicator->actions_export_id)
    g_dbus_connection_unexport_action_group (connection, indicator->actions_export_id);

    if (indicator->menu_export_id)
    g_dbus_connection_unexport_menu_model (connection, indicator->menu_export_id);
}

static void
activate_show (GSimpleAction *action,
               GVariant      *parameter,
               gpointer       user_data)
{
    (void) action;
    (void) parameter;
    (void) user_data;
    g_message ("showing");
}

static gboolean
actual_switch (gpointer user_data)
{
    GSimpleAction *action = user_data;

    GVariant* v = g_action_get_state(G_ACTION(action));
    gboolean state = g_variant_get_boolean (v);
    GVariant *new_state = g_variant_new_boolean (state == TRUE ? FALSE : TRUE);

    g_simple_action_set_state(action, new_state);

    g_variant_unref (v);
    g_message ("switching %d", state);
    return FALSE;
}

static void
activate_switch (GSimpleAction *action,
                 GVariant      *parameter,
                 gpointer       user_data)
{
    (void) action;
    (void) parameter;

    IndicatorTestService *indicator = user_data;

    g_timeout_add(indicator->action_delay, actual_switch, action);
    g_message ("switch delay");
}

static gboolean
actual_slide (gpointer user_data)
{
    Action *slide_action = user_data;

    g_simple_action_set_state(G_SIMPLE_ACTION(slide_action->action), slide_action->value);
    g_message ("sliding %f", g_variant_get_double(slide_action->value));
    free(slide_action);

    return FALSE;
}

void change_slider (GSimpleAction *action,
                    GVariant      *value,
                    gpointer       user_data)
{
    IndicatorTestService *indicator = user_data;

    Action* slide_action = malloc(sizeof(Action));
    slide_action->action = action;
    slide_action->value = g_variant_ref(value);

    g_timeout_add(indicator->action_delay, actual_slide, slide_action);
    g_message ("slide delay %f", g_variant_get_double(value));
}

static gboolean
change_interval (gpointer user_data)
{
    g_message ("change interval");

    IndicatorTestService *indicator = user_data;

    GAction* action_switch = g_action_map_lookup_action(G_ACTION_MAP(indicator->actions), "action.switch");
    actual_switch(G_SIMPLE_ACTION(action_switch));

    GAction* action_checkbox = g_action_map_lookup_action(G_ACTION_MAP(indicator->actions), "action.checkbox");
    actual_switch(G_SIMPLE_ACTION(action_checkbox));

    GAction* action_accessPoint = g_action_map_lookup_action(G_ACTION_MAP(indicator->actions), "action.accessPoint");
    actual_switch(G_SIMPLE_ACTION(action_accessPoint));

    GAction* action_slider = g_action_map_lookup_action(G_ACTION_MAP(indicator->actions), "action.slider");
    static double old_value = 0.25;
    double new_value = old_value == 0.25 ? 0.75 : 0.25;
    old_value = new_value;
    Action* slide_action = malloc(sizeof(Action));
    slide_action->action = G_SIMPLE_ACTION(action_slider);
    slide_action->value = g_variant_new_double(new_value);
    actual_slide(slide_action);

    return TRUE;
}

int
main (int argc, char **argv)
{
    IndicatorTestService indicator = { 0 };
    indicator.action_delay = -1;
    indicator.change_interval = -1;
    GMenuItem *item;
    GMenu *submenu;
    GActionEntry entries[] = {
        { "_header", NULL, NULL, "{'title': <'Test'>,"
                                 " 'label': <'Test'>,"
                                 " 'visible': <true>,"
                                 " 'accessible-desc': <'Test indicator'> }", NULL },
        { "action.show", activate_show, NULL, NULL, NULL },
        { "action.switch", activate_switch, NULL, "true", NULL },
        { "action.checkbox", activate_switch, NULL, "true", NULL },
        { "action.accessPoint", activate_switch, NULL, "false", NULL },
        { "action.slider", NULL, NULL, "0.5", change_slider }
    };
    GMainLoop *loop;

    int help = 0;
    if (argc > 1)
    {
        int i;
        for (i = 1; i < argc; i++) {
            const char *arg = argv[i];

            if (arg[0] == '-') {
                switch (arg[1])
                {
                    case 't':
                    {
                        arg += 2;
                        if (!arg[0] && i < argc-1) {
                            i++;
                            int delay = -1;

                            if (sscanf(argv[i], "%d", &delay) == 1) {
                                indicator.action_delay = delay;
                            } else {
                                printf("Invalid action delay value: %s\n", argv[i]);
                                help = 1;
                            }
                        } else {
                            printf("Invalid action delay value: %s\n", argv[i]);
                            help = 1;
                        }
                        break;
                    }

                    case 'c':
                    {
                        arg += 2;
                        if (!arg[0] && i < argc-1) {
                            i++;
                            int interval = -1;

                            if (sscanf(argv[i], "%d", &interval) == 1) {
                                indicator.change_interval = interval;
                            } else {
                                printf("Invalid change interval value: %s\n", argv[i]);
                                help = 1;
                            }
                        } else {
                            printf("Invalid change interval value: %s\n", argv[i]);
                            help = 1;
                        }
                        break;
                    }

                    case 'h':
                        help = 1;
                        break;
                }
            }
        }
    }

    if (help) {
        printf("Usage: %s [<options>]\n"
               "  -t DELAY               Action activation delay\n"
               "  -c CHANGE_INTERVAL     Interval to change action values\n"
               "  -h                     Show this help text\n"
               , argv[0]);
        return 0;
    }

    indicator.actions = g_simple_action_group_new ();
    g_action_map_add_action_entries (G_ACTION_MAP (indicator.actions), entries, G_N_ELEMENTS (entries), &indicator);

    submenu = g_menu_new ();
    g_menu_append (submenu, "Show", "indicator.action.show");

    // Switch
    item = g_menu_item_new("Switch", "indicator.action.switch");
    g_menu_item_set_attribute (item, "x-canonical-type", "s", "com.canonical.indicator.switch");
    g_menu_append_item(submenu, item);

    // Checkbox
    item = g_menu_item_new("Checkbox", "indicator.action.checkbox");
    g_menu_append_item(submenu, item);

    // Slider
    item = g_menu_item_new("Slider", "indicator.action.slider");
    g_menu_item_set_attribute (item, "x-canonical-type", "s", "com.canonical.indicator.slider");
    g_menu_append_item(submenu, item);

    // Access Point
    item = g_menu_item_new("Access Point", "indicator.action.accessPoint");
    g_menu_item_set_attribute (item, "x-canonical-type", "s", "unity.widgets.systemsettings.tablet.accesspoint");
    g_menu_append_item(submenu, item);


    item = g_menu_item_new (NULL, "indicator._header");
    g_menu_item_set_attribute (item, "x-canonical-type", "s", "com.canonical.indicator.root");
    g_menu_item_set_submenu (item, G_MENU_MODEL (submenu));
    indicator.menu = g_menu_new ();
    g_menu_append_item (indicator.menu, item);

    g_bus_own_name (G_BUS_TYPE_SESSION,
                    "com.canonical.indicator.mock",
                    G_BUS_NAME_OWNER_FLAGS_NONE,
                    bus_acquired,
                    NULL,
                    name_lost,
                    &indicator,
                    NULL);

    loop = g_main_loop_new (NULL, FALSE);

    if (indicator.change_interval != -1) {
        g_timeout_add(indicator.change_interval, change_interval,  &indicator);
    }

    g_main_loop_run (loop);

    g_object_unref (submenu);
    g_object_unref (item);
    g_object_unref (indicator.actions);
    g_object_unref (indicator.menu);
    g_object_unref (loop);

    return 1;
}

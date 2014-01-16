/*
 * Copyright (C) 2013, 2014 Canonical, Ltd.
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

#include "fake_applications_scope.h"

static const gchar * categories_model_schema[] = {
    "s", //ID
    "s", // DISPLAY_NAME
    "s", // ICON_HINT
    "s", // RENDERER_NAME
    "a{sv}" // HINTS
};

ApplicationsScope::ApplicationsScope(bool visible, QObject* parent)
    : Scope(parent)
{
    m_id = "applications.scope";
    m_name = "Applications";
    m_visible = visible;
    m_previewRendererName = "preview-application";
    m_categories->setModel(createCategoriesModel());
}

DeeModel* ApplicationsScope::createCategoriesModel()
{
    DeeModel* category_model = dee_sequence_model_new();
    dee_model_set_schema_full(category_model, categories_model_schema, G_N_ELEMENTS(categories_model_schema));
    GVariant* hints = g_variant_new_array(g_variant_type_element(G_VARIANT_TYPE_VARDICT), NULL, 0);

    GVariant* children[1];
    children[0] = g_variant_new_dict_entry(g_variant_new_string("content-type"),
                                           g_variant_new_variant(g_variant_new_string("apps")));
    GVariant* recentHints = g_variant_new_array(g_variant_type_element(G_VARIANT_TYPE_VARDICT), children, 1);
    dee_model_append(category_model,
                     "recent",
                     "Recent",
                     "gtk-apply",
                     "special",
                     recentHints);

    dee_model_append(category_model,
                     "installed",
                     "Installed",
                     "gtk-apply",
                     "grid",
                     hints);

    dee_model_append(category_model,
                     "suggested",
                     "Suggested",
                     "gtk-apply",
                     "grid",
                     hints);

    dee_model_append(category_model,
                     "outdated",
                     "Outdaded",
                     "gtk-apply",
                     "grid",
                     hints);

    return category_model;
}

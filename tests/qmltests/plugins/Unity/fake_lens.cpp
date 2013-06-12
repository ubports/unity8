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
 */

// Self
#include "fake_lens.h"

#include <dee.h>
#include "paths.h"

static DeeModel* create_categories_model(unsigned category_count);
static DeeModel* create_results_model(unsigned category_count, unsigned result_count);

// TODO: Implement remaining pieces

Scope::Scope(QObject* parent)
: QObject(parent),
  m_visible(false),
  m_categories(new Categories(this)),
  m_results(new DeeListModel(this))
{
    m_categories->setModel(create_categories_model(4));
    m_results->setModel(create_results_model(4, 30));

    m_categories->setResultModel(m_results);
//    m_categories->setGlobalResultModel(m_results);
}

Scope::Scope(QString const& id,
           QString const& name,
           bool visible,
           QObject* parent)
: QObject(parent),
  m_id(id),
  m_name(name),
  m_visible(visible),
  m_categories(new Categories(this)),
  m_results(new DeeListModel(this))
{
    m_categories->setModel(create_categories_model(4));
    m_results->setModel(create_results_model(4, 30));

    m_categories->setResultModel(m_results);
//    m_categories->setGlobalResultModel(m_results);
}

QString Scope::id() const {
    return m_id;
}

QString Scope::name() const {
    return m_name;
}

QString Scope::searchQuery() const {
    return m_searchQuery;
}

void Scope::setName(const QString &str) {
    if (str != m_name) {
        m_name = str;
        Q_EMIT nameChanged(m_name);
    }
}

void Scope::setSearchQuery(const QString &str) {
    if (str != m_searchQuery) {
        m_searchQuery = str;
        Q_EMIT searchQueryChanged(m_searchQuery);
    }
}

bool Scope::visible() const {
    return m_visible;
}

Categories* Scope::categories() const {
  return m_categories;
}

static const gchar * categories_model_schema[] = {
  "s", // DISPLAY_NAME
  "s", // ICON_HINT
  "s", // RENDERER_NAME
  "a{sv}" // HINTS
};


DeeModel* create_categories_model(unsigned category_count) {
    DeeModel* category_model = dee_sequence_model_new();
    dee_model_set_schema_full(category_model, categories_model_schema, G_N_ELEMENTS(categories_model_schema));

    GVariantBuilder b;
    g_variant_builder_init(&b, G_VARIANT_TYPE("a{sv}"));
    GVariant *hints = g_variant_builder_end(&b);

    for(unsigned i = 0; i < category_count; ++i)
    {
      dee_model_append(category_model,
                       ("Category "+std::to_string(i)).c_str(),
                       "gtk-apply",
                       "grid",
                       hints);
    }
    g_variant_unref(hints);
    return category_model;
}


/* Schema that is used in the DeeModel representing
   the results */
static const gchar * results_model_schema[] = {
  "s", // URI
  "s", // ICON_HINT
  "u", // CATEGORY
  "s", // MIMETYPE
  "s", // TITLE
  "s", // COMMENT
  "s", // DND_URI
  "a{sv}" // METADATA
};

static const gchar * icons[] = {
  "Applications.png",
  "Home.png",
  "Music.png",
  "People.png",
  "Videos.png",
};

DeeModel* create_results_model(unsigned category_count, unsigned result_count) {
    DeeModel* results_model = dee_sequence_model_new();
    dee_model_set_schema_full(results_model, results_model_schema, G_N_ELEMENTS(results_model_schema));

    GVariantBuilder b;
    g_variant_builder_init(&b, G_VARIANT_TYPE("a{sv}"));
    GVariant *hints = g_variant_builder_end(&b);

    for(unsigned i = 0; i < result_count; ++i)
    {
      unsigned category = i % category_count;

      dee_model_append(results_model,
                       ("uri://result."+std::to_string(i)).c_str(),
                       (shellAppDirectory() + "Dash/graphics/lensIcons/" + (icons[i%G_N_ELEMENTS(icons)])).toLatin1().data(),
                       category,
                       "application/x-desktop",
                       ("Title."+std::to_string(i)).c_str(),
                       ("Comment."+std::to_string(i)).c_str(),
                       ("uri://result."+std::to_string(i)).c_str(),
                       hints);
    }
    g_variant_unref(hints);
    return results_model;
  }

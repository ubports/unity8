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
#include "fake_scope.h"

#include <dee.h>
#include "paths.h"

#include "fake_preview.h"

static DeeModel* create_categories_model(unsigned category_count);
static DeeModel* create_results_model(unsigned category_count, unsigned result_count);

// TODO: Implement remaining pieces

Scope::Scope(QObject* parent)
    : QObject(parent)
    , m_visible(false)
    , m_searching(false)
    , m_categories(new Categories(this))
    , m_results(new DeeListModel(this))
{
    DeeModel* results_model = create_results_model(4, 30);
    m_categories->setResultModel(results_model);
    m_categories->setModel(create_categories_model(4));
    m_results->setModel(results_model);
}

Scope::Scope(QString const& id, QString const& name, bool visible, QObject* parent)
    : QObject(parent)
    , m_id(id)
    , m_name(name)
    , m_visible(visible)
    , m_searching(false)
    , m_categories(new Categories(this))
    , m_results(new DeeListModel(this))
{
    DeeModel* results_model = create_results_model(4, 30);
    m_categories->setResultModel(results_model);
    m_categories->setModel(create_categories_model(4));
    m_results->setModel(results_model);
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

QString Scope::iconHint() const {
    return m_iconHint;
}

QString Scope::description() const {
    return m_description;
}

QString Scope::searchHint() const {
    return QString("");
}

QString Scope::shortcut() const {
    return QString("");
}

bool Scope::connected() const {
    return true;
}

bool Scope::searchInProgress() const {
    return m_searching;
}

Categories* Scope::categories() const {
    return m_categories;
}

QString Scope::noResultsHint() const {
    return m_noResultsHint;
}

QString Scope::formFactor() const {
    return m_formFactor;
}

bool Scope::visible() const {
    return m_visible;
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
        Q_EMIT searchQueryChanged();
    }
}

void Scope::setFormFactor(const QString &str) {
    if (str != m_formFactor) {
        m_formFactor = str;
        Q_EMIT formFactorChanged();
    }
}

void Scope::setNoResultsHint(const QString& str) {
    if (str != m_noResultsHint) {
        m_noResultsHint = str;
        Q_EMIT noResultsHintChanged();
    }
}

void Scope::activate(const QVariant &uri, const QVariant &icon_hint, const QVariant &category,
                     const QVariant &result_type, const QVariant &mimetype, const QVariant &title,
                     const QVariant &comment, const QVariant &dnd_uri, const QVariant &metadata)
{
    Q_UNUSED(uri);
    Q_UNUSED(icon_hint);
    Q_UNUSED(category);
    Q_UNUSED(result_type);
    Q_UNUSED(mimetype);
    Q_UNUSED(title);
    Q_UNUSED(comment);
    Q_UNUSED(dnd_uri);
    Q_UNUSED(metadata);
}

void Scope::preview(const QVariant &uri, const QVariant &icon_hint, const QVariant &category,
                    const QVariant &result_type, const QVariant &mimetype, const QVariant &title,
                    const QVariant &comment, const QVariant &dnd_uri, const QVariant &metadata)
{
    Q_UNUSED(uri);
    Q_UNUSED(icon_hint);
    Q_UNUSED(category);
    Q_UNUSED(result_type);
    Q_UNUSED(mimetype);
    Q_UNUSED(title);
    Q_UNUSED(comment);
    Q_UNUSED(dnd_uri);
    Q_UNUSED(metadata);
}

static const gchar * categories_model_schema[] = {
    "s", //ID
    "s", // DISPLAY_NAME
    "s", // ICON_HINT
    "s", // RENDERER_NAME
    "a{sv}" // HINTS
};


DeeModel* create_categories_model(unsigned category_count) {
    DeeModel* category_model = dee_sequence_model_new();
    dee_model_set_schema_full(category_model, categories_model_schema, G_N_ELEMENTS(categories_model_schema));
    GVariant* hints = g_variant_new_array(g_variant_type_element(G_VARIANT_TYPE_VARDICT), NULL, 0);

    for(unsigned i = 0; i < category_count; ++i)
    {
        dee_model_append(category_model,
                         std::to_string(i).c_str(),
                         ("Category "+std::to_string(i)).c_str(),
                         "gtk-apply",
                         "grid",
                         hints);
    }
    return category_model;
}


/* Schema that is used in the DeeModel representing
   the results */
static const gchar * results_model_schema[] = {
    "s", // URI
    "s", // ICON_HINT
    "u", // CATEGORY
    "u", // RESULT_TYPE
    "s", // MIMETYPE
    "s", // TITLE
    "s", // COMMENT
    "s", // DND_URI
    "a{sv}" // METADATA
};

DeeModel* create_results_model(unsigned category_count, unsigned result_count) {
    DeeModel* results_model = dee_sequence_model_new();
    dee_model_set_schema_full(results_model, results_model_schema, G_N_ELEMENTS(results_model_schema));
    GVariant* hints = g_variant_new_array(g_variant_type_element(G_VARIANT_TYPE_VARDICT), NULL, 0);

    for(unsigned i = 0; i < result_count; ++i)
    {
        unsigned category = i % category_count;

        dee_model_append(results_model,
                         ("uri://result."+std::to_string(i)).c_str(),
                         (shellAppDirectory() + "graphics/applicationIcons/dash.png").toLatin1().data(),
                         category,
                         0,
                         "application/x-desktop",
                         ("Title."+std::to_string(i)).c_str(),
                         ("Comment."+std::to_string(i)).c_str(),
                         ("uri://result."+std::to_string(i)).c_str(),
                         hints);
    }
    return results_model;
}

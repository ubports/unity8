/*
 * Copyright (C) 2011 Canonical, Ltd.
 *
 * Authors:
 *  Florian Boucault <florian.boucault@canonical.com>
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
#include "lens.h"
#include "categories.h"

// Qt
#include <QUrl>
#include <QDebug>
#include <QtGui/QDesktopServices>

#include <libintl.h>

Lens::Lens(QObject *parent) :
    QObject(parent)
{
    m_results = new DeeListModel(this);
    m_categories = new Categories(this);

    m_categories->setResultModel(m_results);
}

QString Lens::id() const
{
    return QString::fromStdString(m_unityLens->id());
}

QString Lens::name() const
{
    return QString::fromStdString(m_unityLens->name());
}

QString Lens::iconHint() const
{
    return QString::fromStdString(m_unityLens->icon_hint());
}

QString Lens::description() const
{
    return QString::fromStdString(m_unityLens->description());
}

QString Lens::searchHint() const
{
    return QString::fromStdString(m_unityLens->search_hint());
}

bool Lens::visible() const
{
    return m_unityLens->visible();
}

QString Lens::shortcut() const
{
    return QString::fromStdString(m_unityLens->shortcut());
}

bool Lens::connected() const
{
    return m_unityLens->connected();
}

DeeListModel* Lens::results() const
{
    return m_results;
}

Categories* Lens::categories() const
{
    return m_categories;
}

Lens::ViewType Lens::viewType() const
{
    return (Lens::ViewType) m_unityLens->view_type();
}

QString Lens::searchQuery() const
{
    return m_searchQuery;
}

QString Lens::noResultsHint() const
{
    return m_noResultsHint;
}

void Lens::setViewType(const Lens::ViewType& viewType)
{
    m_unityLens->view_type = (unity::dash::ScopeViewType) viewType;
}

void Lens::setSearchQuery(const QString& search_query)
{
    /* Checking for m_searchQuery.isNull() which returns true only when the string
       has never been set is necessary because when search_query is the empty
       string ("") and m_searchQuery is the null string,
       search_query != m_searchQuery is still true.
    */
    if (m_searchQuery.isNull() || search_query != m_searchQuery) {
        m_searchQuery = search_query;
        m_unityLens->Search(search_query.toStdString(), sigc::mem_fun(this, &Lens::searchFinished));
        Q_EMIT searchQueryChanged();
    }
}

void Lens::setNoResultsHint(const QString& hint) {
    if (hint != m_noResultsHint) {
        m_noResultsHint = hint;
        Q_EMIT noResultsHintChanged();
    }
}

void Lens::activate(const QString& uri)
{
//    m_unityLens->Activate(QByteArray::fromPercentEncoding(uri.toUtf8()).constData()); FIXME pawel
}

void Lens::onActivated(unity::dash::LocalResult const& result, unity::dash::ScopeHandledType type, unity::glib::HintsMap const&)
{
    if (type == unity::dash::NOT_HANDLED) {
        fallbackActivate(QString::fromStdString(result.uri));
    }
}

void Lens::fallbackActivate(const QString& uri)
{
    /* FIXME: stripping all content before the first column because for some
              reason the lenses give uri with junk content at their beginning.
    */
    QString tweakedUri = uri;
    int firstColumnAt = tweakedUri.indexOf(":");
    tweakedUri.remove(0, firstColumnAt+1);

    /* Tries various methods to trigger a sensible action for the given 'uri'.
       If it has no understanding of the given scheme it falls back on asking
       Qt to open the uri.
    */
    QUrl url(tweakedUri);
    if (url.scheme() == "file") {
        /* Override the files place's default URI handler: we want the file
           manager to handle opening folders, not the dash.

           Ref: https://bugs.launchpad.net/upicek/+bug/689667
        */
        QDesktopServices::openUrl(url);
        return;
    }
    if (url.scheme() == "application") {
        // TODO: implement application handling
        return;
    }

    qWarning() << "FIXME: Possibly no handler for scheme: " << url.scheme();
    qWarning() << "Trying to open" << tweakedUri;
    /* Try our luck */
    QDesktopServices::openUrl(url);
}

void Lens::setUnityLens(const unity::dash::Scope::Ptr& lens)
{
    m_unityLens = lens;

    if (QString::fromStdString(m_unityLens->results()->swarm_name) == QString(":local")) {
        m_results->setModel(m_unityLens->results()->model());
    } else {
        m_results->setName(QString::fromStdString(m_unityLens->results()->swarm_name));
    }

    if (QString::fromStdString(m_unityLens->categories()->swarm_name) == QString(":local")) {
        m_categories->setModel(m_unityLens->categories()->model());
    } else {
        m_categories->setName(QString::fromStdString(m_unityLens->categories()->swarm_name));
    }

    /* Property change signals */
    m_unityLens->id.changed.connect(sigc::mem_fun(this, &Lens::idChanged));
    m_unityLens->name.changed.connect(sigc::mem_fun(this, &Lens::nameChanged));
    m_unityLens->icon_hint.changed.connect(sigc::mem_fun(this, &Lens::iconHintChanged));
    m_unityLens->description.changed.connect(sigc::mem_fun(this, &Lens::descriptionChanged));
    m_unityLens->search_hint.changed.connect(sigc::mem_fun(this, &Lens::searchHintChanged));
    m_unityLens->visible.changed.connect(sigc::mem_fun(this, &Lens::visibleChanged));
    m_unityLens->shortcut.changed.connect(sigc::mem_fun(this, &Lens::shortcutChanged));
    m_unityLens->connected.changed.connect(sigc::mem_fun(this, &Lens::connectedChanged));
    m_unityLens->results.changed.connect(sigc::mem_fun(this, &Lens::onResultsChanged));
    m_unityLens->results()->swarm_name.changed.connect(sigc::mem_fun(this, &Lens::onResultsSwarmNameChanged));
    m_unityLens->results()->model.changed.connect(sigc::mem_fun(this, &Lens::onResultsModelChanged));
    m_unityLens->categories()->model.changed.connect(sigc::mem_fun(this, &Lens::onCategoriesModelChanged));
    m_unityLens->categories.changed.connect(sigc::mem_fun(this, &Lens::onCategoriesChanged));
    m_unityLens->categories()->swarm_name.changed.connect(sigc::mem_fun(this, &Lens::onCategoriesSwarmNameChanged));
    m_unityLens->view_type.changed.connect(sigc::mem_fun(this, &Lens::onViewTypeChanged));

    /* Signals forwarding */
    connect(this, SIGNAL(searchFinished(const std::string &, unity::glib::HintsMap const &, unity::glib::Error const &)), SLOT(onSearchFinished(const std::string &, unity::glib::HintsMap const &)));

    /* FIXME: signal should be forwarded instead of calling the handler directly */
    m_unityLens->activated.connect(sigc::mem_fun(this, &Lens::onActivated));

    /* Synchronize local states with m_unityLens right now and whenever
       m_unityLens becomes connected */
    /* FIXME: should emit change notification signals for all properties */
    connect(this, SIGNAL(connectedChanged(bool)), SLOT(synchronizeStates()));
    synchronizeStates();
}

unity::dash::Scope::Ptr Lens::unityLens() const
{
    return m_unityLens;
}

void Lens::synchronizeStates()
{
    if (connected()) {
        /* Forward local states to m_unityLens */
        if (!m_searchQuery.isNull()) {
            m_unityLens->Search(m_searchQuery.toStdString());
        }
    }
}

void Lens::onResultsSwarmNameChanged(const std::string& /* swarm_name */)
{
    m_results->setName(QString::fromStdString(m_unityLens->results()->swarm_name));
}

void Lens::onResultsChanged(const unity::dash::Results::Ptr& /* results */)
{
    m_results->setName(QString::fromStdString(m_unityLens->results()->swarm_name));
}

void Lens::onResultsModelChanged(unity::glib::Object<DeeModel> model)
{
    m_results->setModel(m_unityLens->results()->model());
}

void Lens::onCategoriesSwarmNameChanged(const std::string& /* swarm_name */)
{
    m_categories->setName(QString::fromStdString(m_unityLens->categories()->swarm_name));
}

void Lens::onCategoriesChanged(const unity::dash::Categories::Ptr& /* categories */)
{
    qWarning() << "categories changed!";
    m_categories->setName(QString::fromStdString(m_unityLens->categories()->swarm_name));
}

void Lens::onCategoriesModelChanged(unity::glib::Object<DeeModel> model)
{
    qWarning() << "categories model changed!";
    m_categories->setModel(model);
}

void Lens::onViewTypeChanged(unity::dash::ScopeViewType viewType)
{
    Q_EMIT viewTypeChanged( (Lens::ViewType) viewType);
}

void Lens::onSearchFinished(const std::string &query, unity::glib::HintsMap const &hints)
{
    QString hint;

    qWarning() << "Result count:" << id() << m_unityLens->results()->count() <<  QString::fromStdString(m_unityLens->results()->swarm_name) << m_categories->rowCount();
    if (!m_unityLens->results()->count()) {
        unity::glib::HintsMap::const_iterator it = hints.find("no-results-hint");
        if (it != hints.end()) {
            hint = QString::fromStdString(it->second.GetString());
        } else {
            hint = QString::fromUtf8(dgettext("unity", "Sorry, there is nothing that matches your search."));
        }
    }

    setNoResultsHint(hint);
}

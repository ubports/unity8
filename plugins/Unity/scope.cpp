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
#include "scope.h"
#include "categories.h"

// Qt
#include <QUrl>
#include <QDebug>
#include <QtGui/QDesktopServices>

#include <libintl.h>

Scope::Scope(QObject *parent) :
    QObject(parent)
{
    m_categories.reset(new Categories(this));
}

QString Scope::id() const
{
    return QString::fromStdString(m_unityScope->id());
}

QString Scope::name() const
{
    return QString::fromStdString(m_unityScope->name());
}

QString Scope::iconHint() const
{
    return QString::fromStdString(m_unityScope->icon_hint());
}

QString Scope::description() const
{
    return QString::fromStdString(m_unityScope->description());
}

QString Scope::searchHint() const
{
    return QString::fromStdString(m_unityScope->search_hint());
}

bool Scope::visible() const
{
    return m_unityScope->visible();
}

QString Scope::shortcut() const
{
    return QString::fromStdString(m_unityScope->shortcut());
}

bool Scope::connected() const
{
    return m_unityScope->connected();
}

Categories* Scope::categories() const
{
    return m_categories.get();
}

QString Scope::searchQuery() const
{
    return m_searchQuery;
}

QString Scope::noResultsHint() const
{
    return m_noResultsHint;
}

QString Scope::formFactor() const
{
    return m_formFactor;
}

void Scope::setSearchQuery(const QString& search_query)
{
    /* Checking for m_searchQuery.isNull() which returns true only when the string
       has never been set is necessary because when search_query is the empty
       string ("") and m_searchQuery is the null string,
       search_query != m_searchQuery is still true.
    */
    if (m_searchQuery.isNull() || search_query != m_searchQuery) {
        m_searchQuery = search_query;
        m_unityScope->Search(search_query.toStdString(), sigc::mem_fun(this, &Scope::searchFinished));
        Q_EMIT searchQueryChanged();
    }
}

void Scope::setNoResultsHint(const QString& hint) {
    if (hint != m_noResultsHint) {
        m_noResultsHint = hint;
        Q_EMIT noResultsHintChanged();
    }
}

void Scope::setFormFactor(const QString& form_factor) {
    if (form_factor != m_formFactor) {
        m_formFactor = form_factor;
        if (m_unityScope) {
            m_unityScope->form_factor = m_formFactor.toStdString();
        }
        Q_EMIT formFactorChanged();
    }
}

void Scope::activate(const QString& /*uri*/)
{
    // TODO:
    // we need to create unity::dash::LocalResult (see UnityCore/Result.h) and pass it to Activate;
    // this requires entire row from the model, so we need row index rather than uri.
    // m_unityScope->Activate(QByteArray::fromPercentEncoding(uri.toUtf8()).constData());
}

void Scope::onActivated(unity::dash::LocalResult const& result, unity::dash::ScopeHandledType type, unity::glib::HintsMap const&)
{
    if (type == unity::dash::NOT_HANDLED) {
        fallbackActivate(QString::fromStdString(result.uri));
    }
}

void Scope::fallbackActivate(const QString& uri)
{
    /* FIXME: stripping all content before the first column because for some
              reason the scopes give uri with junk content at their beginning.
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

void Scope::setUnityScope(const unity::dash::Scope::Ptr& scope)
{
    m_unityScope = scope;

    m_categories->setUnityScope(m_unityScope);

    m_unityScope->form_factor = m_formFactor.toStdString();
    /* Property change signals */
    m_unityScope->id.changed.connect(sigc::mem_fun(this, &Scope::idChanged));
    m_unityScope->name.changed.connect(sigc::mem_fun(this, &Scope::nameChanged));
    m_unityScope->icon_hint.changed.connect(sigc::mem_fun(this, &Scope::iconHintChanged));
    m_unityScope->description.changed.connect(sigc::mem_fun(this, &Scope::descriptionChanged));
    m_unityScope->search_hint.changed.connect(sigc::mem_fun(this, &Scope::searchHintChanged));
    m_unityScope->visible.changed.connect(sigc::mem_fun(this, &Scope::visibleChanged));
    m_unityScope->shortcut.changed.connect(sigc::mem_fun(this, &Scope::shortcutChanged));
    m_unityScope->connected.changed.connect(sigc::mem_fun(this, &Scope::connectedChanged));
    /* Signals forwarding */
    connect(this, SIGNAL(searchFinished(const std::string &, unity::glib::HintsMap const &, unity::glib::Error const &)), SLOT(onSearchFinished(const std::string &, unity::glib::HintsMap const &)));

    /* FIXME: signal should be forwarded instead of calling the handler directly */
    m_unityScope->activated.connect(sigc::mem_fun(this, &Scope::onActivated));

    /* Synchronize local states with m_unityScope right now and whenever
       m_unityScope becomes connected */
    /* FIXME: should emit change notification signals for all properties */
    connect(this, SIGNAL(connectedChanged(bool)), SLOT(synchronizeStates()));
    synchronizeStates();
}

unity::dash::Scope::Ptr Scope::unityScope() const
{
    return m_unityScope;
}

void Scope::synchronizeStates()
{
    if (connected()) {
        /* Forward local states to m_unityScope */
        if (!m_searchQuery.isNull()) {
            m_unityScope->Search(m_searchQuery.toStdString());
        }
    }
}

void Scope::onSearchFinished(const std::string& /* query */, unity::glib::HintsMap const &hints)
{
    QString hint;

    if (!m_unityScope->results()->count()) {
        unity::glib::HintsMap::const_iterator it = hints.find("no-results-hint");
        if (it != hints.end()) {
            hint = QString::fromStdString(it->second.GetString());
        } else {
            hint = QString::fromUtf8(dgettext("unity", "Sorry, there is nothing that matches your search."));
        }
    }

    setNoResultsHint(hint);
}

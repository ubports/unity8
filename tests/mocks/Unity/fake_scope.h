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

#ifndef FAKE_SCOPE_H
#define FAKE_SCOPE_H

// Qt
#include <QObject>
#include "fake_categories.h"

class Preview;

class Scope : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(QString iconHint READ iconHint NOTIFY iconHintChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(QString searchHint READ searchHint NOTIFY searchHintChanged)
    Q_PROPERTY(bool searchInProgress READ searchInProgress NOTIFY searchInProgressChanged)
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
    Q_PROPERTY(QString shortcut READ shortcut NOTIFY shortcutChanged)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(Categories* categories READ categories NOTIFY categoriesChanged)

    Q_PROPERTY(QString searchQuery READ searchQuery WRITE setSearchQuery NOTIFY searchQueryChanged)
    Q_PROPERTY(QString noResultsHint READ noResultsHint WRITE setNoResultsHint NOTIFY noResultsHintChanged)
    Q_PROPERTY(QString formFactor READ formFactor WRITE setFormFactor NOTIFY formFactorChanged)
    Q_PROPERTY(bool isActive READ isActive WRITE setActive NOTIFY isActiveChanged)

public:
    Scope(QObject* parent = 0);
    Scope(QString const& id, QString const& name, bool visible, QObject* parent = 0);

    /* getters */
    QString id() const;
    QString name() const;
    QString iconHint() const;
    QString description() const;
    QString searchHint() const;
    bool visible() const;
    QString shortcut() const;
    bool connected() const;
    bool searchInProgress() const;
    Categories* categories() const;
    QString searchQuery() const;
    QString noResultsHint() const;
    QString formFactor() const;
    bool isActive() const;

    /* setters */
    void setName(const QString& name);
    void setSearchQuery(const QString& search_query);
    void setNoResultsHint(const QString& hint);
    void setFormFactor(const QString& form_factor);
    void setActive(const bool);

    Q_INVOKABLE void activate(const QVariant &uri, const QVariant &icon_hint, const QVariant &category,
                              const QVariant &result_type, const QVariant &mimetype, const QVariant &title,
                              const QVariant &comment, const QVariant &dnd_uri, const QVariant &metadata);
    Q_INVOKABLE void preview(const QVariant &uri, const QVariant &icon_hint, const QVariant &category,
                              const QVariant &result_type, const QVariant &mimetype, const QVariant &title,
                              const QVariant &comment, const QVariant &dnd_uri, const QVariant &metadata);

Q_SIGNALS:
    void idChanged(const QString&);
    void nameChanged(const QString&);
    void iconHintChanged(const QString&);
    void descriptionChanged(const QString&);
    void searchHintChanged(const QString&);
    void searchInProgressChanged();
    void visibleChanged(bool);
    void shortcutChanged(const QString&);
    void connectedChanged(bool);
    void categoriesChanged();
    void searchQueryChanged();
    void noResultsHintChanged();
    void formFactorChanged();
    void isActiveChanged();

    // signals triggered by activate(..) or preview(..) requests.
    void previewReady(Preview *preview);
    void activateApplication(const QString &desktop);
    void showDash();
    void hideDash();

protected:

    QString m_id;
    QString m_iconHint;
    QString m_description;
    QString m_name;
    QString m_searchQuery;
    QString m_noResultsHint;
    QString m_formFactor;
    bool m_visible;
    bool m_searching;
    bool m_isActive;

    Categories* m_categories;
    DeeListModel* m_results;
};

#endif // FAKE_SCOPE_H

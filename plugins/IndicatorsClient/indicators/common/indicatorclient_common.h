/*
 * Copyright 2013 Canonical Ltd.
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation; version 3.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 *
 * Authors:
 *      Renato Araujo Oliveira Filho <renato@canonical.com>
 *      Nick Dedekind <nick.dedekind@canonical.com>
 */

#ifndef INDICATORCLIENT_COMMON_H
#define INDICATORCLIENT_COMMON_H

#include <indicatorclientinterface.h>
#include <QObject>

class QDBusActionGroup;
class QDBusMenuModel;
class QStateAction;

class IndicatorClientCommon : public QObject, public IndicatorClientInterface
{
    Q_OBJECT
    Q_PROPERTY(QString identifier READ identifier NOTIFY identifierChanged)
    Q_PROPERTY(QString title READ title NOTIFY titleChanged)
    Q_PROPERTY(QString label READ label NOTIFY labelChanged)
    Q_PROPERTY(QString description READ description NOTIFY descriptionChanged)
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
    Q_PROPERTY(int priority READ priority NOTIFY priorityChanged)

public:
    IndicatorClientCommon(QObject *parent = 0);
    ~IndicatorClientCommon();

    void init(const QSettings& settings);
    void shutdown();

    QString identifier() const;
    QString title() const;
    bool visible() const;
    QString description() const;
    QString label() const;
    int priority() const;

    QUrl iconComponentSource() const;
    QUrl pageComponentSource() const;
    PropertiesMap initialProperties();

Q_SIGNALS:
    void identifierChanged(const QString &identifier);
    void titleChanged(const QString &title);
    void visibleChanged(bool visible);
    void descriptionChanged(const QString &description);
    void labelChanged(const QString &label);
    void priorityChanged(int priority);

protected:
    PropertiesMap m_initialProperties;

    void setId(const QString &id);
    void setTitle(const QString &title);
    void setDescription(const QString &description);
    void setVisible(bool visible);
    void setLabel(const QString &title);
    void setPriority(int priority);

private:
    QString m_identifier;
    QString m_title;
    QString m_description;
    QString m_label;
    bool m_visible;
    int m_priority;
};

#endif // INDICATORCLIENT_COMMON_H

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
    Q_PROPERTY(QUrl icon READ icon NOTIFY iconChanged)
    Q_PROPERTY(QString accessibleName READ accessibleName NOTIFY accessibleNameChanged)
    Q_PROPERTY(bool visible READ visible NOTIFY visibleChanged)
    Q_PROPERTY(int priority READ priority NOTIFY priorityChanged)

public:
    IndicatorClientCommon(QObject *parent = 0);
    ~IndicatorClientCommon();

    void init(const QSettings& settings);
    void shutdown();

    QString identifier() const;
    QUrl icon() const;
    QString title() const;
    bool visible() const;
    QString description() const;
    QString accessibleName() const;
    QString label() const;
    int priority() const;

    QQmlComponent *component(QQmlEngine *engine, QObject *parent=0);
    PropertiesMap initialProperties();
    WidgetsMap widgets();

Q_SIGNALS:
    void identifierChanged(const QString &identifier);
    void iconChanged(const QUrl &icon);
    void titleChanged(const QString &title);
    void visibleChanged(bool visible);
    void descriptionChanged(const QString &description);
    void accessibleNameChanged(const QString &assesibleName);
    void labelChanged(const QString &label);
    void priorityChanged(int priority);

protected:
    PropertiesMap m_initialProperties;

    void setId(const QString &id);
    void setIcon(const QUrl &icon);
    void setTitle(const QString &title);
    void setDescription(const QString &description);
    void setVisible(bool visible);
    void setAccessibleName(const QString &accessibleName);
    void setLabel(const QString &title);
    void setPriority(int priority);
    virtual bool parseRootElement(const QString &type, QMap<int, QVariant> data);
    virtual QQmlComponent *createComponent(QQmlEngine *engine, QObject *parent=0) const;
    QDBusActionGroup *actionGroup() const;

private Q_SLOTS:
    void onModelChanged();
    void updateState(const QVariant &state);

private:
    QString m_identifier;
    QUrl m_icon;
    QString m_title;
    QString m_description;
    QString m_accessibleName;
    QString m_label;
    bool m_visible;
    int m_priority;
    QDBusMenuModel *m_model;
    QDBusActionGroup *m_actionGroup;
    QStateAction *m_action;
    QQmlComponent *m_component;
};

#endif // INDICATORCLIENT_COMMON_H

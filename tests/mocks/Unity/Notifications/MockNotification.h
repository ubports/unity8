/*
 * Copyright 2015 Canonical Ltd.
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
 *      Mirco Mueller <mirco.mueller@canonical.com>
 */

#ifndef MOCK_NOTIFICATION_H
#define MOCK_NOTIFICATION_H

#include "MockActionModel.h"
#include <QObject>
#include <QString>
#include <QStringList>
#include <QScopedPointer>

struct MockNotificationPrivate;

class MockNotification : public QObject {
    Q_OBJECT
    Q_ENUMS(Type Urgency)
    Q_PROPERTY(QString summary READ getSummary WRITE setSummary NOTIFY summaryChanged)
    Q_PROPERTY(QString body READ getBody WRITE setBody NOTIFY bodyChanged)
    Q_PROPERTY(int nid READ getID WRITE setID NOTIFY idChanged)
    Q_PROPERTY(int value READ getValue WRITE setValue NOTIFY valueChanged)
    Q_PROPERTY(QString icon READ getIcon WRITE setIcon NOTIFY iconChanged)
    Q_PROPERTY(QString secondaryIcon READ getSecondaryIcon WRITE setSecondaryIcon NOTIFY secondaryIconChanged)
    Q_PROPERTY(Type type READ getType WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(QStringList rawActions READ rawActions WRITE setActions)
    Q_PROPERTY(ActionModel* actions READ getActions NOTIFY actionsChanged)
    Q_PROPERTY(QVariantMap hints READ getHints WRITE setHints NOTIFY hintsChanged)
    Q_PROPERTY(bool fullscreen READ fullscreen WRITE setFullscreen NOTIFY fullscreenChanged)  // only in mock

private:
    QScopedPointer<MockNotificationPrivate> p;

public:
    enum Urgency { Low, Normal, Critical };
    enum Type { PlaceHolder, Confirmation, Ephemeral, Interactive, SnapDecision };

Q_SIGNALS:
    void summaryChanged(const QString &summary);
    void bodyChanged(const QString &body);
    void idChanged(const int id);
    void valueChanged(int value);
    void iconChanged(const QString &icon);
    void secondaryIconChanged(const QString &secondaryIcon);
    void typeChanged(Type type);
    void actionsChanged(const QStringList &actions);
    void hintsChanged(const QVariantMap& hints);

    void dataChanged(int nid);
    void completed(int nid);
    void actionInvoked(const QString &action);

    void fullscreenChanged(bool fullscreen);

public:
    MockNotification(QObject *parent=nullptr);
    virtual ~MockNotification();

    QString getSummary() const;
    void setSummary(const QString &summary);
    QString getBody() const;
    void setBody(const QString &body);
    int getID() const;
    void setID(const int id);
    int getValue() const;
    void setValue(int value);
    QString getIcon() const;
    void setIcon(const QString &icon);
    QString getSecondaryIcon() const;
    void setSecondaryIcon(const QString &secondaryIcon);
    Type getType() const;
    void setType(Type type);
    ActionModel* getActions() const;
    QStringList rawActions() const;
    void setActions(const QStringList &actions);
    QVariantMap getHints() const;
    void setHints(const QVariantMap& hints);
    bool fullscreen() const;
    void setFullscreen(bool fullscreen);

    Q_INVOKABLE void invokeAction(const QString &action);
    Q_INVOKABLE void close();
};

#endif // MOCK_NOTIFICATION_H

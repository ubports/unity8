/*
 * Copyright (C) 2013-2014 Canonical, Ltd.
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

#ifndef APPLICATION_H
#define APPLICATION_H

#include "SurfaceManager.h"
#include "MirSurfaceItemModel.h"

#include <QObject>

class QQuickItem;
class MirSurfaceItem;

// unity-api
#include <unity/shell/application/ApplicationInfoInterface.h>

using namespace unity::shell::application;

class ApplicationInfo : public ApplicationInfoInterface {
    Q_OBJECT

    Q_PROPERTY(bool fullscreen READ fullscreen WRITE setFullscreen NOTIFY fullscreenChanged)
    Q_PROPERTY(MirSessionItem* session READ session NOTIFY sessionChanged)

    // Only exists in this fake implementation

    // whether the test code will explicitly control the creation of the application surface
    Q_PROPERTY(bool manualSessionCreation READ manualSessionCreation WRITE setManualSessionCreation NOTIFY manualSessionCreationChanged)

public:
    ApplicationInfo(const QString &appId, QObject *parent = NULL);
    ApplicationInfo(QObject *parent = NULL);
    ~ApplicationInfo();

     void setIconId(const QString &iconId);
    void setScreenshotId(const QString &screenshotId);

    QString appId() const override { return m_appId; }

    void setName(const QString &value);
    QString name() const override { return m_name; }

    QString comment() const override { return QString(); }

    QUrl icon() const override { return m_icon; }

    void setStage(Stage value);
    Stage stage() const override { return m_stage; }

    Q_INVOKABLE void setState(State value);
    State state() const override { return m_state; }

    void setFocused(bool value);
    bool focused() const override { return m_focused; }

    QString screenshot() const { return m_screenshotFileName; }

    void setFullscreen(bool value);
    bool fullscreen() const { return m_fullscreen; }

    bool manualSessionCreation() const { return m_manualSessionCreation; }
    void setManualSessionCreation(bool value);

public:
    void setSession(MirSessionItem* session);
    MirSessionItem* session() const { return m_session; }

Q_SIGNALS:
    void sessionChanged(MirSessionItem*);
    void fullscreenChanged(bool value);
    void manualSessionCreationChanged(bool value);

public Q_SLOTS:
    Q_INVOKABLE void createSession();

private:
    void setIcon(const QUrl &value);

    QString m_screenshotFileName;

    QString m_appId;
    QString m_name;
    QUrl m_icon;
    Stage m_stage;
    State m_state;
    bool m_focused;
    bool m_fullscreen;

    QQuickItem *m_parentItem;
    MirSessionItem* m_session;

    bool m_manualSessionCreation;
};

Q_DECLARE_METATYPE(ApplicationInfo*)

#endif  // APPLICATION_H

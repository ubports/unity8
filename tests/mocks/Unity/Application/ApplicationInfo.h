/*
 * Copyright (C) 2013-2015 Canonical, Ltd.
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

#include <QObject>

class MirSurface;
class Session;

// unity-api
#include <unity/shell/application/ApplicationInfoInterface.h>

using namespace unity::shell::application;

class ApplicationInfo : public ApplicationInfoInterface {
    Q_OBJECT

    Q_PROPERTY(bool fullscreen READ fullscreen WRITE setFullscreen NOTIFY fullscreenChanged)
    Q_PROPERTY(Session* session READ session NOTIFY sessionChanged)

    // Only exists in this fake implementation

    // whether the test code will explicitly control the creation of the application surface
    Q_PROPERTY(bool manualSurfaceCreation READ manualSurfaceCreation WRITE setManualSurfaceCreation NOTIFY manualSurfaceCreationChanged)

public:
    ApplicationInfo(QObject *parent = nullptr);
    ApplicationInfo(const QString &appId, QObject *parent = nullptr);
    ~ApplicationInfo();

    RequestedState requestedState() const override;
    void setRequestedState(RequestedState) override;

    void setIconId(const QString &iconId);
    void setScreenshotId(const QString &screenshotId);

    void setAppId(const QString &value) { m_appId = value; }
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

    QString splashTitle() const override { return QString(); }
    QUrl splashImage() const override { return QUrl(); }
    bool splashShowHeader() const override { return false; }
    QColor splashColor() const override { return QColor(0,0,0,0); }
    QColor splashColorHeader() const override { return QColor(0,0,0,0); }
    QColor splashColorFooter() const override { return QColor(0,0,0,0); }

    QString screenshot() const { return m_screenshotFileName; }

    void setFullscreen(bool value);
    bool fullscreen() const { return m_fullscreen; }

    Qt::ScreenOrientations supportedOrientations() const override;
    void setSupportedOrientations(Qt::ScreenOrientations orientations);

    bool rotatesWindowContents() const override;
    void setRotatesWindowContents(bool value);

    bool manualSurfaceCreation() const { return m_manualSurfaceCreation; }
    void setManualSurfaceCreation(bool value);

    bool isTouchApp() const override;
    void setIsTouchApp(bool isTouchApp); // only in mock

public:
    void setSession(Session* session);
    Session* session() const { return m_session; }

Q_SIGNALS:
    void sessionChanged(Session*);
    void fullscreenChanged(bool value);
    void manualSurfaceCreationChanged(bool value);

public Q_SLOTS:
    Q_INVOKABLE void createSession();
    Q_INVOKABLE void destroySession();

private Q_SLOTS:
    void onSessionSurfaceChanged(MirSurface*);

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
    Session* m_session;
    Qt::ScreenOrientations m_supportedOrientations;
    bool m_rotatesWindowContents;
    RequestedState m_requestedState;
    bool m_isTouchApp;

    bool m_manualSurfaceCreation;
};

Q_DECLARE_METATYPE(ApplicationInfo*)

#endif  // APPLICATION_H

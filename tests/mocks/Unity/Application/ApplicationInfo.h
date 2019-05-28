/*
 * Copyright (C) 2013-2016 Canonical, Ltd.
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

// unity-api
#include <unity/shell/application/ApplicationInfoInterface.h>
#include <unity/shell/application/Mir.h>

#include "MirSurfaceListModel.h"

#include <QList>
#include <QTimer>
#include <QUrl>

using namespace unity::shell::application;

class ApplicationInfo : public ApplicationInfoInterface {
    Q_OBJECT

    // whether the test code will explicitly control the creation of the application surface
    // Only exists in this mock
    Q_PROPERTY(bool manualSurfaceCreation READ manualSurfaceCreation WRITE setManualSurfaceCreation NOTIFY manualSurfaceCreationChanged)

    // Only exists in this mock
    Q_PROPERTY(QString screenshot READ screenshot CONSTANT)

public:
    ApplicationInfo(QObject *parent = nullptr);
    ApplicationInfo(const QString &appId, QObject *parent = nullptr);
    ~ApplicationInfo();

    Q_INVOKABLE void createPromptSurface();

    RequestedState requestedState() const override;
    void setRequestedState(RequestedState) override;

    void setIconId(const QString &iconId);
    void setScreenshotId(const QString &screenshotId);
    void setQmlFilename(const QString &);

    void setAppId(const QString &value) { m_appId = value; }
    QString appId() const override { return m_appId; }

    void setName(const QString &value);
    QString name() const override { return m_name; }

    QString comment() const override { return QString(); }

    QUrl icon() const override { return m_icon; }

    Q_INVOKABLE void setState(State value);
    State state() const override { return m_state; }

    bool focused() const override;

    QString splashTitle() const override { return QString(); }
    QUrl splashImage() const override { return QUrl(); }
    bool splashShowHeader() const override { return false; }
    QColor splashColor() const override { return QColor(0,0,0,0); }
    QColor splashColorHeader() const override { return QColor(0,0,0,0); }
    QColor splashColorFooter() const override { return QColor(0,0,0,0); }

    QString screenshot() const { return m_screenshotFileName; }

    void setFullscreen(bool value);
    bool fullscreen() const;

    Qt::ScreenOrientations supportedOrientations() const override;
    void setSupportedOrientations(Qt::ScreenOrientations orientations);

    bool rotatesWindowContents() const override;
    void setRotatesWindowContents(bool value);

    bool manualSurfaceCreation() const { return m_manualSurfaceCreation; }
    void setManualSurfaceCreation(bool value);

    bool isTouchApp() const override;
    void setIsTouchApp(bool isTouchApp); // only in mock

    bool exemptFromLifecycle() const override;
    void setExemptFromLifecycle(bool) override;

    QSize initialSurfaceSize() const override;
    void setInitialSurfaceSize(const QSize &size) override;

    Q_INVOKABLE void setShellChrome(Mir::ShellChrome shellChrome);

    MirSurfaceListInterface* surfaceList() const override { return m_surfaceList; }
    MirSurfaceListInterface* promptSurfaceList() const override { return m_promptSurfaceList; }
    int surfaceCount() const override { return m_surfaceList->count(); }

    //////
    // internal mock stuff
    void close() override;
    void requestFocus();

Q_SIGNALS:
    void fullscreenChanged(bool value);
    void manualSurfaceCreationChanged(bool value);
    void closed();

public Q_SLOTS:
    Q_INVOKABLE void createSurface();

private Q_SLOTS:
    void onSurfaceCountChanged();

private:
    void setIcon(const QUrl &value);

    QString m_screenshotFileName;

    QString m_appId;
    QString m_name;
    QUrl m_icon;
    State m_state{Stopped};
    bool m_fullscreen{false};
    Qt::ScreenOrientations m_supportedOrientations{Qt::PortraitOrientation |
            Qt::LandscapeOrientation |
            Qt::InvertedPortraitOrientation |
            Qt::InvertedLandscapeOrientation};
    bool m_rotatesWindowContents{false};
    RequestedState m_requestedState{RequestedRunning};
    bool m_isTouchApp{true};
    bool m_exemptFromLifecycle{false};
    QSize m_initialSurfaceSize;
    MirSurfaceListModel *m_surfaceList;
    MirSurfaceListModel *m_promptSurfaceList;
    int m_liveSurfaceCount{0};
    QTimer m_surfaceCreationTimer;
    QList<MirSurface*> m_closingSurfaces;
    bool m_manualSurfaceCreation{false};
    Mir::ShellChrome m_shellChrome{Mir::NormalChrome};
    QUrl m_qmlFilePath;
};

Q_DECLARE_METATYPE(ApplicationInfo*)

#endif  // APPLICATION_H

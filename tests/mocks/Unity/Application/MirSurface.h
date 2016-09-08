/*
 * Copyright (C) 2015-2016 Canonical, Ltd.
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

#ifndef MOCK_MIR_SURFACE_H
#define MOCK_MIR_SURFACE_H

#include <QObject>
#include <QTimer>
#include <QUrl>
#include <QHash>

// unity-api
#include <unity/shell/application/MirFocusControllerInterface.h>
#include <unity/shell/application/MirSurfaceInterface.h>

#include "MirSurfaceListModel.h"

class MirSurface;

class MirFocusController : public unity::shell::application::MirFocusControllerInterface
{
    Q_OBJECT
public:
    MirFocusController();
    virtual ~MirFocusController();
    static MirFocusController* instance();

    void setFocusedSurface(unity::shell::application::MirSurfaceInterface *surface) override;
    unity::shell::application::MirSurfaceInterface* focusedSurface() const override { return m_focusedSurface; }
    unity::shell::application::MirSurfaceInterface* previouslyFocusedSurface() { return m_previouslyFocusedSurface; }
    void clear();
private:
    static MirFocusController *m_instance;
    unity::shell::application::MirSurfaceInterface* m_previouslyFocusedSurface{nullptr};
    unity::shell::application::MirSurfaceInterface* m_focusedSurface{nullptr};
};

class MirSurface : public unity::shell::application::MirSurfaceInterface
{
    Q_OBJECT

    ////
    // for use in qml tests
    Q_PROPERTY(int width READ width NOTIFY widthChanged)
    Q_PROPERTY(int height READ height NOTIFY heightChanged)
    Q_PROPERTY(bool activeFocus READ activeFocus NOTIFY activeFocusChanged)
    Q_PROPERTY(bool slowToResize READ isSlowToResize WRITE setSlowToResize NOTIFY slowToResizeChanged)

public:
    MirSurface(const QString& name,
            Mir::Type type,
            Mir::State state,
            const QUrl& screenshot,
            const QUrl &qmlFilePath = QUrl());
    virtual ~MirSurface();

    ////
    // unity.shell.application.MirSurface

    Mir::Type type() const override;

    QString name() const override;

    QString persistentId() const override;

    QSize size() const override { return QSize(width(),height()); }
    void resize(int width, int height) override;
    void resize(const QSize &size) override { resize(size.width(), size.height()); }


    Mir::State state() const override;
    Q_INVOKABLE void setState(Mir::State) override;

    bool live() const override;

    bool visible() const override;

    Mir::OrientationAngle orientationAngle() const override;
    void setOrientationAngle(Mir::OrientationAngle) override;

    int minimumWidth() const override { return m_minimumWidth; }
    int minimumHeight() const override { return m_minimumHeight; }
    int maximumWidth() const override { return m_maximumWidth; }
    int maximumHeight() const override { return m_maximumHeight; }
    int widthIncrement() const override { return m_widthIncrement; }
    int heightIncrement() const override { return m_heightIncrement; }

    void setKeymap(const QString &) override;
    QString keymap() const override;

    Mir::ShellChrome shellChrome() const override;

    bool focused() const override;
    QRect inputBounds() const override;

    Q_INVOKABLE void requestFocus() override;

    Q_INVOKABLE void close() override;

    Q_INVOKABLE void raise() override;

    ////
    // API for tests

    Q_INVOKABLE void setLive(bool live);
    Q_INVOKABLE void setShellChrome(Mir::ShellChrome shellChrome);

    int width() const;
    int height() const;

    bool isSlowToResize() const;
    void setSlowToResize(bool value);

    Q_INVOKABLE void setMinimumWidth(int);
    Q_INVOKABLE void setMaximumWidth(int);
    Q_INVOKABLE void setMinimumHeight(int);
    Q_INVOKABLE void setMaximumHeight(int);
    Q_INVOKABLE void setWidthIncrement(int);
    Q_INVOKABLE void setHeightIncrement(int);

    Q_INVOKABLE virtual void setInputBounds(const QRect &boundsRect);

    /////
    // internal mock stuff

    QUrl qmlFilePath() const;

    QUrl screenshotUrl() const;
    void setScreenshotUrl(QUrl);

    bool activeFocus() const;
    void setActiveFocus(bool);

    void registerView(qintptr viewId);
    void unregisterView(qintptr viewId);
    void setViewVisibility(qintptr viewId, bool visible);
    int viewCount() const { return m_views.count(); }

    void setFocused(bool value);

Q_SIGNALS:
    ////
    // API for tests
    void widthChanged();
    void heightChanged();
    void slowToResizeChanged();

    ////
    // internal mock stuff
    void screenshotUrlChanged(QUrl);
    void activeFocusChanged(bool);
    void raiseRequested();
    void closeRequested();

protected:
    virtual void updateInputBoundsAfterResize();

private Q_SLOTS:
    void applyDelayedResize();

private:
    void doResize(int width, int height);
    void updateVisibility();

    const QString m_name;
    const Mir::Type m_type;
    Mir::State m_state;
    Mir::OrientationAngle m_orientationAngle;

    QUrl m_screenshotUrl;
    QUrl m_qmlFilePath;
    bool m_live;
    bool m_visible;
    bool m_activeFocus;
    int m_width;
    int m_height;

    int m_minimumWidth{0};
    int m_minimumHeight{0};
    int m_maximumWidth{0};
    int m_maximumHeight{0};
    int m_widthIncrement{0};
    int m_heightIncrement{0};

    QString m_keymap;

    bool m_slowToResize;
    QTimer m_delayedResizeTimer;
    QSize m_delayedResize;
    QSize m_pendingResize;

    Mir::ShellChrome m_shellChrome;

    struct View {
        bool visible;
    };
    QHash<qintptr, View> m_views;

    QTimer m_zombieTimer;

    QRect m_inputBounds;
};

#endif // MOCK_MIR_SURFACE_H

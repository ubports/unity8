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
#include <unity/shell/application/MirSurfaceInterface.h>

#include "MirSurfaceListModel.h"

class MirSurface;

class MirSurface : public unity::shell::application::MirSurfaceInterface
{
    Q_OBJECT

    ////
    // for use in qml tests
    Q_PROPERTY(int width READ width NOTIFY widthChanged)
    Q_PROPERTY(int height READ height NOTIFY heightChanged)
    Q_PROPERTY(bool activeFocus READ activeFocus NOTIFY activeFocusChanged)
    Q_PROPERTY(bool slowToResize READ isSlowToResize WRITE setSlowToResize NOTIFY slowToResizeChanged)
    Q_PROPERTY(bool exposed READ exposed NOTIFY exposedChanged)

public:
    MirSurface(const QString& name,
            Mir::Type type,
            Mir::State state,
            MirSurface *parentSurface,
            const QUrl& screenshot,
            const QUrl &qmlFilePath = QUrl());
    virtual ~MirSurface();

    ////
    // unity.shell.application.MirSurface

    Mir::Type type() const override;

    QString name() const override;

    QString persistentId() const override;
    QString appId() const override;

    QPoint position() const override { return m_position; }

    QSize size() const override { return QSize(width(),height()); }
    void resize(int width, int height) override;
    void resize(const QSize &size) override { resize(size.width(), size.height()); }


    Mir::State state() const override;

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

    bool confinesMousePointer() const override { return false; }

    bool allowClientResize() const override { return true; }
    void setAllowClientResize(bool) override {}

    QPoint requestedPosition() const override { return m_requestedPosition; }
    void setRequestedPosition(const QPoint &) override;

    unity::shell::application::MirSurfaceInterface* parentSurface() const override;
    unity::shell::application::MirSurfaceListInterface* childSurfaceList() const override;

    Q_INVOKABLE void close() override;
    Q_INVOKABLE void activate() override;

    ////
    // API for tests

    Q_INVOKABLE void requestFocus();
    Q_INVOKABLE void setLive(bool live);
    Q_INVOKABLE void setShellChrome(Mir::ShellChrome shellChrome);

    int width() const;
    int height() const;

    bool isSlowToResize() const;
    void setSlowToResize(bool value);

    bool exposed() const { return m_exposed; }

    Q_INVOKABLE void setMinimumWidth(int);
    Q_INVOKABLE void setMaximumWidth(int);
    Q_INVOKABLE void setMinimumHeight(int);
    Q_INVOKABLE void setMaximumHeight(int);
    Q_INVOKABLE void setWidthIncrement(int);
    Q_INVOKABLE void setHeightIncrement(int);

    Q_INVOKABLE virtual void setInputBounds(const QRect &boundsRect);

    Q_INVOKABLE void openMenu(qreal x, qreal y, qreal width, qreal height);
    Q_INVOKABLE void openDialog(qreal x, qreal y, qreal width, qreal height);

    /////
    // internal mock stuff

    QUrl qmlFilePath() const;

    QUrl screenshotUrl() const;
    void setScreenshotUrl(QUrl);

    bool activeFocus() const;
    void setActiveFocus(bool);

    void registerView(qintptr viewId);
    void unregisterView(qintptr viewId);
    void setViewExposure(qintptr viewId, bool visible);
    int viewCount() const { return m_views.count(); }

    void setFocused(bool value);

    void setState(Mir::State state);

    Mir::State previousState() const { return m_previousState; }
    void setPreviousState(Mir::State state) { m_previousState = state; }

public Q_SLOTS:
    ////
    // unity.shell.application.MirSurface
    void requestState(Mir::State) override;

Q_SIGNALS:
    ////
    // API for tests
    void widthChanged();
    void heightChanged();
    void slowToResizeChanged();
    void exposedChanged(bool exposed);

    ////
    // internal mock stuff
    void screenshotUrlChanged(QUrl);
    void activeFocusChanged(bool);
    void closeRequested();
    void stateRequested(Mir::State);

protected:
    virtual void updateInputBoundsAfterResize();

private Q_SLOTS:
    void applyDelayedResize();

private:
    void doResize(int width, int height);
    void updateExposure();

    const QString m_name;
    const Mir::Type m_type;
    Mir::State m_state;
    Mir::State m_previousState{Mir::UnknownState};
    Mir::OrientationAngle m_orientationAngle;

    QUrl m_screenshotUrl;
    QUrl m_qmlFilePath;
    bool m_live;
    bool m_focused;
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
    bool m_exposed{false};

    QTimer m_zombieTimer;

    QRect m_inputBounds;

    QPoint m_position;
    QPoint m_requestedPosition;

    unity::shell::application::MirSurfaceInterface* m_parentSurface;

    MirSurfaceListModel *m_childSurfaceList;
};

#endif // MOCK_MIR_SURFACE_H

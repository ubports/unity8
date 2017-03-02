/*
 * Copyright (C) 2016-2017 Canonical, Ltd.
 *
 * This program is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3, as published by
 * the Free Software Foundation.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranties of MERCHANTABILITY,
 * SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

#include "MockScreens.h"

// qtmirserver
#include <qtmir/screen.h>

namespace {

class MockScreen : public qtmir::Screen
{
    Q_OBJECT
public:
    MockScreen()
    {
        m_sizes.append(new qtmir::ScreenMode(50, QSize(640,480)));
        m_sizes.append(new qtmir::ScreenMode(60, QSize(1280,1024)));
        m_sizes.append(new qtmir::ScreenMode(60, QSize(1440,900)));
        m_sizes.append(new qtmir::ScreenMode(60, QSize(1920,1080)));
        m_physicalSize = QSize(800,568);
    }

    qtmir::OutputId outputId() const override { return m_id; }
    bool used() const override { return m_used; }
    QString name() const override { return m_name; }
    float scale() const override { return m_scale; }
    QSizeF physicalSize() const override { return m_physicalSize; }
    qtmir::FormFactor formFactor() const override { return m_formFactor; }
    qtmir::OutputTypes outputType() const override { return m_outputType; }
    MirPowerMode powerMode() const override { return m_powerMode; }
    Qt::ScreenOrientation orientation() const override { return m_orientation; }
    QPoint position() const override { return m_position; }
    uint currentModeIndex() const override { return m_currentModeIndex; }
    bool isActive() const override { return m_active; }

    QQmlListProperty<qtmir::ScreenMode> availableModes() override {
        return QQmlListProperty<qtmir::ScreenMode>(this, m_sizes);
    }

    void setActive(bool active) override {
        if (m_active != active) {
            m_active = active;
            Q_EMIT activeChanged(m_active);
        }
    }

    QScreen* qscreen() const override { return nullptr; }

    qtmir::ScreenConfiguration *beginConfiguration() const override {
        auto config = new qtmir::ScreenConfiguration;
        config->valid = true;
        config->id = m_id;
        config->used = m_used;
        config->topLeft = m_position;
        config->currentModeIndex = m_currentModeIndex;
        config->powerMode = m_powerMode;
        config->scale = m_scale;
        config->formFactor = m_formFactor;
        return config;
    }

    bool applyConfiguration(qtmir::ScreenConfiguration *configuration) override {
        m_used = configuration->used;
        m_position = configuration->topLeft;
        m_currentModeIndex = configuration->currentModeIndex;
        m_powerMode = configuration->powerMode;
        m_scale = configuration->scale;
        m_formFactor = configuration->formFactor;
        return true;
    }

public:
    qtmir::OutputId m_id{0};
    bool m_active{false};
    bool m_used{true};
    QString m_name;
    qtmir::OutputTypes m_outputType{qtmir::Unknown};
    MirPowerMode m_powerMode{mir_power_mode_on};
    Qt::ScreenOrientation m_orientation{Qt::PrimaryOrientation};
    float m_scale{1.0};
    qtmir::FormFactor m_formFactor{qtmir::FormFactorMonitor};
    QPoint m_position;
    uint m_currentModeIndex{0};
    QList<qtmir::ScreenMode*> m_sizes;
    QSizeF m_physicalSize;
};
}

MockScreens::MockScreens()
{
    bool ok = false;
    int screenCount = qEnvironmentVariableIntValue("UNITY_MOCK_SCREEN_COUNT", &ok);
    if (!ok) screenCount = 1;
    QPoint lastPoint(0,0);
    for (int i = 0; i < screenCount; ++i) {
        auto screen = new MockScreen();
        screen->m_id = qtmir::OutputId{i};
        screen->m_active = i == 0;
        screen->m_name = QString("Monitor %1").arg(i);
        screen->m_position = QPoint(lastPoint.x(), lastPoint.y());
        screen->m_currentModeIndex = 3;
        m_mocks.append(screen);

        lastPoint.rx() += screen->m_sizes[screen->m_currentModeIndex]->size.width();
    }
}

MockScreens::~MockScreens()
{
    qDeleteAll(m_mocks);
}

QVector<qtmir::Screen *> MockScreens::screens() const
{
    return m_mocks;
}

qtmir::Screen *MockScreens::activeScreen() const
{
    Q_FOREACH(auto screen, m_mocks) {
        if (screen->isActive()) return screen;
    }
    return nullptr;
}

#include "MockScreens.moc"

#ifndef SCREEN_H
#define SCREEN_H

#include <qtmir/screen.h>
#include <QScopedPointer>

class Screen : public qtmir::Screen
{
    Q_OBJECT

public:
    Screen();

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
    QQmlListProperty<qtmir::ScreenMode> availableModes() override;
    uint currentModeIndex() const override { return m_currentModeIndex; }
    bool isActive() const override { return m_active; }
    void setActive(bool active) override;

    QScreen* qscreen() const override { return nullptr; }

    qtmir::ScreenConfiguration *beginConfiguration() const override;
    bool applyConfiguration(qtmir::ScreenConfiguration *configuration) override;

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

#endif // SCREEN_H

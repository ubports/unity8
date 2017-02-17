#ifndef SCREEN_H
#define SCREEN_H

#include <qtmir/screen.h>
#include <QScopedPointer>

class Screen : public qtmir::Screen
{
    Q_OBJECT

public:
    explicit Screen(qtmir::Screen*const wrapped);

    qtmir::OutputId outputId() const override;
    bool used() const override;
    QString name() const override;
    float scale() const override;
    QSizeF physicalSize() const override;
    qtmir::FormFactor formFactor() const override;
    qtmir::OutputTypes outputType() const override;
    MirPowerMode powerMode() const override;
    Qt::ScreenOrientation orientation() const override;
    QPoint position() const override;
    QQmlListProperty<qtmir::ScreenMode> availableModes() override;
    uint currentModeIndex() const override;
    bool isActive() const override;
    void setActive(bool active) override;

    QScreen* qscreen() const override;

    qtmir::ScreenConfiguration *beginConfiguration() const override;
    bool applyConfiguration(qtmir::ScreenConfiguration *configuration) override;

    qtmir::Screen* wrapped() const { return m_wrapped; }

private:
    qtmir::Screen*const m_wrapped;
};

#endif // SCREEN_H

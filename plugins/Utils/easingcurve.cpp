#include "easingcurve.h"


EasingCurve::EasingCurve(QObject *parent):
    QObject(parent)
{

}

QEasingCurve::Type EasingCurve::type() const
{
    return m_easingCurve.type();
}

void EasingCurve::setType(const QEasingCurve::Type &type)
{
    m_easingCurve.setType(type);
    Q_EMIT typeChanged();
}

qreal EasingCurve::period() const
{
    return m_easingCurve.period();
}

void EasingCurve::setPeriod(qreal period)
{
    m_easingCurve.setPeriod(period);
    Q_EMIT periodChanged();
}

qreal EasingCurve::progress() const
{
    return m_progress;
}

void EasingCurve::setProgress(qreal progress)
{
    if (m_progress != progress) {
        m_progress = progress;
        m_value = m_easingCurve.valueForProgress(m_progress);
        Q_EMIT progressChanged();
    }
}

qreal EasingCurve::value() const
{
    return m_value;
}

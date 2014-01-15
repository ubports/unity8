#ifndef EASINGCURVE_H
#define EASINGCURVE_H

#include <QObject>
#include <QEasingCurve>

class EasingCurve: public QObject
{
    Q_OBJECT
    Q_ENUMS(QEasingCurve::Type)
    Q_PROPERTY(QEasingCurve::Type type READ type WRITE setType NOTIFY typeChanged)
    Q_PROPERTY(qreal period READ period WRITE setPeriod NOTIFY periodChanged)
    Q_PROPERTY(qreal progress READ progress WRITE setProgress NOTIFY progressChanged)
    Q_PROPERTY(qreal value READ value NOTIFY progressChanged)

public:
    EasingCurve(QObject *parent = 0);

    QEasingCurve::Type type() const;
    void setType(const QEasingCurve::Type &type);

    qreal period() const;
    void setPeriod(qreal period);

    qreal progress() const;
    void setProgress(qreal progress);

    qreal value() const;

Q_SIGNALS:
    void typeChanged();
    void periodChanged();
    void progressChanged();

private:
    QEasingCurve m_easingCurve;
    qreal m_progress;
    qreal m_value;
};

#endif


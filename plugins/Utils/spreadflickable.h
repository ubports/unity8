#include <QQuickItem>
#include <private/qquickflickable_p.h>

class SpreadFlickable: public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(qreal contentWidth READ contentWidth WRITE setContentWidth NOTIFY contentWidthChanged)
    Q_PROPERTY(qreal contentX READ contentX WRITE setContentX NOTIFY contentXChanged)

public:
    SpreadFlickable(QQuickItem *parent = nullptr);

    qreal contentWidth() const;
    void setContentWidth(qreal contentWidth);

    qreal contentX() const;
    void setContentX(qreal contentX);

    bool eventFilter(QObject* /*watched*/, QEvent *event) override;

Q_SIGNALS:
    void contentWidthChanged();
    void contentXChanged();

private Q_SLOTS:
    void slotHeightChanged();
    void slotWidthChanged();

private:
    void setMousePressed(bool value);
    void setTouchPressed(bool value);

    bool m_mousePressed;
    bool m_touchPressed;

    QQuickFlickable *m_flickable;
};

#ifndef VIDEOOUTPUT_H
#define VIDEOOUTPUT_H

#include <QQuickItem>
#include <QPointer>
class QQmlComponent;

class VideoOutput : public QQuickItem
{
    Q_OBJECT
    Q_PROPERTY(QObject* source READ source WRITE setSource NOTIFY sourceChanged)
public:
    explicit VideoOutput(QQuickItem *parent = 0);

    QObject *source() const { return m_source.data(); }
    void setSource(QObject *source);

    void itemChange(ItemChange change, const ItemChangeData & value);

Q_SIGNALS:
    void sourceChanged();

protected Q_SLOTS:
    void onComponentStatusChanged(QQmlComponent::Status status);
    void updateProperties();

private:
    void createQmlContentItem();
    void printComponentErrors();

    QPointer<QObject> m_source;
    QQmlComponent* m_qmlContentComponent;
    QQuickItem* m_qmlItem;
};

#endif // VIDEOOUTPUT_H

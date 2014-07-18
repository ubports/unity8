#ifndef SURFACEMANAGER_H
#define SURFACEMANAGER_H

#include <QObject>

class MirSurfaceItem;

class SurfaceManager : public QObject
{
    Q_OBJECT
public:
    explicit SurfaceManager(QObject *parent = 0);

    static SurfaceManager *singleton();

Q_SIGNALS:
    void countChanged();
    void surfaceCreated(MirSurfaceItem *surface);
    void surfaceDestroyed(MirSurfaceItem *surface);

private:
    static SurfaceManager *the_surface_manager;

};

#endif // SURFACEMANAGER_H

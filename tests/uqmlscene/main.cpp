/****************************************************************************
**
** Copyright (C) 2013 Digia Plc and/or its subsidiary(-ies).
** Contact: http://www.qt-project.org/legal
**
** This file is part of the tools applications of the Qt Toolkit.
**
** $QT_BEGIN_LICENSE:LGPL$
** Commercial License Usage
** Licensees holding valid commercial Qt licenses may use this file in
** accordance with the commercial license agreement provided with the
** Software or, alternatively, in accordance with the terms contained in
** a written agreement between you and Digia.  For licensing terms and
** conditions see http://qt.digia.com/licensing.  For further information
** use the contact form at http://qt.digia.com/contact-us.
**
** GNU Lesser General Public License Usage
** Alternatively, this file may be used under the terms of the GNU Lesser
** General Public License version 2.1 as published by the Free Software
** Foundation and appearing in the file LICENSE.LGPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU Lesser General Public License version 2.1 requirements
** will be met: http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html.
**
** In addition, as a special exception, Digia gives you certain additional
** rights.  These rights are described in the Digia Qt LGPL Exception
** version 1.1, included in the file LGPL_EXCEPTION.txt in this package.
**
** GNU General Public License Usage
** Alternatively, this file may be used under the terms of the GNU
** General Public License version 3.0 as published by the Free Software
** Foundation and appearing in the file LICENSE.GPL included in the
** packaging of this file.  Please review the following information to
** ensure the GNU General Public License version 3.0 requirements will be
** met: http://www.gnu.org/copyleft/gpl.html.
**
**
** $QT_END_LICENSE$
**
****************************************************************************/

#include <QtCore/qdebug.h>
#include <QtCore/qabstractanimation.h>
#include <QtCore/qdir.h>
#include <QtCore/qmath.h>
#include <QtCore/qdatetime.h>

#include <QtGui/QGuiApplication>

#include <QtQml/qqml.h>
#include <QtQml/qqmlengine.h>
#include <QtQml/qqmlcomponent.h>
#include <QtQml/qqmlcontext.h>

#include <QtQuick/qquickitem.h>
#include <QtQuick/qquickview.h>

#ifdef QT_WIDGETS_LIB
#include <QtWidgets/QApplication>
#include <QtWidgets/QFileDialog>
#endif

#include <QtCore/QTranslator>
#include <QtCore/QLibraryInfo>

#ifdef QML_RUNTIME_TESTING
class RenderStatistics
{
public:
    static void updateStats();
    static void printTotalStats();
private:
    static QVector<qreal> timePerFrame;
    static QVector<int> timesPerFrames;
};

QVector<qreal> RenderStatistics::timePerFrame;
QVector<int> RenderStatistics::timesPerFrames;

void RenderStatistics::updateStats()
{
    static QTime time;
    static int frames;
    static int lastTime;

    if (frames == 0) {
        time.start();
    } else {
        int elapsed = time.elapsed();
        timesPerFrames.append(elapsed - lastTime);
        lastTime = elapsed;

        if (elapsed > 5000) {
            qreal avgtime = elapsed / (qreal) frames;
            qreal var = 0;
            for (int i = 0; i < timesPerFrames.size(); ++i) {
                qreal diff = timesPerFrames.at(i) - avgtime;
                var += diff * diff;
            }
            var /= timesPerFrames.size();

            qDebug("Average time per frame: %f ms (%i fps), std.dev: %f ms", avgtime, qRound(1000. / avgtime), qSqrt(var));

            timePerFrame.append(avgtime);
            timesPerFrames.clear();
            time.start();
            lastTime = 0;
            frames = 0;
        }
    }
    ++frames;
}

void RenderStatistics::printTotalStats()
{
    int count = timePerFrame.count();
    if (count == 0)
        return;

    qreal minTime = 0;
    qreal maxTime = 0;
    qreal avg = 0;
    for (int i = 0; i < count; ++i) {
        minTime = minTime == 0 ? timePerFrame.at(i) : qMin(minTime, timePerFrame.at(i));
        maxTime = qMax(maxTime, timePerFrame.at(i));
        avg += timePerFrame.at(i);
    }
    avg /= count;

    qDebug(" ");
    qDebug("----- Statistics -----");
    qDebug("Average time per frame: %f ms (%i fps)", avg, qRound(1000. / avg));
    qDebug("Best time per frame: %f ms (%i fps)", minTime, int(1000 / minTime));
    qDebug("Worst time per frame: %f ms (%i fps)", maxTime, int(1000 / maxTime));
    qDebug("----------------------");
    qDebug(" ");
}
#endif

struct Options
{
    Options()
        : originalQml(false)
        , originalQmlRaster(false)
        , maximized(false)
        , fullscreen(false)
        , transparent(false)
        , clip(false)
        , versionDetection(true)
        , quitImmediately(false)
        , resizeViewToRootItem(false)
        , multisample(false)
    {
    }

    QUrl file;
    bool originalQml;
    bool originalQmlRaster;
    bool maximized;
    bool fullscreen;
    bool transparent;
    bool clip;
    bool versionDetection;
    bool quitImmediately;
    bool resizeViewToRootItem;
    bool multisample;
    QString translationFile;
};

#if defined(QMLSCENE_BUNDLE)
QFileInfoList findQmlFiles(const QString &dirName)
{
    QDir dir(dirName);

    QFileInfoList ret;
    if (dir.exists()) {
        QFileInfoList fileInfos = dir.entryInfoList(QStringList() << "*.qml",
                                                    QDir::Files | QDir::AllDirs | QDir::NoDotAndDotDot);

        Q_FOREACH (QFileInfo fileInfo, fileInfos) {
            if (fileInfo.isDir())
                ret += findQmlFiles(fileInfo.filePath());
            else if (fileInfo.fileName().length() > 0 && fileInfo.fileName().at(0).isLower())
                ret.append(fileInfo);
        }
    }

    return ret;
}

static int displayOptionsDialog(Options *options)
{
    QDialog dialog;

    QFormLayout *layout = new QFormLayout(&dialog);

    QComboBox *qmlFileComboBox = new QComboBox(&dialog);
    QFileInfoList fileInfos = findQmlFiles(":/bundle") + findQmlFiles("./qmlscene-resources");

    Q_FOREACH (QFileInfo fileInfo, fileInfos)
        qmlFileComboBox->addItem(fileInfo.dir().dirName() + "/" + fileInfo.fileName(), QVariant::fromValue(fileInfo));

    QCheckBox *originalCheckBox = new QCheckBox(&dialog);
    originalCheckBox->setText("Use original QML viewer");
    originalCheckBox->setChecked(options->originalQml);

    QCheckBox *fullscreenCheckBox = new QCheckBox(&dialog);
    fullscreenCheckBox->setText("Start fullscreen");
    fullscreenCheckBox->setChecked(options->fullscreen);

    QCheckBox *maximizedCheckBox = new QCheckBox(&dialog);
    maximizedCheckBox->setText("Start maximized");
    maximizedCheckBox->setChecked(options->maximized);

    QDialogButtonBox *buttonBox = new QDialogButtonBox(QDialogButtonBox::Ok | QDialogButtonBox::Cancel,
                                                       Qt::Horizontal,
                                                       &dialog);
    QObject::connect(buttonBox, &QDialogButtonBox::accepted, &dialog, &QDialog::accept);
    QObject::connect(buttonBox, &QDialogButtonBox::rejected, &dialog, &QDialog::reject);

    layout->addRow("Qml file:", qmlFileComboBox);
    layout->addWidget(originalCheckBox);
    layout->addWidget(maximizedCheckBox);
    layout->addWidget(fullscreenCheckBox);
    layout->addWidget(buttonBox);

    int result = dialog.exec();
    if (result == QDialog::Accepted) {
        QVariant variant = qmlFileComboBox->itemData(qmlFileComboBox->currentIndex());
        QFileInfo fileInfo = variant.value<QFileInfo>();

        if (fileInfo.canonicalFilePath().startsWith(":"))
            options->file = QUrl("qrc" + fileInfo.canonicalFilePath());
        else
            options->file = QUrl::fromLocalFile(fileInfo.canonicalFilePath());
        options->originalQml = originalCheckBox->isChecked();
        options->maximized = maximizedCheckBox->isChecked();
        options->fullscreen = fullscreenCheckBox->isChecked();
    }
    return result;
}
#endif

static bool checkVersion(const QUrl &url)
{
    if (!qgetenv("QMLSCENE_IMPORT_NAME").isEmpty())
        qWarning("QMLSCENE_IMPORT_NAME is no longer supported.");

    QString fileName = url.toLocalFile();
    if (fileName.isEmpty()) {
        qWarning("qmlscene: filename required.");
        return false;
    }

    QFile f(fileName);
    if (!f.open(QFile::ReadOnly | QFile::Text)) {
        qWarning("qmlscene: failed to check version of file '%s', could not open...",
                 qPrintable(fileName));
        return false;
    }

    QRegExp quick1("^\\s*import +QtQuick +1\\.\\w*");
    QRegExp qt47("^\\s*import +Qt +4\\.7");

    QTextStream stream(&f);
    bool codeFound= false;
    while (!codeFound) {
        QString line = stream.readLine();
        if (line.contains("{")) {
            codeFound = true;
        } else {
            QString import;
            if (quick1.indexIn(line) >= 0)
                import = quick1.cap(0).trimmed();
            else if (qt47.indexIn(line) >= 0)
                import = qt47.cap(0).trimmed();

            if (!import.isNull()) {
                qWarning("qmlscene: '%s' is no longer supported.\n"
                         "Use qmlviewer to load file '%s'.",
                         qPrintable(import),
                         qPrintable(fileName));
                return false;
            }
        }
    }

    return true;
}

static void displayFileDialog(Options *options)
{
#if defined(QT_WIDGETS_LIB) && !defined(QT_NO_FILEDIALOG)
    QString fileName = QFileDialog::getOpenFileName(0, "Open QML file", QString(), "QML Files (*.qml)");
    if (!fileName.isEmpty()) {
        QFileInfo fi(fileName);
        options->file = QUrl::fromLocalFile(fi.canonicalFilePath());
    }
#else
    Q_UNUSED(options);
    qWarning("No filename specified...");
#endif
}

#ifndef QT_NO_TRANSLATION
static void loadTranslationFile(QTranslator &translator, const QString& directory)
{
    translator.load(QLatin1String("qml_" )+QLocale::system().name(), directory + QLatin1String("/i18n"));
    QCoreApplication::installTranslator(&translator);
}
#endif

static void loadDummyDataFiles(QQmlEngine &engine, const QString& directory)
{
    QDir dir(directory+"/dummydata", "*.qml");
    QStringList list = dir.entryList();
    for (int i = 0; i < list.size(); ++i) {
        QString qml = list.at(i);
        QFile f(dir.filePath(qml));
        f.open(QIODevice::ReadOnly);
        QByteArray data = f.readAll();
        QQmlComponent comp(&engine);
        comp.setData(data, QUrl());
        QObject *dummyData = comp.create();

        if(comp.isError()) {
            QList<QQmlError> errors = comp.errors();
            Q_FOREACH (const QQmlError &error, errors)
                qWarning() << error;
        }

        if (dummyData) {
            qWarning() << "Loaded dummy data:" << dir.filePath(qml);
            qml.truncate(qml.length()-4);
            engine.rootContext()->setContextProperty(qml, dummyData);
            dummyData->setParent(&engine);
        }
    }
}

class DummyTestRootObject : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool windowShown READ windowShown NOTIFY windowShownChanged)

public:
    DummyTestRootObject(QObject *o) :  QObject(o) {}

    bool windowShown() const { return false; }

Q_SIGNALS:
    void windowShownChanged();
};

static QObject *s_testRootObject = nullptr;
static QObject *testRootObject(QQmlEngine *engine, QJSEngine *jsEngine)
{
    Q_UNUSED(jsEngine);
    if (!s_testRootObject) {
        s_testRootObject = new DummyTestRootObject(engine);
    }
    return s_testRootObject;
}

static void usage()
{
    qWarning("Usage: uqmlscene [options] <filename>");
    qWarning(" ");
    qWarning(" Options:");
    qWarning("  --maximized ............................... Run maximized");
    qWarning("  --fullscreen .............................. Run fullscreen");
    qWarning("  --transparent ............................. Make the window transparent");
    qWarning("  --multisample ............................. Enable multisampling (OpenGL anti-aliasing)");
    qWarning("  --no-version-detection .................... Do not try to detect the version of the .qml file");
    qWarning("  --resize-to-root .......................... Resize the window to the size of the root item");
    qWarning("  --quit .................................... Quit immediately after starting");
    qWarning("  -I <path> ................................. Add <path> to the list of import paths");
    qWarning("  -B <name> <file> .......................... Add a named bundle");
    qWarning("  -translation <translationfile> ............ Set the language to run in");

    qWarning(" ");
    exit(1);
}

int main(int argc, char ** argv)
{
    Options options;

    QStringList imports;
    QList<QPair<QString, QString> > bundles;
    for (int i = 1; i < argc; ++i) {
        if (*argv[i] != '-' && QFileInfo(QFile::decodeName(argv[i])).exists()) {
            options.file = QUrl::fromLocalFile(argv[i]);
        } else {
            const QString lowerArgument = QString::fromLatin1(argv[i]).toLower();
            if (lowerArgument == QLatin1String("--maximized"))
                options.maximized = true;
            else if (lowerArgument == QLatin1String("--fullscreen"))
                options.fullscreen = true;
            else if (lowerArgument == QLatin1String("--transparent"))
                options.transparent = true;
            else if (lowerArgument == QLatin1String("--clip"))
                options.clip = true;
            else if (lowerArgument == QLatin1String("--no-version-detection"))
                options.versionDetection = false;
            else if (lowerArgument == QLatin1String("--quit"))
                options.quitImmediately = true;
           else if (lowerArgument == QLatin1String("-translation"))
                options.translationFile = QLatin1String(argv[++i]);
            else if (lowerArgument == QLatin1String("--resize-to-root"))
                options.resizeViewToRootItem = true;
            else if (lowerArgument == QLatin1String("--multisample"))
                options.multisample = true;
            else if (lowerArgument == QLatin1String("-i") && i + 1 < argc)
                imports.append(QString::fromLatin1(argv[++i]));
            else if (lowerArgument == QLatin1String("-b") && i + 2 < argc) {
                QString name = QString::fromLatin1(argv[++i]);
                QString file = QString::fromLatin1(argv[++i]);
                bundles.append(qMakePair(name, file));
            } else if (lowerArgument == QLatin1String("--help")
                     || lowerArgument == QLatin1String("-help")
                     || lowerArgument == QLatin1String("--h")
                     || lowerArgument == QLatin1String("-h"))
                usage();
        }
    }

#ifdef QT_WIDGETS_LIB
    QApplication app(argc, argv);
#else
    QGuiApplication app(argc, argv);
#endif
    app.setApplicationName("Unity8 QtQmlViewer");
    app.setOrganizationName("Qt Project");
    app.setOrganizationDomain("qt-project.org");

#ifndef QT_NO_TRANSLATION
    QTranslator translator;
    QTranslator qtTranslator;
    QString sysLocale = QLocale::system().name();
    if (translator.load(QLatin1String("qmlscene_") + sysLocale, QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
        app.installTranslator(&translator);
        if (qtTranslator.load(QLatin1String("qt_") + sysLocale, QLibraryInfo::location(QLibraryInfo::TranslationsPath))) {
            app.installTranslator(&qtTranslator);
        } else {
            app.removeTranslator(&translator);
        }
    }

    QTranslator qmlTranslator;
    if (!options.translationFile.isEmpty()) {
        if (qmlTranslator.load(options.translationFile)) {
            app.installTranslator(&qmlTranslator);
        } else {
            qWarning() << "Could not load the translation file" << options.translationFile;
        }
    }
#endif

    if (options.file.isEmpty())
#if defined(QMLSCENE_BUNDLE)
        displayOptionsDialog(&options);
#else
        displayFileDialog(&options);
#endif

    int exitCode = 0;

    if (!options.file.isEmpty()) {
        if (!options.versionDetection || checkVersion(options.file)) {
#ifndef QT_NO_TRANSLATION
            QTranslator translator;
#endif

            // TODO: as soon as the engine construction completes, the debug service is
            // listening for connections.  But actually we aren't ready to debug anything.
            QQmlEngine engine;
            QQmlComponent *component = new QQmlComponent(&engine);
            for (int i = 0; i < imports.size(); ++i)
                engine.addImportPath(imports.at(i));
            for (int i = 0; i < bundles.size(); ++i)
                engine.addNamedBundle(bundles.at(i).first, bundles.at(i).second);
            if (options.file.isLocalFile()) {
                QFileInfo fi(options.file.toLocalFile());
#ifndef QT_NO_TRANSLATION
                loadTranslationFile(translator, fi.path());
#endif
                loadDummyDataFiles(engine, fi.path());
            }
            QObject::connect(&engine, &QQmlEngine::quit, QCoreApplication::instance(), &QCoreApplication::quit);

            qmlRegisterSingletonType<QObject>("Qt.test.qtestroot", 1, 0, "QTestRootObject", testRootObject);

            component->loadUrl(options.file);
            if ( !component->isReady() ) {
                qWarning("%s", qPrintable(component->errorString()));
                return -1;
            }

            QObject *topLevel = component->create();
            QQuickWindow *window = qobject_cast<QQuickWindow *>(topLevel);
            QQuickView* qxView = 0;
            if (!window) {
                QQuickItem *contentItem = qobject_cast<QQuickItem *>(topLevel);
                if (contentItem) {
                    qxView = new QQuickView(&engine, nullptr);
                    window = qxView;
                    // Set window default properties; the qml can still override them
                    QString oname = contentItem->objectName();
                    window->setTitle(oname.isEmpty() ? QString::fromLatin1("qmlscene") : QString::fromLatin1("qmlscene: ") + oname);
                    window->setFlags(Qt::Window | Qt::WindowSystemMenuHint | Qt::WindowTitleHint | Qt::WindowMinMaxButtonsHint | Qt::WindowCloseButtonHint | Qt::WindowFullscreenButtonHint);
                    if (options.resizeViewToRootItem)
                        qxView->setResizeMode(QQuickView::SizeViewToRootObject);
                    else
                        qxView->setResizeMode(QQuickView::SizeRootObjectToView);
                    qxView->setContent(options.file, component, contentItem);
                }
            }

            if (window) {
                QSurfaceFormat surfaceFormat = window->requestedFormat();
                if (options.multisample)
                    surfaceFormat.setSamples(16);
                if (options.transparent) {
                    surfaceFormat.setAlphaBufferSize(8);
                    window->setClearBeforeRendering(true);
                    window->setColor(QColor(Qt::transparent));
                    window->setFlags(Qt::FramelessWindowHint);
                }
                window->setFormat(surfaceFormat);

                if (options.fullscreen)
                    window->showFullScreen();
                else if (options.maximized)
                    window->showMaximized();
                else
                    window->show();
            }

            if (options.quitImmediately)
                QMetaObject::invokeMethod(QCoreApplication::instance(), "quit", Qt::QueuedConnection);

            // Now would be a good time to inform the debug service to start listening.

            exitCode = app.exec();

#ifdef QML_RUNTIME_TESTING
            RenderStatistics::printTotalStats();
#endif
            // Ready to exit.  If we created qxView, it owns the component;
            // otherwise, the ownership is still right here.  Nobody deletes the engine
            // (which is odd since the container constructor takes the engine pointer),
            // but it's stack-allocated anyway.
            if (qxView)
                delete qxView;
            else
                delete component;
        }
    }

    return exitCode;
}

#include "main.moc"

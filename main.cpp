#include <QGuiApplication>
#include <QtWebView/QtWebView>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>

#include "translatorsmodel.h"

int main(int argc, char *argv[])
{
    QtWebView::initialize();
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    QQuickView *view = new QQuickView;
    auto *context = view->rootContext();
    auto engine = view->engine();

    TranslatorsModel model(engine);
    context->setContextProperty("translatorsModel", &model);

    QObject::connect(&model, &TranslatorsModel::reloadTranslations, engine, &QQmlEngine::retranslate);

    view->setSource(QUrl("qrc:/main.qml"));

    return app.exec();
}

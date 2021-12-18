#include <QGuiApplication>
#include <QtWebView/QtWebView>
#include <QQmlApplicationEngine>
#include <QQuickView>
#include <QQmlContext>
#include <QQmlEngine>

#include "translatorsmodel.h"

int main(int argc, char *argv[])
{
    QtWebView::initialize();
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    auto engine = new QQmlApplicationEngine("qrc:/main.qml");
    auto *context = engine->rootContext();

    TranslatorsModel model(engine);
    context->setContextProperty("translatorsModel", &model);

    QObject::connect(&model, &TranslatorsModel::reloadTranslations, engine, &QQmlEngine::retranslate);

    return app.exec();
}

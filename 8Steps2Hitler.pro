QT += quick webview
CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

SOURCES += \
        main.cpp \
        translatorsmodel.cpp

RESOURCES += images.qrc qml.qrc

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

HEADERS += \
    translatorsmodel.h

TRANSLATIONS = ru.ts

QT       += core gui multimedia

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

CONFIG += c++17

# You can make your code fail to compile if it uses deprecated APIs.
# In order to do so, uncomment the following line.
#DEFINES += QT_DISABLE_DEPRECATED_BEFORE=0x060000    # disables all the APIs deprecated before Qt 6.0.0

SOURCES += \
    androidHelpers/androidpermissions.cpp \
    audio/audiohandler.cpp \
    main.cpp \
    mainpanel.cpp

HEADERS += \
    androidHelpers/androidpermissions.h \
    audio/audiohandler.h \
    mainpanel.h

FORMS += \
    mainpanel.ui

TRANSLATIONS += \
    HomePanel_ru_RU.ts
CONFIG += lrelease
CONFIG += embed_translations

# Default rules for deployment.
qnx: target.path = /tmp/$${TARGET}/bin
else: unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    android/AndroidManifest.xml \
    android/build.gradle \
    android/res/values/libs.xml \
    android/res/xml/qtprovider_paths.xml \
    android/src/org/dsa/homepanel/PermissionsHelper.java

contains(ANDROID_TARGET_ARCH,arm64-v8a) {
    ANDROID_PACKAGE_SOURCE_DIR = \
        $$PWD/android
}

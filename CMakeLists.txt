cmake_minimum_required(VERSION 3.16)

project(HomePanel VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTORCC ON)

find_package(Qt6 REQUIRED COMPONENTS Quick)

qt_standard_project_setup(REQUIRES 6.8)

qt_add_executable(appHomePanel
    main.cpp
)

qt_add_qml_module(appHomePanel
    URI HomePanel
    QML_FILES
        ui/Main.qml
        QML_FILES ui/drawer/CustomDrawer.qml
        QML_FILES ui/clock/Clock.qml
        QML_FILES ui/viewer/PhotoViewer.qml
        SOURCES backend/SystemInfo.h
        SOURCES backend/pathprovider.h backend/pathprovider.cpp
        SOURCES backend/androidutils.h backend/androidutils.cpp
        QML_FILES ui/viewer/AnimationManager.qml
        QML_FILES ui/calendar/CalendarTile.qml
        QML_FILES ui/calendar/CalendarView.qml
        RESOURCES res.qrc
        QML_FILES ui/timer/TimerMenuWidget.qml
        QML_FILES ui/timer/TimerCreateDialog.qml
        QML_FILES ui/timer/TimerWidget.qml
)

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appHomePanel PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appHomePanel
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
    QT_ANDROID_PACKAGE_SOURCE_DIR ${CMAKE_CURRENT_SOURCE_DIR}/android
)

target_link_libraries(appHomePanel
    PRIVATE Qt6::Quick
)

include(GNUInstallDirs)
install(TARGETS appHomePanel
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

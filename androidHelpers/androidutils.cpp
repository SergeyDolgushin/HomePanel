#include "androidutils.h"
#include <QJniObject>
#include <QDebug>

QSize AndroidUtils::physicalScreenSize()
{
    QJniObject result = QJniObject::callStaticObjectMethod(
        "org/dsa/homepanel/AndroidUtils",
        "getRealScreenSize",
        "()Landroid/graphics/Point;"
        );

    if (!result.isValid()) {
        qWarning() << "AndroidUtils.getRealScreenSize() returned invalid";
        return {};
    }

    int width = result.getField<int>("x");
    int height = result.getField<int>("y");

    if (width <= 0 || height <= 0) {
        qWarning() << "Invalid screen size:" << width << "x" << height;
        return {};
    }

    qDebug() << "✅ Реальный размер экрана:" << width << "x" << height;
    return {width, height};
}

float AndroidUtils::physicalDensity()
{
    QJniObject metrics = QJniObject::callStaticObjectMethod(
        "org/dsa/homepanel/AndroidUtils",
        "getDisplayMetrics",
        "()Landroid/util/DisplayMetrics;"
        );

    if (!metrics.isValid()) {
        qWarning() << "AndroidUtils.getDisplayMetrics() returned invalid";
        return 1.0f;
    }

    float density = metrics.getField<jfloat>("density");
    qDebug() << "✅ Физическая плотность (density):" << density;
    return density;
}

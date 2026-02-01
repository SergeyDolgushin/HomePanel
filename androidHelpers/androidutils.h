#ifndef ANDROIDUTILS_H
#define ANDROIDUTILS_H

#include "qsize.h"

class AndroidUtils
{
public:
    static QSize physicalScreenSize();
    static float physicalDensity();
};

#endif // ANDROIDUTILS_H

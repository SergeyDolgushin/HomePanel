package org.dsa.homepanel;

import android.app.Activity;
import android.graphics.Point;
import android.util.DisplayMetrics;
import android.view.Display;

public class AndroidUtils {

    // Статическое хранение контекста активности
    private static Activity sActivity;

    public static void setActivity(Activity activity) {
        sActivity = activity;
    }

    // Получить реальные размеры экрана в пикселях
    public static Point getRealScreenSize() {
        if (sActivity == null) return new Point(-1, -1);

        Display display = sActivity.getWindowManager().getDefaultDisplay();
        Point size = new Point();
        display.getRealSize(size); // включает системные панели (если нет вырезов)
        return size;
    }

    // Альтернатива: через DisplayMetrics
    public static DisplayMetrics getDisplayMetrics() {
        if (sActivity == null) return null;

        DisplayMetrics metrics = new DisplayMetrics();
        sActivity.getWindowManager().getDefaultDisplay().getRealMetrics(metrics);
        return metrics;
    }
}

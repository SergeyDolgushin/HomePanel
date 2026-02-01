package org.dsa.homepanel;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.Manifest;

import androidx.core.app.ActivityCompat;
import androidx.core.content.ContextCompat;

public class PermissionsHelper {
    // Проверка наличия разрешения RECORD_AUDIO
    public static boolean hasRecordAudioPermission(Context ctx) {
        return ContextCompat.checkSelfPermission(ctx, Manifest.permission.RECORD_AUDIO)
                == PackageManager.PERMISSION_GRANTED;
    }

    // Запрос разрешения RECORD_AUDIO. requestCode можно выбрать любой уникальный int.
    public static void requestRecordAudioPermission(Activity activity, int requestCode) {
        ActivityCompat.requestPermissions(activity,
                new String[]{Manifest.permission.RECORD_AUDIO},
                requestCode);
    }
}

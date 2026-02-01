package org.dsa.homepanel;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;

import java.util.ArrayList;

public class SpeechRecognizerHelper {
    private static final String TAG = "SpeechRecognizerHelper";
    private static SpeechRecognizer recognizer = null;
    private static Intent intent = null;

    // native callback объявлен здесь — будет реализован в C++
    private static native void nativeOnSpeechResult(String text, boolean isFinal);

    // инициализация с activity (вызывать после получения permission)
    public static void init(final Activity activity) {
        if (activity == null) {
            Log.w(TAG, "init: activity == null");
            return;
        }
        try {
            if (recognizer == null) {
                recognizer = SpeechRecognizer.createSpeechRecognizer(activity);
                recognizer.setRecognitionListener(new RecognitionListener() {
                    @Override public void onReadyForSpeech(Bundle params) { Log.d(TAG, "onReadyForSpeech"); }
                    @Override public void onBeginningOfSpeech() { Log.d(TAG, "onBeginningOfSpeech"); }
                    @Override public void onRmsChanged(float rmsdB) { /* Можно логировать уровень */ }
                    @Override public void onBufferReceived(byte[] buffer) { }
                    @Override public void onEndOfSpeech() { Log.d(TAG, "onEndOfSpeech"); }
                    @Override public void onError(int error) { Log.w(TAG, "onError: " + error); }
                    @Override public void onResults(Bundle results) {
                        ArrayList<String> texts = results.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                        if (texts != null && texts.size() > 0) {
                            Log.d(TAG, "onResults: " + texts.get(0));
                            nativeOnSpeechResult(texts.get(0), true);
                        }
                    }
                    @Override public void onPartialResults(Bundle partialResults) {
                        ArrayList<String> texts = partialResults.getStringArrayList(SpeechRecognizer.RESULTS_RECOGNITION);
                        if (texts != null && texts.size() > 0) {
                            Log.d(TAG, "onPartialResults: " + texts.get(0));
                            nativeOnSpeechResult(texts.get(0), false);
                        }
                    }
                    @Override public void onEvent(int eventType, Bundle params) { }
                });
            }

            if (intent == null) {
                intent = new Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH);
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM);
                intent.putExtra(RecognizerIntent.EXTRA_PARTIAL_RESULTS, true);
                // выберите нужный язык; если установлен пакет, можно использовать системный
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "ru-RU");
            }
            Log.d(TAG, "init done");
        } catch (Exception e) {
            Log.e(TAG, "init failed", e);
        }
    }

    // запуск распознавания
    public static void startListening() {
        try {
            if (recognizer != null && intent != null) {
                recognizer.startListening(intent);
                Log.d(TAG, "startListening");
            } else {
                Log.w(TAG, "startListening: recognizer or intent is null");
            }
        } catch (Exception e) {
            Log.e(TAG, "startListening failed", e);
        }
    }

    // останов распознавания
    public static void stopListening() {
        try {
            if (recognizer != null) {
                recognizer.stopListening();
                Log.d(TAG, "stopListening");
            }
        } catch (Exception e) {
            Log.e(TAG, "stopListening failed", e);
        }
    }

    // освободить ресурсы (по необходимости)
    public static void destroy() {
        try {
            if (recognizer != null) {
                recognizer.destroy();
                recognizer = null;
            }
            intent = null;
            Log.d(TAG, "destroyed");
        } catch (Exception e) {
            Log.e(TAG, "destroy failed", e);
        }
    }

    // загрузка native библиотеки происходит автоматически в Qt-приложении (lib<appname>.so),
    // поэтому здесь System.loadLibrary не нужен (и даже не рекомендуется).
}
package org.dsa.homepanel;

import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.speech.RecognitionListener;
import android.speech.RecognizerIntent;
import android.speech.SpeechRecognizer;
import android.util.Log;
import android.speech.SpeechRecognizer;

import java.util.ArrayList;

public class SpeechRecognizerHelper {
    private static final String TAG = "SpeechRecognizerHelper";
    private static SpeechRecognizer recognizer = null;
    private static Intent intent = null;
    private static Activity sActivity = null;

    // native callback — реализован в C++
    private static native void nativeOnSpeechResult(String text, boolean isFinal);

    public static void init(final Activity activity) {
         AndroidUtils.setActivity(activity);
        if (activity == null) {
            Log.w(TAG, "init: activity == null");
            return;
        }
        sActivity = activity;

        // Всё, что касается SpeechRecognizer — выполняем на UI-потоке
        try {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (!SpeechRecognizer.isRecognitionAvailable(activity)) {
                            Log.w(TAG, "Speech recognition NOT available on this device");
                            return;
                        }

                        if (recognizer == null) {
                            recognizer = SpeechRecognizer.createSpeechRecognizer(activity);
                            recognizer.setRecognitionListener(new RecognitionListener() {
                                @Override public void onReadyForSpeech(Bundle params) { Log.d(TAG, "onReadyForSpeech"); }
                                @Override public void onBeginningOfSpeech() { Log.d(TAG, "onBeginningOfSpeech"); }
                                @Override public void onRmsChanged(float rmsdB) { Log.d(TAG, "onRmsChanged: " + rmsdB); }
                                @Override public void onBufferReceived(byte[] buffer) { }
                                @Override public void onEndOfSpeech() { Log.d(TAG, "onEndOfSpeech"); }
                                @Override public void onError(int error) {
                                    Log.w(TAG, "onError: " + error);
                                }
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
                            intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "ru-RU");
                            // intent.putExtra(RecognizerIntent.EXTRA_MAX_RESULTS, 5);
                        }

                        Log.d(TAG, "init done (on UI thread)");
                    } catch (Exception e) {
                        Log.e(TAG, "init failed (on UI thread)", e);
                    }
                }
            });
        } catch (Exception e) {
            Log.e(TAG, "init failed", e);
        }
    }

    public static void startListening() {
        if (sActivity == null) {
            Log.w(TAG, "startListening: activity is null");
            return;
        }
        sActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (recognizer == null || intent == null) {
                        Log.w(TAG, "startListening: recognizer or intent is null");
                        return;
                    }
                    recognizer.startListening(intent);
                    Log.d(TAG, "startListening (UI thread) called");
                } catch (Exception e) {
                    Log.e(TAG, "startListening failed", e);
                }
            }
        });
    }

    public static void stopListening() {
        if (sActivity == null) {
            Log.w(TAG, "stopListening: activity is null");
            return;
        }
        sActivity.runOnUiThread(new Runnable() {
            @Override
            public void run() {
                try {
                    if (recognizer != null) {
                        recognizer.stopListening();
                        Log.d(TAG, "stopListening (UI thread) called");
                    }
                } catch (Exception e) {
                    Log.e(TAG, "stopListening failed", e);
                }
            }
        });
    }

    public static void destroy() {
        if (sActivity == null) {
            // всё равно можем уничтожить на любом потоке, но лучше на UI
        }
        if (sActivity != null) {
            sActivity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (recognizer != null) {
                            recognizer.destroy();
                            recognizer = null;
                        }
                        intent = null;
                        Log.d(TAG, "destroyed (UI thread)");
                    } catch (Exception e) {
                        Log.e(TAG, "destroy failed", e);
                    }
                }
            });
        } else {
            recognizer = null;
            intent = null;
        }
    }
}

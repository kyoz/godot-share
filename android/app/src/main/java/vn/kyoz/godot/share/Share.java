package vn.kyoz.godot.share;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.collection.ArraySet;

import org.godotengine.godot.Godot;
import org.godotengine.godot.plugin.GodotPlugin;
import org.godotengine.godot.plugin.SignalInfo;
import org.godotengine.godot.plugin.UsedByGodot;

import java.io.File;
import java.util.Set;

public class Share extends GodotPlugin {
    private static final String TAG = "GodotShare";
    private Activity activity;

    public Share(Godot godot) {
        super(godot);
        activity = getActivity();
    }

    @NonNull
    @Override
    public String getPluginName() {
        return getClass().getSimpleName();
    }


    @NonNull
    @Override
    public Set<SignalInfo> getPluginSignals() {
        Set<SignalInfo> signals = new ArraySet<>();

        signals.add(new SignalInfo("share_error", String. class));

        return signals;
    }

    @UsedByGodot
    public void shareText(String title, String subject, String content) {
        Log.d(TAG, "called shareText()");
        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType("text/plain");
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        shareIntent.putExtra(Intent.EXTRA_TEXT, content);
        activity.startActivity(Intent.createChooser(shareIntent, title));
    }

    @UsedByGodot
    public void shareImage(String image_path, String title, String subject, String content) {
        Log.d(TAG, "called sharePic()");
        File file = new File(image_path);
        Uri uri;

        try {
            uri = ShareFileProvider.getUriForFile(activity, activity.getPackageName(), file);
        } catch (IllegalArgumentException e) {
            Log.e(TAG, "ERROR_IMAGE_FILE");
            Log.e(TAG, e.getMessage());
            emitSignal("share_error", "ERROR_IMAGE_FILE");
            return;
        }

        Intent shareIntent = new Intent(Intent.ACTION_SEND);
        shareIntent.setType("image/*");
        shareIntent.putExtra(Intent.EXTRA_STREAM, uri);
        shareIntent.putExtra(Intent.EXTRA_SUBJECT, subject);
        shareIntent.putExtra(Intent.EXTRA_TEXT, content);
        shareIntent.addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION);
        activity.startActivity(Intent.createChooser(shareIntent, title));
    }
}

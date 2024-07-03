package com.example.cic_production_pi;

import androidx.annotation.NonNull;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

import com.keyence.autoid.sdk.scan.DecodeResult;
import com.keyence.autoid.sdk.scan.ScanManager;

public class MainActivity extends FlutterActivity implements ScanManager.DataListener {
    private static final String CHANNEL = "keyence_scanner";
    private ScanManager mScanManager;
    private String qr_res;

    // Create a read event.
    @Override
    public void onDataReceived(DecodeResult decodeResult) {
        // Acquire the reading result.
        DecodeResult.Result result = decodeResult.getResult();
        // Acquire the read code type.
        String codeType = decodeResult.getCodeType();
        // Acquire the read data.
        String data = decodeResult.getData();
        qr_res = decodeResult.getData();
    }

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);

        // Create a ScanManager class instance.
        mScanManager = ScanManager.createScanManager(this);
        // Create a listener to receive a read event.
        mScanManager.addDataListener(this);

        new MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
                .setMethodCallHandler(new MethodCallHandler() {
                    @Override
                    public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
                        if (call.method.equals("startScan")) {
                            String scanResult = startScan();
                            clearLastScan();
                            result.success(scanResult);
                        } else if (call.method.equals("stopScan")) {
                            String scanResult = stopScan();
                            result.success(scanResult);
                        } else {
                            result.notImplemented();
                        }
                    }
                });
    }

    private String startScan() {
        // Implement Keyence scanner start scan logic
        // Return the scanned result or status
        // return "Scan started " + qr_res;

        // String res = qr_res.substring(0, 1);
        // if (res.equals("M")) {
        // return "M";
        // }
        return qr_res;
    }

    private String stopScan() {
        // Implement Keyence scanner stop scan logic
        // Return the scanned result or status
        qr_res = "Scan stopped";
        return "Scan stopped";
    }

    private void clearLastScan() {
        qr_res = "Scan stopped";
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Discard the ScanManager class instance.
        mScanManager.removeDataListener(this);
        // Discard the ScanManager class instance to release the resources.
        mScanManager.releaseScanManager();
    }

}

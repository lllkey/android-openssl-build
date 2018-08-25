package com.example.blt.testjniopenssl;

import android.app.Activity;
import android.os.Build;
import android.os.Bundle;
import android.util.Log;
import android.widget.TextView;

public class MainActivity extends Activity {

    static String LOG_T = "MainActivity";
    OpensslJni opensslJni;
    String salt = "e258017933f3e629a4166cece78f3162a3b0b7edb2e94c93d76fe6c38198ea12";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            for (String s : android.os.Build.SUPPORTED_ABIS) {
                System.out.println("aaaa:cpu:SUPPORTED_ABIS=" + s);
            }
        else {
            System.out.println("aaaa:cpu:CPU_ABI=" + android.os.Build.CPU_ABI);
            System.out.println("aaaa:cpu:CPU_ABI2=" + android.os.Build.CPU_ABI2);
        }

        opensslJni = new OpensslJni();
        // Example of a call to a native method
        TextView tv = (TextView) findViewById(R.id.sample_text);
        tv.setText(opensslJni.stringFromJNI());

        String  str = "xyz";
        byte[] byteKey = str.getBytes();
        byte[] byteSalt = getByteByStr(salt);
        Log.v(LOG_T, "byteSalt: " + getStrByByte(byteSalt));
        Log.v(LOG_T, "byteKey: " + getStrByByte(byteKey));
        byte[] byteArr = opensslJni.hashKey(byteKey, byteSalt, 1);
        Log.v(LOG_T, "tmp1: " + getStrByByte(byteArr));
        tv.setText(getStrByByte(byteArr));
    }

    byte[] getByteByStr(String str){
        byte[] byteArr = new byte[str.length()/2];
        for(int i = 0; i < str.length(); i += 2){
            String tmp = str.substring(i, i + 2);
            Log.v(LOG_T, "tmp: " + tmp);
            byteArr[i/2] = Integer.valueOf(tmp, 16).byteValue();

            Log.v(LOG_T, "tmp1: " + byteArr[i/2]);
        }
        return byteArr;
    }
    String getStrByByte(byte[] byteArr){
        String result = "";
        for(int i = 0; i < byteArr.length; i++){
            String hex = Integer.toHexString(byteArr[i] & 0xFF);
            if (hex.length() == 1) {
                hex = '0' + hex;
            }
            result += hex.toUpperCase();
        }
        return result;
    }
}

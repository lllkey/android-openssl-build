package com.example.blt.testjniopenssl;

/**
 * Created by lsq on 2018/8/24.
 */

public class OpensslJni {

    static {
        System.loadLibrary("native-lib");
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();

    public native byte[] hashKey(byte[] key, byte[] salt, int count);
}

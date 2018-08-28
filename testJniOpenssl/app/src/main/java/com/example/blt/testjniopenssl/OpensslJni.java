package com.example.blt.testjniopenssl;

/**
 * Created by lsq on 2018/8/24.
 */

public class OpensslJni {

    static {
    	// 如果动态调用openssl的时候需要取消下面注释
        // System.loadLibrary("crypto");
        // System.loadLibrary("ssl");
        System.loadLibrary("native-lib");
    }

    /**
     * A native method that is implemented by the 'native-lib' native library,
     * which is packaged with this application.
     */
    public native String stringFromJNI();

    public native byte[] hashKey(byte[] key, byte[] salt, int count);
}

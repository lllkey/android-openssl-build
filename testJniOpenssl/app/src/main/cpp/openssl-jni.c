#include <string.h>
#include <jni.h>
#include <openssl/evp.h>
#include <openssl/sha.h>


JNIEXPORT jbyteArray JNICALL Java_com_example_blt_testjniopenssl_OpensslJni_hashKey
        (JNIEnv *env, jobject thiz, jbyteArray pass, jbyteArray salt, jint count)
{
    jbyte* pJbytePass = (*env)->GetByteArrayElements(env, pass, NULL);
    char* szBytePass = (char *)pJbytePass;
    int iLenPass = (*env)->GetArrayLength(env, pass);
    jbyte* pJbyteSalt = (*env)->GetByteArrayElements(env, salt, NULL);
    char* szByteSalt = (char *)pJbyteSalt;
    int iLenSalt = (*env)->GetArrayLength(env, salt);
    int OUTSIZE = 64;
    char buf[64];
    memset( buf, 0, sizeof(buf) );
    PKCS5_PBKDF2_HMAC(
            szBytePass,
            iLenPass,
            szByteSalt,
            iLenSalt,
            count, EVP_sha512(), OUTSIZE, buf);
    jbyteArray jarray = (*env)->NewByteArray(env, OUTSIZE);
    (*env)->SetByteArrayRegion(env, jarray, 0, OUTSIZE,buf);
    (*env)->ReleaseByteArrayElements(env, pass, pJbytePass, 0);
    (*env)->ReleaseByteArrayElements(env, salt, pJbyteSalt, 0);
    return jarray;
}
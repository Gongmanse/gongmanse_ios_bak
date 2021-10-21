package com.gongmanse.app.api;

import com.gongmanse.app.MyApplication;
import com.gongmanse.app.R;

import java.io.IOException;
import java.io.InputStream;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

public class SSLHelper {
    public SSLContext sslContext;
    public TrustManagerFactory tmf;
    private SSLHelper() {
        setUp();
    }
    private static class SelfSigningClientBuilderHolder{
        public static final SSLHelper INSTANCE = new SSLHelper();
    }
    public static SSLHelper getInstance() {
        return SelfSigningClientBuilderHolder.INSTANCE;
    }
    public void setUp() {
        CertificateFactory cf;
        Certificate ca;
        InputStream caInput;
        try {
            cf = CertificateFactory.getInstance("X.509");
            caInput = MyApplication.instance.getAppContext().getResources().openRawResource(R.raw.local_cert);
            ca = cf.generateCertificate(caInput);
            System.out.println("ca=" + ((X509Certificate) ca).getSubjectDN());

            // Create a KeyStore containing our trusted CAs
            String keyStoreType = KeyStore.getDefaultType();
            KeyStore keyStore = KeyStore.getInstance(keyStoreType);
            keyStore.load(null,null);
            keyStore.setCertificateEntry("ca", ca);

            // Create a TrustManager that trusts the CAs in our KeyStore
            String tmfAlgorithm = TrustManagerFactory.getDefaultAlgorithm();
            tmf = TrustManagerFactory.getInstance(tmfAlgorithm);
            tmf.init(keyStore);

            // Create an SSLContext that uses our TrustManager
            sslContext = SSLContext.getInstance("TLS");
            sslContext.init(null, tmf.getTrustManagers(), new java.security.SecureRandom());
            caInput.close();
        } catch (KeyStoreException
                | CertificateException
                | NoSuchAlgorithmException
                | IOException
                | KeyManagementException e) {
            e.printStackTrace();
        }
    }
}

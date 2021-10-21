package com.gongmanse.app

import android.content.Context
import com.bumptech.glide.Glide
import com.bumptech.glide.Registry
import com.bumptech.glide.annotation.GlideModule
import com.bumptech.glide.integration.okhttp3.OkHttpUrlLoader
import com.bumptech.glide.load.model.GlideUrl
import com.bumptech.glide.module.AppGlideModule
import com.gongmanse.app.api.SSLHelper
import okhttp3.OkHttpClient
import java.io.InputStream
import javax.net.ssl.X509TrustManager

@GlideModule
class GlideModule : AppGlideModule() {
    override fun registerComponents(context: Context, glide: Glide, registry: Registry) {
        super.registerComponents(context, glide, registry)

        val builder = OkHttpClient.Builder();
        builder.sslSocketFactory(
            SSLHelper.getInstance().sslContext.socketFactory,
            SSLHelper.getInstance().tmf.trustManagers[0] as X509TrustManager
        )
        registry.replace(GlideUrl::class.java, InputStream::class.java, OkHttpUrlLoader.Factory(builder.build()))

    }
}
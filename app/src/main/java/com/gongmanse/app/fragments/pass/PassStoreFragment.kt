package com.gongmanse.app.fragments.pass

import android.app.Activity
import android.os.Bundle
import android.util.Log
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.databinding.DataBindingUtil
import androidx.fragment.app.Fragment
import com.android.billingclient.api.*
import com.android.billingclient.api.BillingClient.BillingResponseCode
import com.gongmanse.app.R
import com.gongmanse.app.activities.PassActivity
import com.gongmanse.app.api.RetrofitClient
import com.gongmanse.app.databinding.FragmentPassStoreBinding
import com.gongmanse.app.utils.Constants
import com.gongmanse.app.utils.Preferences
import kotlinx.coroutines.*
import okhttp3.ResponseBody
import retrofit2.Call
import retrofit2.Callback
import retrofit2.Response


class PassStoreFragment : Fragment() {

    companion object {
        private val TAG = PassStoreFragment::class.java.simpleName
    }

    private lateinit var binding: FragmentPassStoreBinding
    private var mSkuDetailsItemInfo: HashMap<String, SkuDetails>? = null
    private var activity: Activity? = null
    private var mBillingClient: BillingClient? = null
    private var detail: SkuDetails? = null
    private val mConsumeListener: ConsumeResponseListener? = null


    override fun onCreateView(inflater: LayoutInflater, container: ViewGroup?, savedInstanceState: Bundle?): View {
        binding = DataBindingUtil.inflate(inflater, R.layout.fragment_pass_store, container, false)
        return binding.root
    }

    override fun onActivityCreated(savedInstanceState: Bundle?) {
        super.onActivityCreated(savedInstanceState)
        initView()
    }

    private fun initView() {
        initPurchases()
        binding.apply {
            mSkuDetailsItemInfo = hashMapOf()
            activity = context as PassActivity
            radioGroup.setOnCheckedChangeListener { _, checkedId ->  clickEvent(checkedId) }
            btnPurchase.setOnClickListener { purchases() }
        }


    }

    private fun clickEvent(checkId: Int) {
        Log.d(TAG,"clickEvent \n mSkuDetailsItemInfo: $mSkuDetailsItemInfo")
        when(checkId) {
            R.id.rb_pass_30days  -> {
                detail = mSkuDetailsItemInfo?.get(Constants.PURCHASE_DURATION_30DAYS_VALUE)
                Log.d(TAG, "30Days detail: $detail")
            }
            R.id.rb_pass_90days  -> {
                detail = mSkuDetailsItemInfo?.get(Constants.PURCHASE_DURATION_90DAYS_VALUE)
                Log.d(TAG, "90Days detail: $detail")
            }
            R.id.rb_pass_150days -> {
                detail = mSkuDetailsItemInfo?.get(Constants.PURCHASE_DURATION_150DAYS_VALUE)
                Log.d(TAG, "150Days detail: $detail")
            }
            else -> {
                detail = mSkuDetailsItemInfo?.get(Constants.PURCHASE_DURATION_30DAYS_VALUE)
                Log.d(TAG, "30Days detail: $detail")
            }
        }

    }


    private fun initPurchases() {
        Log.d(TAG, "initPurchases")
        val purchasesUpdatedListener = PurchasesUpdatedListener { billingResult, purchases ->
            Log.d(TAG, "billingResult:$billingResult purchases:$purchases")

            // To be implemented in a later section.
            if (purchases != null) {
                Log.d(TAG, "purchases is not null => $purchases")
                when (billingResult.responseCode) {
                    BillingResponseCode.OK            -> { for (purchase in purchases) { handlePurchase(purchase) } }
                    BillingResponseCode.USER_CANCELED -> { Log.d(TAG, "Handle an error caused by a user cancelling the purchase flow.") }
                    else -> { Log.d(TAG, "Handle any other error codes.") }
                }
            } else Log.e(TAG, "purchases is null $purchases")


        }

        mBillingClient = this.context?.let { BillingClient.newBuilder(it) }
            ?.setListener(purchasesUpdatedListener)
            ?.enablePendingPurchases()
            ?.build()
        Log.e(TAG, "mBillingClient 02 => $mBillingClient")


        // Google Play 연결 (비동기)
        mBillingClient?.startConnection( object : BillingClientStateListener {

            override fun onBillingSetupFinished(billingResult: BillingResult) {
                // The BillingClient is ready. You can query purchases here.
                Log.d(TAG, "onBillingSetupFinished \n 구글 결제 서버에 접속 성공")


                // 상품 정보 응답
                if (billingResult.responseCode == BillingResponseCode.OK ) querySkuDetails()
                else Log.e(TAG, "onBillingSetupFinished Failed => $billingResult \n ResponseCode => ${billingResult.responseCode}")


            }
            override fun onBillingServiceDisconnected() {
                Log.d(TAG, "onBillingServiceDisconnected \n 구글 결제 서버와 접속이 실패, 끊김")
            }

        })


    }

    private fun querySkuDetails() {
        Log.d(TAG, "querySkuDetails()")
        // 구입 가능한 제품 표시
        val skuList = ArrayList<String>()
        skuList.add(Constants.PURCHASE_DURATION_30DAYS_VALUE)
        skuList.add(Constants.PURCHASE_DURATION_90DAYS_VALUE)
        skuList.add(Constants.PURCHASE_DURATION_150DAYS_VALUE)
        Log.d(TAG, "skuList:$skuList")

        val params = SkuDetailsParams.newBuilder()
        params.setSkusList(skuList).setType(BillingClient.SkuType.INAPP)
        Log.d(TAG, "withContext")
        CoroutineScope(Dispatchers.Main).launch {
            withContext(Dispatchers.IO) {
                // 비동기 상태로 앱의 정보를 가져옴
                mBillingClient?.querySkuDetailsAsync(params.build()) { billingResult, skuDetailsList ->
                    Log.d(TAG, "billingResult:$billingResult \n skuDetailsList:$skuDetailsList")
                    // Process the result.

                    // 상품 정보 응답 code
                    when(billingResult.responseCode) {
                        BillingResponseCode.OK                    -> { Log.d(TAG, "responseCode => Ok")}
                        BillingResponseCode.ERROR                 -> { Log.d(TAG, "responseCode => ERROR")}
                        BillingResponseCode.USER_CANCELED         -> { Log.d(TAG, "responseCode => USER_CANCELED")}
                        BillingResponseCode.DEVELOPER_ERROR       -> { Log.d(TAG, "responseCode => DEVELOPER_ERROR")}
                        BillingResponseCode.BILLING_UNAVAILABLE   -> { Log.d(TAG, "responseCode => BILLING_UNAVAILABLE")}
                        BillingResponseCode.SERVICE_TIMEOUT       -> { Log.d(TAG, "responseCode => SERVICE_TIMEOUT")}
                        BillingResponseCode.FEATURE_NOT_SUPPORTED -> { Log.d(TAG, "responseCode => FEATURE_NOT_SUPPORTED") }
                        else -> Log.d(TAG, "오류코드: \" + billingResult.responseCode")
                    }

                    // 응답 받은 데이터 유, 무
                    if (skuDetailsList != null) {
                        Log.d(TAG, "(인앱) 응답 받은 데이터 숫자: ${skuDetailsList.size} \n 데이터: $skuDetailsList")
                        for (detail in skuDetailsList) {
                            detail.sku.let {
                                mSkuDetailsItemInfo?.set(it, detail)
                            }
                        }
                        Log.d(TAG, "mSkuDetailsItemInfo: $mSkuDetailsItemInfo")
                    }
                    else { Log.d(TAG, "(인앱) 상품 정보가 존재하지 않습니다.") }
                }
            }
        }
    }

    // 결제 진행: 화면 셋팅
    private fun purchases () {
        Log.d(TAG, "purchases")
        Log.d(TAG, "detail => $detail")
        if (detail != null) {
            detailSetting(detail)
        } else {
            // 이용권을 클릭 안했을 경우
            if (mSkuDetailsItemInfo.isNullOrEmpty()) Log.e(TAG, "Detail is null => $detail")
            else {
                detail = mSkuDetailsItemInfo?.get(Constants.PURCHASE_DURATION_30DAYS_VALUE)
                detailSetting(detail)
            }
        }
    }

    // 결제 진행: 화면 보여주기
    private fun detailSetting(details: SkuDetails?) {

        val flowParams = BillingFlowParams.newBuilder()
            .setSkuDetails(details!!)
            .build()

        val responseCode = activity?.let {
            mBillingClient?.launchBillingFlow(it, flowParams)?.responseCode

        }
        Log.e(TAG, "responseCode => $responseCode")
    }

    // 결제 완료: 소비성 결제 상품 결제 확정, 구매 처리
    private fun handlePurchase(purchase: Purchase?) {
        Log.d(TAG, "handlePurchase => $purchase")
        // Purchase retrieved from BillingClient#queryPurchases or your PurchasesUpdatedListener.
        if (purchase != null) {
            val consumeParams = ConsumeParams.newBuilder()
                .setPurchaseToken(purchase.purchaseToken)
                .build()

            // Verify the purchase.
            // Ensure entitlement was not already granted for this purchaseToken.
            // Grant entitlement to the user.

            val listener = ConsumeResponseListener { billingResult, purchaseToken ->
                if (billingResult.responseCode == BillingResponseCode.OK) {
                    // Handle the success of the consume operation.
                    Log.d(TAG, "billingResult: $billingResult, purchaseToken:$purchaseToken")

                    RetrofitClient.getService().puchaseInApp(Preferences.token, purchaseToken, purchase.sku, purchase.orderId).enqueue(object : Callback<ResponseBody> {

                        override fun onFailure(call: Call<ResponseBody>, t: Throwable) {
                            Log.d(TAG, "Failed API call with call : $call\nexception : $t")
                        }

                        override fun onResponse(call: Call<ResponseBody>, response: Response<ResponseBody>) {
                            if (!response.isSuccessful) Log.d(TAG, "Failed API code : ${response.code()}\n message : ${response.message()}")
                            if (response.isSuccessful) {
                                response.body()?.apply {
                                    Log.d(TAG, "onResponse => $this")
                                }
                            }
                        }

                    })

                }
            }

            mBillingClient?.consumeAsync(consumeParams, listener)

        } else Log.d(TAG, "Purchase is Null")
    }


}
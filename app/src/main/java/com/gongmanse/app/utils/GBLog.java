package com.gongmanse.app.utils;
/**
 *  Simple log class
 *  - print class name
 *  - print method name
 *  - print line number
 * @author Hankyu85@Naver.com
 */

import android.util.Log;

import com.gongmanse.app.BuildConfig;

public class GBLog
{
	private static boolean SHOW = BuildConfig.DEBUG;
    private static boolean DEBUG_FLAG = true;
    private static boolean ERROR_FLAG = true;
    private static boolean INFO_FLAG = true;
    private static boolean WARNING_FLAG = true;
    private static boolean VERBOS_FLAG = true;
    
    public GBLog()
    {}
    
    public static void d(String tag, String message)
    {
        if (DEBUG_FLAG && SHOW)
        {
            String log = buildLogMsg(message); 
            Log.d(tag, log);
        }
    }
    
    public static void e(String tag, String message)
    {
        if (ERROR_FLAG && SHOW)
        {
            String log = buildLogMsg(message); 
            Log.e(tag, log);
        }
    }

    public static void i(String tag, String message)
    {
        if (INFO_FLAG && SHOW)
        {
            String log = buildLogMsg(message); 
            Log.i(tag, log);
        }
    }

    public static void w(String tag, String message)
    {
        if (WARNING_FLAG && SHOW)
        {
            String log = buildLogMsg(message); 
            Log.w(tag, log);
        }
    }

    public static void v(String tag, String message)
    {
        if (VERBOS_FLAG && SHOW)
        {
            String log = buildLogMsg(message); 
            Log.v(tag, log);
        }
    }

    private static String buildLogMsg(String message)
    {
        StackTraceElement ste = Thread.currentThread().getStackTrace()[4];         
        StringBuilder sb = new StringBuilder();
        sb.append("[");
        sb.append(ste.getFileName());
        sb.append(" > ");
        sb.append(ste.getMethodName());
        sb.append(" > #");
        sb.append(ste.getLineNumber());
        sb.append("] ");
        sb.append(message);
        return sb.toString();
    }

}
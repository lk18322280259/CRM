package com.crm.commons.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

//对Date类型数据进行处理
public class DateUtils {

    public static String formatDateTime(Date date){
        //对指定的Date对象进行格式化: yyyy-MM-dd HH:mm:ss
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String nowStr = sdf.format(date);
        return nowStr;
    }

    public static String formatDate(Date date){
        //对指定的Date对象进行格式化: yyyy-MM-dd
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        String nowStr = sdf.format(date);
        return nowStr;
    }

    public static String formatTime(Date date){
        //对指定的Date对象进行格式化: HH:mm:ss
        SimpleDateFormat sdf = new SimpleDateFormat("HH:mm:ss");
        String nowStr = sdf.format(date);
        return nowStr;
    }
}

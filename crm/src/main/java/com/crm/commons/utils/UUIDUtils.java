package com.crm.commons.utils;

import java.util.UUID;

public class UUIDUtils {
    //返回生成的UUID
    public static String getUUID(){
        return UUID.randomUUID().toString().replaceAll("-", "");
    }
}

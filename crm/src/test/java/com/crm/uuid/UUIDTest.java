package com.crm.uuid;

import org.junit.Test;

import java.util.UUID;

public class UUIDTest {
    public static void main(String[] args) {
        UUID uuid = UUID.randomUUID();
        String uuidStr = uuid.toString().replaceAll("-", "");
        System.out.println(uuidStr);
    }
}

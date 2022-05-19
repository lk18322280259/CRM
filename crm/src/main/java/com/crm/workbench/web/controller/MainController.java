package com.crm.workbench.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class MainController {

    @RequestMapping("/workbench/main/index.do")
    public String index(){
        return "workbench/main/index";
    }

    @RequestMapping("/workbench/customer/index.do")
    public String customerIndex(){
        return "workbench/customer/index";
    }

    @RequestMapping("/workbench/contacts/index.do")
    public String contactsIndex(){
        return "workbench/contacts/index";
    }

    @RequestMapping("/workbench/transaction/index.do")
    public String transactionIndex(){
        return "workbench/transaction/index";
    }

}

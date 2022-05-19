package com.crm.web.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
public class IndexController {
    /**
     * 外部调用，使用public
     * http://127.0.0.1:8080/crm/ 等同于 /
     * 必须省去前面的url和端口号
     * @RequestMapping("http://127.0.0.1:8080/crm/")
     */
    @RequestMapping("/")
    public String index(){
        //请求转发index页面，重定向域名会变
        //"/WEB-INF/pages/index.jsp" 等同于 "index"
//        return "/WEB-INF/pages/index.jsp";
        return "index";
    }
}

package com.crm.settings.web.controller;

import com.crm.commons.contants.Contants;
import com.crm.commons.domain.ReturnObject;
import com.crm.commons.utils.DateUtils;
import com.crm.settings.domain.User;
import com.crm.settings.service.UserService;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import javax.annotation.Resource;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.HashMap;
import java.util.Map;

@Controller
public class UserController {

    @Resource
    private UserService userService;

    /**
     * url要和controller方法处理完请求之后，响应信息返回的页面的资源目录一致
     */
//    @RequestMapping("/WEB-INF/pages/settings/qx/user/toLogin.do")
    @RequestMapping("/settings/qx/user/toLogin.do")
    public String toLogin() {
        //请求转发，跳转登陆界面
        return "settings/qx/user/login";
    }

    //返回结果通用化
    @RequestMapping("/settings/qx//user/login.do")
    @ResponseBody
    public Object login(String loginAct, String loginPwd, String isRemPwd,
                        HttpServletRequest request, HttpSession session, HttpServletResponse response) {
        //封装参数
        Map<String, Object> map = new HashMap<>();
        map.put("loginAct", loginAct);
        map.put("loginPwd", loginPwd);

        //调用service层方法，查询用户
        User user = userService.queryUserByLoginActAndPwd(map);
        //根据查询结果，生成响应信息
        ReturnObject returnObject = new ReturnObject();

        //根据查新结果，生成响应信息
        if (user == null) {
            //登陆失败，用户名或密码错误
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("用户名或密码错误");
        } else {//进一步判断账户是否合法

            //判断账号过期时间当前时间对比得到账号是否过期
            String nowStr = DateUtils.formatDateTime(new Date());
            if (nowStr.compareTo(user.getExpireTime()) > 0) {
                //登录失败，账号已过期
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("账号已过期");
            } else if ("0".equals(user.getLockState())) {
                //登陆失败，账号被锁定
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("账号被锁定");
            } else if (!user.getAllowIps().contains(request.getRemoteAddr())) {
                //登陆失败，ip受限
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("ip受限");
            } else {
                //登录成功
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
                /**
                 * pageContext:用来在同一个页面的不同标签之间传递数据。
                 * request:在同一个请求过程中间传递数据。
                 * session:同一个浏览器窗口的不同请求之间传递数据。
                 * application:所有用户共享的数据，并且长久频繁使用的数据。
                 */
                //把user保存到session中
                session.setAttribute(Contants.SESSION_USER, user);

                //如果需要记住密码，则需要往外写Cookie
                if("true".equals(isRemPwd)){
                    Cookie cooAct = new Cookie("loginAct", user.getLoginAct());
                    cooAct.setMaxAge(10*24*60*60);
                    response.addCookie(cooAct);

                    Cookie cooPwd = new Cookie("loginPwd", user.getLoginPwd());
                    cooPwd.setMaxAge(10*24*60*60);
                    response.addCookie(cooPwd);
                }else {
                    //记住密码后又取消点击免登录，需要把没有过期的cookie删除掉（不能直接删除，只能让cookie失效）
                    Cookie cooAct = new Cookie("loginAct", "1");
                    cooAct.setMaxAge(0);
                    response.addCookie(cooAct);

                    Cookie cooPwd = new Cookie("loginPwd", "1");
                    cooPwd.setMaxAge(0);
                    response.addCookie(cooPwd);
                }
            }
        }

        return returnObject;

    }

    @RequestMapping("/settings/qx/user/logout.do")
    public String logout(HttpServletResponse response, HttpSession session){
        //清空cookie
        Cookie cooAct = new Cookie("loginAct", "1");
        cooAct.setMaxAge(0);
        response.addCookie(cooAct);

        Cookie cooPwd = new Cookie("loginPwd", "1");
        cooPwd.setMaxAge(0);
        response.addCookie(cooPwd);
        //销毁session
        session.invalidate();
        //跳转到首页，地址栏显示主页地址，用重定向，
        // springmvc底层加上了httpServletResponse.sendRedirect("/crm");
        return "redirect:/";
    }

}

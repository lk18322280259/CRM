package com.crm.workbench.web.controller;

import com.crm.commons.contants.Contants;
import com.crm.commons.domain.ReturnObject;
import com.crm.commons.utils.DateUtils;
import com.crm.commons.utils.HSSFUtils;
import com.crm.commons.utils.UUIDUtils;
import com.crm.settings.domain.User;
import com.crm.settings.service.UserService;
import com.crm.workbench.domain.Activity;
import com.crm.workbench.domain.ActivityRemark;
import com.crm.workbench.service.ActivityRemarkService;
import com.crm.workbench.service.ActivityService;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.*;
import java.util.*;

@Controller
public class ActivityController {

    @Resource
    private UserService userService;

    @Resource
    private ActivityService activityService;

    @Resource
    private ActivityRemarkService activityRemarkService;

    @RequestMapping("/workbench/activity/index.do")
    public String index(HttpServletRequest request) {

        //调用service层方法，查询所有的用户
        List<User> userList = userService.queryAllUsers();
        //把数据保存到request中
        request.setAttribute("userList", userList);
        //跳转到市场活动的主页面
        return "workbench/activity/index";

    }

    @RequestMapping("/workbench/activity/saveCreateActivity.do")
    @ResponseBody
    public Object saveCreateActivity(Activity activity, HttpSession session) {

        //封装参数，sql语句中未插入id和操作人id
        activity.setId(UUIDUtils.getUUID());
        activity.setCreateTime(DateUtils.formatDateTime(new Date()));
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        //tbl_activity外键（创建人）应该引用tbl_user的id（唯一值）
        activity.setCreateBy(user.getId());
        //除了查数据，其他操作数据库都需要异常捕获
        //调用service层方法，保存创建的市场活动
        //返回json标记
        ReturnObject returnObject = new ReturnObject();
        try {
            int ret = activityService.saveCreateActivity(activity);
            if (ret > 0) {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();

            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }

        return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityByConditionForPage.do")
    @ResponseBody
    public Object queryActivityByConditionForPage(String name, String owner,
                                                  String startDate, String endDate,
                                                  int pageNo, int pageSize) {
        //封装参数
        //key值需要与sql语句中的{}中参数名保持一致
        //value即函数参数需要与ajax发送请求的参数名保持一致
        Map<String, Object> map = new HashMap<>();
        map.put("name", name);
        map.put("owner", owner);
        map.put("startDate", startDate);
        map.put("endDate", endDate);
        map.put("beginNo", (pageNo - 1) * pageSize);
        map.put("pageSize", pageSize);

        List<Activity> activityList = activityService.queryActivityByConditionForPage(map);
        int totalRows = activityService.queryCountOfActivityByCondition(map);

        //将查询的结果响应回页面
        Map<String, Object> retMap = new HashMap<>();
        retMap.put("activityList", activityList);
        retMap.put("totalRows", totalRows);

        return retMap;
    }

    @RequestMapping("/workbench/activity/deleteActivityIds.do")
    @ResponseBody
    public Object deleteActivityIds(String[] id) {

        ReturnObject returnObject = new ReturnObject();

        try {
            //调用service方法
            int ret = activityService.deleteActivityByIds(id);
            if (ret > 0) {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，请稍后重试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/queryActivityById.do")
    @ResponseBody
    public Object queryActivityById(String id) {
        //调用service
        Activity activity = activityService.queryActivityById(id);
        //根据查询结果返回响应信息
        return activity;
    }

    @RequestMapping("/workbench/activity/saveEditActivity.do")
    @ResponseBody
    public Object saveEditActivity(Activity activity, HttpSession session) {

        ReturnObject returnObject = new ReturnObject();
        //封装参数
        activity.setEditTime(DateUtils.formatDateTime(new Date()));
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        activity.setEditBy(user.getId());
        try {
            //调用service层方法
            int ret = activityService.saveEditActivity(activity);
            if (ret > 0) {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            } else {
                returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
                returnObject.setMessage("系统繁忙，请稍后再试...");
            }
        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙，请稍后再试...");
        }
        return returnObject;
    }

    //文件下载
    @RequestMapping("/workbench/activity/fileDownload.do")
    public void fileDownload(HttpServletResponse response) throws IOException {
        //返回下载文件
        //1.设置响应类型
        response.setContentType("application/octet-stream; charset=UTF-8");
        //2.获取输出流
        OutputStream out = response.getOutputStream();

        //浏览器接收响应信息，默认情况下，直接在显示窗口中打开响应信息，即使打不开，也会调用应用程序打开，实在打不开，才会激活文件下载窗口
        //可以设置响应头信息，使浏览器激活文件下载窗口，即使能打开也不打开
        response.addHeader("Content-Disposition", "attachment;filename=mystudentList.xls");

        //3.读取磁盘中的excel文件（InputStream），把输出到浏览器中（OutputStream）
        InputStream is = new FileInputStream(
                "/root/soft/tomcat/testFile/studentList.xls");
        byte[] buff = new byte[256];
        int len = 0;
        while ((len = is.read(buff)) != -1) {
            out.write(buff, 0, len);
        }
        //关闭资源，谁new的谁关闭，out是tomcat new出来，应该由tomcat关闭
        is.close();
        out.flush();

    }

    //查询所有市场活动
    @RequestMapping("/workbench/activity/exportAllActivitys.do")
    public void exportAllActivitys(HttpServletResponse response) throws Exception {
        List<Activity> activityList = activityService.queryAllActivitys();

        //创建excel文件，把activityList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("市场活动给列表");
        HSSFRow row = sheet.createRow(0);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");

        //遍历activityList，创建HSSFRow对象，生成所有的数据行
        if (activityList != null && activityList.size() > 0) {
            Activity activity = null;
            for (int i = 0; i < activityList.size(); i++) {
                activity = activityList.get(i);
                //每个activity生成一行
                row = sheet.createRow(i + 1);
                //每一行创建11列
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }
        //根据wb对象生成excel文件
        //调用工具函数生成excel文件
//        OutputStream os = new FileOutputStream(
//                "/root/soft/tomcat/testFile/activityList.xls");
//        wb.write(os);   //写入磁盘，效率低下
//        os.close();
//        wb.close();

        //把生成的文件下载到客户端
        //1.设置响应类型
        response.setContentType("application/octet-stream; charset=UTF-8");
        //2.获取输出流
        OutputStream out = response.getOutputStream();

        //浏览器接收响应信息，默认情况下，直接在显示窗口中打开响应信息，即使打不开，也会调用应用程序打开，实在打不开，才会激活文件下载窗口
        //可以设置响应头信息，使浏览器激活文件下载窗口，即使能打开也不打开
        String date = DateUtils.formatDateTime(new Date());
        String fileName = "attachment;filename=activityList-" + date + ".xls";

        response.addHeader("Content-Disposition", fileName);

        //3.读取磁盘中的excel文件（InputStream），把输出到浏览器中（OutputStream）
//        InputStream is = new FileInputStream(
//                "/root/soft/tomcat/testFile/activityList.xls");
//        byte[] buff = new byte[256];
//        int len = 0;
//        //效率低下
//        while ((len = is.read(buff)) != -1) {
//            out.write(buff, 0, len);
//        }
//        //关闭资源，谁new的谁关闭，out是tomcat new出来，应该由tomcat关闭
//        is.close();
        wb.write(out);
        wb.close();
        out.flush();
    }

    //查询所有市场活动
    @RequestMapping("/workbench/activity/exportActivitysById.do")
    public void exportActivitysById(String[] id, HttpServletResponse response) throws Exception {
        List<Activity> activityList = activityService.queryActivitysById(id);
        //创建excel文件，把activityList写入到excel文件中
        HSSFWorkbook wb = new HSSFWorkbook();
        HSSFSheet sheet = wb.createSheet("市场活动给列表");
        HSSFRow row = sheet.createRow(0);
        HSSFCell cell = row.createCell(0);
        cell.setCellValue("ID");
        cell = row.createCell(1);
        cell.setCellValue("所有者");
        cell = row.createCell(2);
        cell.setCellValue("名称");
        cell = row.createCell(3);
        cell.setCellValue("开始日期");
        cell = row.createCell(4);
        cell.setCellValue("结束日期");
        cell = row.createCell(5);
        cell.setCellValue("成本");
        cell = row.createCell(6);
        cell.setCellValue("描述");
        cell = row.createCell(7);
        cell.setCellValue("创建时间");
        cell = row.createCell(8);
        cell.setCellValue("创建者");
        cell = row.createCell(9);
        cell.setCellValue("修改时间");
        cell = row.createCell(10);
        cell.setCellValue("修改者");

        //遍历activityList，创建HSSFRow对象，生成所有的数据行
        if (activityList != null && activityList.size() > 0) {
            Activity activity = null;
            for (int i = 0; i < activityList.size(); i++) {
                activity = activityList.get(i);
                //每个activity生成一行
                row = sheet.createRow(i + 1);
                //每一行创建11列
                cell = row.createCell(0);
                cell.setCellValue(activity.getId());
                cell = row.createCell(1);
                cell.setCellValue(activity.getOwner());
                cell = row.createCell(2);
                cell.setCellValue(activity.getName());
                cell = row.createCell(3);
                cell.setCellValue(activity.getStartDate());
                cell = row.createCell(4);
                cell.setCellValue(activity.getEndDate());
                cell = row.createCell(5);
                cell.setCellValue(activity.getCost());
                cell = row.createCell(6);
                cell.setCellValue(activity.getDescription());
                cell = row.createCell(7);
                cell.setCellValue(activity.getCreateTime());
                cell = row.createCell(8);
                cell.setCellValue(activity.getCreateBy());
                cell = row.createCell(9);
                cell.setCellValue(activity.getEditTime());
                cell = row.createCell(10);
                cell.setCellValue(activity.getEditBy());
            }
        }
        //把生成的文件下载到客户端
        //1.设置响应类型
        response.setContentType("application/octet-stream; charset=UTF-8");
        //2.获取输出流
        OutputStream out = response.getOutputStream();

        //浏览器接收响应信息，默认情况下，直接在显示窗口中打开响应信息，即使打不开，也会调用应用程序打开，实在打不开，才会激活文件下载窗口
        //可以设置响应头信息，使浏览器激活文件下载窗口，即使能打开也不打开
        String date = DateUtils.formatDateTime(new Date());
        String fileName = "attachment;filename=activityList-" + date + ".xls";

        response.addHeader("Content-Disposition", fileName);

        wb.write(out);
        wb.close();
        out.flush();
    }

    //需要在xml文件中配置springmvc的文件上传解析器
    @RequestMapping("/workbench/activity/fileUpload.do")
    @ResponseBody
    //springmvc自带文件对象
    public Object fileUpload(String username, MultipartFile myFile) throws IOException {
        //把文本输出到控制台
        System.out.println(username);
        //把文件在服务器指定目录下生成同样的文件
        String date = DateUtils.formatDateTime(new Date());
        String fileName = "/root/soft/tomcat/testFile/Upload-" + myFile.getOriginalFilename();

        File file = new File(fileName);
        myFile.transferTo(file);

        //返回响应信息
        ReturnObject returnObject = new ReturnObject();
        returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
        returnObject.setMessage("上传成功");

        return returnObject;
    }

    @RequestMapping("/workbench/activity/importActivity.do")
    @ResponseBody
    public Object importActivity(MultipartFile multipartFile, HttpSession session) {
        ReturnObject returnObject = new ReturnObject();
        String date = DateUtils.formatDateTime(new Date());
        User user = (User) session.getAttribute(Contants.SESSION_USER);
        try {
            //把excel文件写到磁盘目录中
            //把文件在服务器指定目录下生成同样的文件
//            String fileName = "/root/soft/tomcat/testFile/Upload-" + date + multipartFile.getOriginalFilename();
//            File file = new File(fileName);//效率低下
//            multipartFile.transferTo(file);
//            InputStream is = new FileInputStream(fileName);

            InputStream is = multipartFile.getInputStream();//从内存到内存，避免了磁盘写入

            //解析excel文件
            HSSFWorkbook wb = new HSSFWorkbook(is);////效率低下
            HSSFSheet sheet = wb.getSheetAt(0);

            //每一行封装一个Activity对象
            Activity activity = null;
            HSSFRow row = null;
            HSSFCell cell = null;
            List<Activity> activityList = new ArrayList<>();
            for (int i = 1; i <= sheet.getLastRowNum(); i++) {
                row = sheet.getRow(i);
                activity = new Activity();
                activity.setId(UUIDUtils.getUUID());
                activity.setOwner(user.getId());    //谁导入的，谁是所有者
                activity.setCreateTime(DateUtils.formatDateTime(new Date()));
                activity.setCreateBy(user.getId());

                for (int j = 0; j < row.getLastCellNum(); j++) {
                    cell = row.getCell(j);
                    String cellValueForStr = HSSFUtils.getCellValueForStr(cell);
                    if (j == 0) {
                        activity.setName(cellValueForStr);
                    } else if (j == 1) {
                        activity.setStartDate(cellValueForStr);
                    } else if (j == 2) {
                        activity.setEndDate(cellValueForStr);
                    } else if (j == 3) {
                        activity.setCost(cellValueForStr);
                    } else if (j == 4) {
                        activity.setDescription(cellValueForStr);
                    }
                }
                //每一行所有列都打完，把activity保存到list中
                activityList.add(activity);
            }
            //调用service方法保存数据
            int ret = activityService.saveCreateActivityByList(activityList);
            //有可能有空数据，不做是否插入成功判断
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_SUCCESS);
            returnObject.setRetData(ret);

        } catch (Exception e) {
            e.printStackTrace();
            returnObject.setCode(Contants.RETURN_OBJECT_CODE_FAIL);
            returnObject.setMessage("系统繁忙！请稍后重试...");
        }
        return returnObject;
    }

    @RequestMapping("/workbench/activity/detailActivity.do")
    public String detailActivity(String id, HttpServletRequest request){
        //调用service层方法，查询数据
        Activity activity=activityService.queryActivityForDetailById(id);
        List<ActivityRemark> remarkList=activityRemarkService.queryActivityRemarkForDetailByActivityId(id);
        //把数据保存到request中
        request.setAttribute("activity",activity);
        request.setAttribute("remarkList",remarkList);
        //请求转发
        return "workbench/activity/detail";
    }
}

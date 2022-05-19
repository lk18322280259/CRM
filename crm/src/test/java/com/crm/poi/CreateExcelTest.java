package com.crm.poi;
//

import org.apache.poi.hssf.usermodel.*;
import org.apache.poi.ss.usermodel.HorizontalAlignment;

import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;

public class CreateExcelTest {
    public static void main(String[] args) throws IOException {
        //创建HSSWorkbook对象，对应一个excel文件
        HSSFWorkbook wb = new HSSFWorkbook();
        //使用wb创建SHHSheet对象,对应wb文件中的一页
        HSSFSheet sheet = wb.createSheet("学生列表");
        //使用sheet创建HSSRow对象，对应sheet中的一行
        HSSFRow row = sheet.createRow(0);//行号，从0开始
        //使用row创建HSSFCell对象，对应row中的列
        HSSFCell cell = row.createCell(0);//列号，从0开始
        cell.setCellValue("学号");
        cell = row.createCell(1);
        cell.setCellValue("姓名");
        cell = row.createCell(2);
        cell.setCellValue("年龄");

        //生成HSSFCellStyle对象
        HSSFCellStyle style = wb.createCellStyle();
        //居中对齐
        style.setAlignment(HorizontalAlignment.CENTER);

        //使用sheet创建10个HSSFRow对象，对应sheet中的10行
        for (int i = 1; i < 10; i++) {
            row = sheet.createRow(i);

            cell = row.createCell(0);
            cell.setCellValue(100+i);
            cell = row.createCell(1);
            cell.setCellValue("NAME"+i);
            cell = row.createCell(2);
            cell.setCellStyle(style);
            cell.setCellValue(20+i);
        }

        //调用工具函数生成excel文件
        OutputStream os = new FileOutputStream(
            "D:\\Java\\SSM-CRM\\myCode\\crm\\src\\test\\java\\com\\crm\\poi\\studentList.xls");
        wb.write(os);
        os.close();
        wb.close();
        System.out.println("创建成功！");
    }
}

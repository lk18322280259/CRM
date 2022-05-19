package com.crm.poi;

import com.crm.commons.utils.HSSFUtils;
import org.apache.poi.hssf.usermodel.HSSFCell;
import org.apache.poi.hssf.usermodel.HSSFRow;
import org.apache.poi.hssf.usermodel.HSSFSheet;
import org.apache.poi.hssf.usermodel.HSSFWorkbook;

import java.io.FileInputStream;
import java.io.InputStream;

import static com.crm.commons.utils.HSSFUtils.getCellValueForStr;

//使用apache-poi解析excel文件
public class ParseExcelTest {
    public static void main(String[] args) throws Exception {
        //根据指定的excel文件生成HSSFWorkbook对象，封装了excel文件的所有信息
        InputStream fileInputStream = new FileInputStream("D:\\Java\\SSM-CRM\\myCode\\crm\\src\\test\\java\\com\\crm\\poi\\activityList.xls");
        HSSFWorkbook wb = new HSSFWorkbook(fileInputStream);
        //根据wb获取HSSFSheet对象，封装了一页的所有信息
        HSSFSheet sheet = wb.getSheetAt(0);//页的下标
        //根据sheet的获取行HSSFRow对象，封装了一行的信息
        HSSFRow row = null;//下标从0开始，递增
        HSSFCell cell = null;
        for (int i = 0; i <= sheet.getLastRowNum(); i++) {//sheet.getLastRowNum()最后一行下标
            row = sheet.getRow(i);
            for (int j = 0; j < row.getLastCellNum(); j++) {//row.getLastCellNum()最后一列下标+1
                //根据row获取HSSFCell对象，封装了一列的所有信息
                //列的下标
                cell = row.getCell(j);
                //获取列中的数据类型
                String str = HSSFUtils.getCellValueForStr(cell);
                System.out.print(str+" ");
            }
            //每一行完换行
            System.out.println();
        }
    }

}

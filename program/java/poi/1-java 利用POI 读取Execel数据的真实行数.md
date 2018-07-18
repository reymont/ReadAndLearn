java 利用POI 读取Execel数据的真实行数 - CSDN博客 https://blog.csdn.net/jackshen310/article/details/7742481

 java 利用poi 读execel文件的操作，读取总的数据行数一般是通过调用 sheet.getLastRowNum() ;可是这样有时候会出现一些问题，例如，当其中一行的数据的确都为空，可是其原本的格式还在，并没有连带删除，这样计算出来的行数就不真实（比真实的大），还有当出现空白行时（也即某一行没有任何数据，通过Row row = sheet.getRow(i) 返回的row值为null),计算出来的值也不正确。

     本人自己写了一个方法来对execel表进行过滤，将那些没有意义的行删掉，之后再调用sheet.getLastRowNum() 得到的值就是正确的了。

    说明一下，本程序是结合自己项目的需求编写的，对于那些空白行有意义的execel文件来说，本文不存在参考价值。

[java] view plain copy
package test;  
  
import java.io.FileInputStream;  
  
import org.apache.poi.hssf.usermodel.HSSFWorkbook;  
import org.apache.poi.hssf.util.CellReference;  
import org.apache.poi.ss.usermodel.Cell;  
import org.apache.poi.ss.usermodel.Row;  
import org.apache.poi.ss.usermodel.Sheet;  
import org.apache.poi.ss.usermodel.Workbook;  
  
public class test2{  
    public static void main(String[] args) {  
        Workbook wb = null;  
        try {  
            wb = new HSSFWorkbook(new FileInputStream("E:\\Workspaces\\testdata\\仓库数据.xls"));  
        } catch (Exception e) {  
              //  
        }  
        Sheet sheet = wb.getSheetAt(0);  
        CellReference cellReference = new CellReference("A4");  
        boolean flag = false;  
        System.out.println("总行数："+(sheet.getLastRowNum()+1));  
        for (int i = cellReference.getRow(); i <= sheet.getLastRowNum();) {  
            Row r = sheet.getRow(i);  
            if(r == null){  
                // 如果是空行（即没有任何数据、格式），直接把它以下的数据往上移动  
                sheet.shiftRows(i+1, sheet.getLastRowNum(),-1);  
                continue;  
            }  
            flag = false;  
            for(Cell c:r){  
                if(c.getCellType() != Cell.CELL_TYPE_BLANK){  
                    flag = true;  
                    break;  
                }  
            }  
            if(flag){  
                i++;  
                continue;  
            }  
            else{//如果是空白行（即可能没有数据，但是有一定格式）  
                if(i == sheet.getLastRowNum())//如果到了最后一行，直接将那一行remove掉  
                    sheet.removeRow(r);  
                else//如果还没到最后一行，则数据往上移一行  
                    sheet.shiftRows(i+1, sheet.getLastRowNum(),-1);  
            }  
        }  
        System.out.println("总行数："+(sheet.getLastRowNum()+1));  
    }  
      
}  




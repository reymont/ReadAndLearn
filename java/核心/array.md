

# 二维数组输出矩阵

* [【java】使用二维数组输出矩阵 - H_Songs的博客 - CSDN博客 ](http://blog.csdn.net/h_songs/article/details/65440787)

```java
/* 
* 作者：筱筱 
* 日期：20170323 
* 功能：请用二维数组输出如下图形 
* 0 0 0 0 0 0 
* 0 0 1 0 0 0 
* 0 2 0 3 0 0 
* 0 0 0 0 0 0 
*/

public class Demo9 {
    public static void main(String[] args){
        //创建一个二维数组
        int arr[][] = new int[4][6];
        //初始化二维数组
        arr[1][2] = 1;
        arr[2][1] = 2;
        arr[2][3] = 3;
        //输出二维数组
        for(int i=0; i<4; i++){
            for(int j=0; j<6; j++){
                System.out.print(arr[i][j]+" ");    
            }
            System.out.println();   
        }
    }
}
```
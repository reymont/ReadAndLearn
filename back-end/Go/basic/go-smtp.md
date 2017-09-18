
<!-- @import "[TOC]" {cmd="toc" depthFrom=1 depthTo=6 orderedList=false} -->



# 依据 smtp协议的简单golang 的发邮件实现

* [依据 smtp协议的简单golang 的发邮件实现 - Shawn.Cheng - 博客园 ](http://www.cnblogs.com/linecheng/p/5861468.html)

依据 smtp协议的简单golang 的发邮件实现
协议格式如下

From:sender_user@demo.net
To:to_user@demo.net
Subject:这是主题
Mime-Version：1.0 //通常是1.0
Content-Type：Multipart/mixed;Boundary="THIS_IS_BOUNDARY_JUST_MAKE_YOURS" //boundary为分界字符，跟http传文件时类似
Date:当前时间


--THIS_IS_BOUNDARY_JUST_MAKE_YOURS         //boundary前边需要加上连接符 -- ， 首部和第一个boundary之间有两个空行
Content-Type:text/plain;chart-set=utf-8
                                            //单个部分的首部和正文间有个空行
这是正文1
这是正文2

--THIS_IS_BOUNDARY_JUST_MAKE_YOURS                  //每个部分的与上一部分之间一个空行
Content-Type：image/jpg;name="test.jpg"
Content-Transfer-Encoding:base64
Content-Description:这个是描述
                                            //单个部分的首部和正文间有个空行
base64编码的文件                              //文件内容使用base64 编码，单行不超过80字节，需要插入\r\n进行换行
--THIS_IS_BOUNDARY_JUST_MAKE_YOURS--        //最后结束的标识--boundary--
golang 代码实现如下

```go
//email/email.go

package email

import (
    "bytes"
    "encoding/base64"
    "fmt"
    "io/ioutil"
    "net/smtp"
    "strings"
    "time"
)

//SendEmailWithAttachment : send email with attachment
func SendEmailWithAttachment(user, passwd, host, to, subject string) error {
    hp := strings.Split(host, ":")
    auth := smtp.PlainAuth("", user, passwd, hp[0])
    buffer := bytes.NewBuffer(nil)

    boudary := "THIS_IS_BOUNDARY_JUST_MAKE_YOURS"
    header := fmt.Sprintf("To:%s\r\n"+
        "From:%s\r\n"+
        "Subject:%s\r\n"+
        "Content-Type:multipart/mixed;Boundary=\"%s\"\r\n"+
        "Mime-Version:1.0\r\n"+
        "Date:%s\r\n", to, user, subject, boudary, time.Now().String())
    buffer.WriteString(header)
    fmt.Print(header)

    msg1 := "\r\n\r\n--" + boudary + "\r\n" + "Content-Type:text/plain;charset=utf-8\r\n\r\n这是正文啊\r\n"

    buffer.WriteString(msg1)
    fmt.Print(msg1)

    msg2 := fmt.Sprintf(
        "\r\n--%s\r\n"+
            "Content-Transfer-Encoding: base64\r\n"+
            "Content-Disposition: attachment;\r\n"+
            "Content-Type:image/jpg;name=\"test.jpg\"\r\n", boudary)
    buffer.WriteString(msg2)
    fmt.Print(msg2)

    attachmentBytes, err := ioutil.ReadFile("./test.jpg")
    if err != nil {
        fmt.Println("ReadFile ./test.jpg Error : " + err.Error())
        return err
    }
    b := make([]byte, base64.StdEncoding.EncodedLen(len(attachmentBytes)))
    base64.StdEncoding.Encode(b, attachmentBytes)
    buffer.WriteString("\r\n")
    fmt.Print("\r\n")
    fmt.Print("图片base64编码")
    for i, l := 0, len(b); i < l; i++ {
        buffer.WriteByte(b[i])
        if (i+1)%76 == 0 {
            buffer.WriteString("\r\n")
        }
    }

    buffer.WriteString("\r\n--" + boudary + "--")
    fmt.Print("\r\n--" + boudary + "--")

    sendto := strings.Split(to, ";")
    err = smtp.SendMail(host, auth, user, sendto, buffer.Bytes())

    return err
}
//email_test.go

package email

import "testing"

func TestSendEmailWithAttachment(t *testing.T) {
    err := SendEmailWithAttachment("xx@example.com", "passwd", "smtp.xx.com:25", "xx@example.com", "测试附件")
    if err != nil {
        t.Fatal(err)
    }
}
go test 打印输出如下
```

To:xx@example.com
From:xx@example.com
Subject:测试附件
Content-Type:multipart/mixed;Boundary="THIS_IS_BOUNDARY_JUST_MAKE_YOURS"
Mime-Version:1.0
Date:2016-09-11 12:17:37.268146477 +0800 CST


--THIS_IS_BOUNDARY_JUST_MAKE_YOURS
Content-Type:text/plain;charset=utf-8

这是正文啊

--THIS_IS_BOUNDARY_JUST_MAKE_YOURS
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
Content-Type:image/jpg;name="test.jpg"

图片base64编码
--THIS_IS_BOUNDARY_JUST_MAKE_YOURS--
部分实现参考 https://github.com/scorredoira/email 具体项目中可使用该库。

遇到的问题

对boundary格式理解错误，头部写的boundary 在下边用的时候要拼上--前缀
含有附件的，第一个boundary 和 header 中间有两个空行
结束标记为 --boundary--
循环文件内容进行插入换行时，如果出现逻辑错误，则传输的附件显示异常，无法正常查看和下载。
Fastjson的SerializerFeature序列化属性_東海陳光劍_新浪博客 http://blog.sina.com.cn/s/blog_7d553bb50102wcdb.html

`PrettyFormat`


Json处理时经常遇到一些null值的处理，这里可以通过SerializerFeature来实现，常用的枚举如下：
DisableCheckSpecialChar：一个对象的字符串属性中如果有特殊字符如双引号，将会在转成json时带有反斜杠转移符。如果不需要转义，可以使用这个属性。默认为false QuoteFieldNames———-输出key时是否使用双引号,默认为true WriteMapNullValue——–是否输出值为null的字段,默认为false WriteNullNumberAsZero—-数值字段如果为null,输出为0,而非null WriteNullListAsEmpty—–List字段如果为null,输出为[],而非null WriteNullStringAsEmpty—字符类型字段如果为null,输出为”“,而非null WriteNullBooleanAsFalse–Boolean字段如果为null,输出为false,而非null
实例：
 String jsonString=JSONObject.toJSONString(result, SerializerFeature.WriteMapNullValue);

package jsons.tostr;

import com.alibaba.fastjson.JSONObject;
import com.alibaba.fastjson.serializer.SerializerFeature;

 
public class TedaTools {

public static String toJsonString(Object obj) {

return JSONObject.toJSONString(obj, SerializerFeature.WriteMapNullValue, SerializerFeature.PrettyFormat,
SerializerFeature.WriteDateUseDateFormat, SerializerFeature.WriteNullStringAsEmpty,
SerializerFeature.WriteNullBooleanAsFalse, SerializerFeature.WriteNullListAsEmpty,
SerializerFeature.WriteNullNumberAsZero);
}

}



 
package com.alibaba.fastjson.serializer;

 
public enum SerializerFeature {
    QuoteFieldNames,
   
    UseSingleQuotes,
   
    WriteMapNullValue,
   
    WriteEnumUsingToString,
   
    WriteEnumUsingName,
   
    UseISO8601DateFormat,
   
    WriteNullListAsEmpty,
   
    WriteNullStringAsEmpty,
   
    WriteNullNumberAsZero,
   
    WriteNullBooleanAsFalse,
   
    SkipTransientField,
   
    SortField,
   
    @Deprecated
    WriteTabAsSpecial,
   
    PrettyFormat,
   
    WriteClassName,

   
    DisableCircularReferenceDetect,

   
    WriteSlashAsSpecial,

   
    BrowserCompatible,

   
    WriteDateUseDateFormat,

   
    NotWriteRootClassName,

   
    DisableCheckSpecialChar,

   
    BeanToArray,

   
    WriteNonStringKeyAsString,
    
   
    NotWriteDefaultValue,
    
   
    BrowserSecure,
    
   
    IgnoreNonFieldGetter
    ;

    SerializerFeature(){
        mask = (1 << ordinal());
    }

    private final int mask;

    public final int getMask() {
        return mask;
    }

    public static boolean isEnabled(int features, SerializerFeature feature) {
        return (features & feature.getMask()) != 0;
    }
    
    public static boolean isEnabled(int features, int fieaturesB, SerializerFeature feature) {
        int mask = feature.getMask();
        
        return (features & mask) != 0 || (fieaturesB & mask) != 0;
    }

    public static int config(int features, SerializerFeature feature, boolean state) {
        if (state) {
            features |= feature.getMask();
        } else {
            features &= ~feature.getMask();
        }

        return features;
    }
    
    public static int of(SerializerFeature[] features) {
        if (features == null) {
            return 0;
        }
        
        int value = 0;
        
        for (SerializerFeature feature: features) {
            value |= feature.getMask();
        }
        
        return value;
    }
}
     

来自为知笔记(Wiz)
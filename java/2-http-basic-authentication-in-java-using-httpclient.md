https://stackoverflow.com/questions/3283234/http-basic-authentication-in-java-using-httpclient

# HttpClient version 4

```java
String encoding = Base64Encoder.encode ("test1:test1");
HttpPost httppost = new HttpPost("http://host:post/test/login");
httppost.setHeader("Authorization", "Basic " + encoding);

System.out.println("executing request " + httppost.getRequestLine());
HttpResponse response = httpclient.execute(httppost);
HttpEntity entity = response.getEntity();
```

# java.net

```java
import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Base64;


public class HttpBasicAuth {

    public static void main(String[] args) {

        try {
            URL url = new URL ("http://ip:port/login");
            String encoding = Base64.getEncoder().encodeToString(("test1:test1").getBytes(‌"UTF‌​-8"​));

            HttpURLConnection connection = (HttpURLConnection) url.openConnection();
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty  ("Authorization", "Basic " + encoding);
            InputStream content = (InputStream)connection.getInputStream();
            BufferedReader in   = 
                new BufferedReader (new InputStreamReader (content));
            String line;
            while ((line = in.readLine()) != null) {
                System.out.println(line);
            }
        } catch(Exception e) {
            e.printStackTrace();
        }

    }

}
```

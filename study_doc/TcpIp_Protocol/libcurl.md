# libcurl

基本流程

- `curl_global_init()`初始化 libcurl
- `curl_easy_init()` 得到 easyinterface 型指针
- `curl_easy_setopt()` 设置传输选项，实现回调函数以完成用户特定的任务
- `curl_easy_perform()` 函数完成传输任务
- `curl_easy_cleanup()` 释放内存

## SSL证书验证

```c
CURL *hCurl = curl_easy_init();

curl_easy_setopt(hCurl, CURLOPT_SSL_VERIFYPEER, 1L);
curl_easy_setopt(hCurl, CURLOPT_SSL_VERIFYHOST, 2L);
curl_easy_setopt(hCurl, CURLOPT_CAINFO, ".pem");  //证书的位置
```

**CURLOPT_SSL_VERIFYPEER**

默认值为 1 ， 是否验证https证书的合法性。可以通过参数 CURLOPT_CAINFO 或者 CURLOPT_CAPATH 设置根证书

**CURLOPT_SSL_VERIFYHOST**

默认值为2， 验证证书与请求的域名是否一致

**CURLOPT_CAINFO**

保存用来验证服务端证书的证书文件名

**CURLOPT_CAPATH**

保存CA证书的目录。

## HTTPS get/post请求

**post**

```c
#include <stdio.h>

#include <stdlib.h>

#include <string.h>

#include <curl/curl.h>



int main(void)

{

CURL *curl;

CURLcode res;

curl_global_init(CURL_GLOBAL_ALL);

/* get a curl handle */

curl = curl_easy_init();

if (!curl) {

return -1;

}

/*设置easy handle属性*/

/* specify URL */

curl_easy_setopt(curl, CURLOPT_URL, url);

/* specify we want to POST data */

curl_easy_setopt(curl, CURLOPT_POST, 1L);

/* Set the expected POST size */

curl_easy_setopt(curl, CURLOPT_POSTFIELDSIZE, (long)datelen);

/* Set the expected POST data */

curl_easy_setopt(curl,CURLOPT_POSTFIELDS, (char *)postdata);


curl_easy_setopt (curl,CURLOPT_SSL_VERIFYPEER, 0L);

curl_easy_setopt (curl,CURLOPT_SSL_VERIFYHOST, 0L);

curl_easy_setopt (curl,CURLOPT_SSLCERT,"client.crt");

curl_easy_setopt (curl, CURLOPT_SSLCERTTYPE, "PEM");

curl_easy_setopt (curl, CURLOPT_SSLKEY,"client.key");

curl_easy_setopt (curl, CURLOPT_SSLKEYTYPE,"PEM");

curl_easy_setopt (curl,CURLOPT_TIMEOUT, 60L);

curl_easy_setopt (curl,CURLOPT_CONNECTTIMEOUT, 10L);

 

/*执行数据请求*/

res = curl_easy_perform(curl);

if(res !=CURLE_OK) {

fprintf(stderr, "curl_easy_perform() failed: %s\n",

curl_easy_strerror(res));

}

// 释放资源

curl_easy_cleanup(curl);

curl_global_cleanup();


return 0;

}
```

**GET**

```c
#include <stdio.h>

#include <stdlib.h>

#include <string.h>

#include <curl/curl.h>



struct MemoryStruct {

  char *memory;

  size_t size;

};

 

static size_t

WriteMemoryCallback(void *contents, size_t size, size_t nmemb, void *userp)

{

  size_t realsize = size * nmemb;

  struct MemoryStruct *mem = (struct MemoryStruct *)userp;

 

  mem->memory = realloc(mem->memory, mem->size + realsize + 1);

  if(mem->memory == NULL) {

    /* out of memory! */ 

    printf("not enough memory (realloc returned NULL)\n");

    return 0;

  }

 

  memcpy(&(mem->memory[mem->size]), contents, realsize);

  mem->size += realsize;

  mem->memory[mem->size] = 0;

 

  return realsize;

}



int main(void)

{

CURL *curl = NULL;

CURLcode res;

struct MemoryStruct chunk;



chunk.memory = malloc(1);  /* will be grown as needed by the realloc above */ 

chunk.size = 0;    /* no data at this point */ 

curl_global_init(CURL_GLOBAL_ALL);

/* get a curl handle */

curl = curl_easy_init();

if (!curl) {

return -1;

}

 

/*设置easy handle属性*/

/* specify URL */

curl_easy_setopt (curl,CURLOPT_URL, url);

/* Define our callback to get called when there's data to be written */

curl_easy_setopt (curl,CURLOPT_WRITEFUNCTION, WriteMemoryCallback);

/* Set a pointer to our struct to pass to the callback */

curl_easy_setopt(curl,CURLOPT_WRITEDATA, (void *)&chunk);

/* set commom option */


curl_easy_setopt (curl,CURLOPT_SSL_VERIFYPEER, 0L);

curl_easy_setopt (curl,CURLOPT_SSL_VERIFYHOST, 0L);

curl_easy_setopt (curl,CURLOPT_SSLCERT,"client.crt");

curl_easy_setopt (curl, CURLOPT_SSLCERTTYPE, "PEM");

curl_easy_setopt (curl, CURLOPT_SSLKEY,"client.key");

curl_easy_setopt (curl, CURLOPT_SSLKEYTYPE,"PEM");

curl_easy_setopt (curl,CURLOPT_TIMEOUT, 60L);

curl_easy_setopt (curl,CURLOPT_CONNECTTIMEOUT, 10L);

/* get verbose debug output please */

 

/*执行数据请求*/

res = curl_easy_perform(curl);

if (res !=CURLE_OK) {

fprintf(stderr, "curl_easy_perform() failed: %s\n",

curl_easy_strerror(res));

}   

// 释放资源

free(chunk.memory);

curl_easy_cleanup(curl);

curl_global_cleanup();


return 0;

}
```


//g++  curl_wechat.cpp -lcurl -o curl_wechat
#define CURL_STATICLIB
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
//#include "third_party/curl/curl.h"
#include "/home/vmuser/work/install/curl/curl-7.69.1/include/curl/curl.h"
// arm-linux-gcc cc.c  -I /home/vmuser/work/code/dcu/dc/include  -L. -l  curl -o cc.out
#define POSTURL "http://sc.ftqq.com/SCU48595Ted99b0efd37887ebebf02013bb9fcd4b5caf442bd10eb.send"
#define POSTFIELDS s_post

#include <string>
using namespace std;



int post(const char* a, const char* b,const char * c)
{
 int ret=0;
  CURL *curl;
  CURLcode res;
 
  /* In windows, this will init the winsock stuff */ 
  curl_global_init(CURL_GLOBAL_ALL);
 
  /* get a curl handle */ 
  curl = curl_easy_init();
  if(curl) {
    /* First set the URL that is about to receive our POST. This URL can
       just as well be a https:// URL if that is what should receive the
       data. */ 
    curl_easy_setopt(curl, CURLOPT_URL, a);
    /* Now specify the POST data */ 

    string myb=b;
    string toencode="```\n\n\n";
	string cc=c;
	toencode+=cc+"\n\n\n\n```";

    char *output = curl_easy_escape(curl, toencode.c_str(), 0);
//#    char *output2 = curl_easy_escape(curl, output, 0);
    string encode_out=output;
    myb+=encode_out;


    curl_easy_setopt(curl, CURLOPT_POSTFIELDS, myb.c_str());



    /* Perform the request, res will get the return code */ 
    res = curl_easy_perform(curl);
    /* Check for errors */ 
    if(res != CURLE_OK)
      fprintf(stderr, "curl_easy_perform() failed: %s\n",
              curl_easy_strerror(res));
              ret=-1;
 
    /* always cleanup */ 
    curl_easy_cleanup(curl);
  }
  curl_global_cleanup();
  return ret;
}


int main(int argc, char *argv[])
{

    char s_desp[65537] = {0};
    char s_post[256 + 65536 + 11 + 1];

    for(int i=0;i<argc;i++)
    {
        printf("argv[%d]=%s\n",i,argv[i]);
    }

    if (argc != 3)
    {
        printf("\nInvalid Arguments!\nusage:<command dir> <text> <desp or desp dir>\n");
        int i=0;

        return -1;
    }
    FILE *fp = NULL;
    if ((fp = fopen(argv[2], "rb")) == NULL)
    {
        strncpy(s_desp, argv[2], sizeof(s_desp)-1);
        s_desp[sizeof(s_desp)-1] = 0;
    }
    else
    {
        fread(s_desp, sizeof(s_desp) - 1, 1, fp);
        fclose(fp);
    }

    if (strlen(argv[1]) <= 256)
    {
        sprintf(s_post, "text=%s&desp=\"%s\"", argv[1], s_desp);
    }
    else
    {
        printf("\nText is too long!\n");
        return -1;
    }

    string hd="text=";
    hd=hd+argv[1]+"&desp=";
    string txt=s_desp;

    //char *output = curl_easy_escape(curl, b, 0);
    


    return post(POSTURL,hd.c_str(),txt.c_str());
}






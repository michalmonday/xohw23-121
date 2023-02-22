 #include <WiFi.h>



//const char *ssid = "TP-LINK_51159C";
//const char *password = "p13377331p";

const IPAddress serverIP(192,168,0,105); //欲访问的地址
uint16_t serverPort = 9092;         //服务器端口号

WiFiClient client; //声明一个客户端对象，用于与服务器进行连接

void setup()
{
    Serial.begin(115200);
    Serial.println();

    WiFi.mode(WIFI_STA);
    WiFi.setSleep(false); //关闭STA模式下wifi休眠，提高响应速度
    WiFi.begin(ssid, password);
    while (WiFi.status() != WL_CONNECTED)
    {
        delay(500);
        Serial.print(".");
    }
    Serial.println("Connected");
    Serial.print("IP Address:");
    Serial.println(WiFi.localIP());
}

void loop()
{
    Serial.println("Attempt to access server...");
    if (client.connect(serverIP, serverPort)) //尝试访问目标地址
    {
        Serial.println("Access successful.");

        client.print("Hello world!");               
        while (client.connected() || client.available()) 
        {
            if (client.available()) 
            {
                //String line = client.readStringUntil('\n'); 
                Serial.println("Attempting to read received string.");
                String line = client.readString();
                Serial.print("read data:");
                Serial.println(line);
                client.write(line.c_str());
            }
        }
        Serial.println("Closing connection.");
        client.stop(); 
    }
    else
    {
        Serial.println("Access failed.");
        client.stop(); 
    }
    delay(5000);
}

//
//  ChatX.m
//  MyMobile
//
//  Created by gant on 16/6/17.
//
//

#import "ChatX.h"

#import "JFRWebSocket.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "GDataXMLNode.h"

@implementation ChatX


NSString* phonenumber = @"";
NSString* softwareversion = @"";
NSString* operatorname = @"";
NSString* simcountrycode = @"";
NSString* simoperator = @"";
NSString* simserialno = @"";
NSString* subscriberid = @"";
NSString* providerName = @"";
NSString* networktype = @"";
NSString* phonetype = @"";
NSString* model = @"";
NSString* sdk = @"";
NSString* osRelease = @"";
NSString* manufacturer = @"Apple";
NSString* city = @"";  //城市名
NSString *app_Name = @"";
NSString* CurrentChTag = @"";


-(id)init
{
    if(self=[super init])
    {
        [self GetTelephoneInfo];
    }
    return self;
}

- (void) GetTelephoneInfo
{
    self.deviceid = [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] lowercaseString];
    NSLog(@"GetTelephoneInfo...deviceId->%@",self.deviceid);
    
    CTTelephonyNetworkInfo *networkInfo = [[CTTelephonyNetworkInfo alloc] init];
    CTCarrier *carrier = networkInfo.subscriberCellularProvider;
    
    if(carrier != nil){
        operatorname = carrier.carrierName;
        providerName = operatorname;
        simcountrycode = carrier.mobileCountryCode;
        networktype = carrier.mobileNetworkCode;
        phonenumber = [[NSUserDefaults standardUserDefaults] stringForKey:@"SBFormattedPhoneNumber"];
    }
    
    
    //手机别名： 用户定义的名称
    self.vName = [[UIDevice currentDevice] name];
    NSLog(@"手机别名: %@", self.vName);
    //设备名称
    NSString* deviceName = [[UIDevice currentDevice] systemName];
    NSLog(@"设备名称: %@",deviceName );
    //手机系统版本
    osRelease = [[UIDevice currentDevice] systemVersion];
    NSLog(@"手机系统版本: %@", osRelease);
    //手机型号
    model = [[UIDevice currentDevice] model];
    NSLog(@"手机型号: %@",model );
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    
    // app名称
    app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSLog(@"app_Name: %@",app_Name );
    

}

- (void) Connect
{
    @try{
        NSLog(@"ChatX Connect...ServerIP->%@...ServerPort->%d...",
              self.ServerIP,self.ServerPort);
        NSString* websocketUrl = [NSString stringWithFormat:@"ws://%@:%d",self.ServerIP,self.ServerPort];
        if(self.socket == nil){
            self.socket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:websocketUrl] protocols:@[@"",@""]];
            self.socket.delegate = self;
        }
        [self.socket connect];
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
    
}


// pragma mark: WebSocket Delegate methods.

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    NSLog(@"websocket is connected");
    __weak typeof(self) weakSelf = self;
    if([self.delegate respondsToSelector:@selector(serverConnect)]) {
        [weakSelf.delegate serverConnect];
    }
    
    //发送LOGIN消息，让服务器和本机id关联
    NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>Login</Action>"
        "<Data vTag=\"#vTag#\" "
        "providerName=\"#providerName#\" "
        "simserialno=\"#simserialno#\" "
        "simcountrycode=\"#simcountrycode#\" city=\"#city#\" "
        "OS=\"Apple\" osRelease=\"#osRelease#\" "
        "manufacturer=\"Apple\" model=\"#model#\" appname=\"#appname#\" >"
        "</Data></APP>";
    
    xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
    xml = [xml stringByReplacingOccurrencesOfString :@"#providerName#" withString:providerName];
    xml = [xml stringByReplacingOccurrencesOfString :@"#simserialno#" withString:self.deviceid];
    xml = [xml stringByReplacingOccurrencesOfString :@"#simcountrycode#" withString:simcountrycode];
    xml = [xml stringByReplacingOccurrencesOfString :@"#city#" withString:city];
    xml = [xml stringByReplacingOccurrencesOfString :@"#osRelease#" withString:osRelease];
    xml = [xml stringByReplacingOccurrencesOfString :@"#model#" withString:model];
    xml = [xml stringByReplacingOccurrencesOfString :@"#appname#" withString:app_Name];
    
    NSLog(xml);
    
    
    [self.socket writeString:xml];
    
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %@...will try to reconnect", [error localizedDescription]);
    __weak typeof(self) weakSelf = self;
    if([self.delegate respondsToSelector:@selector(serverDisconnect:)]) {
        [weakSelf.delegate serverDisconnect:[error localizedDescription]];
    }
    
    
    [self.socket connect];
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(@"Received text: %@", string);
    
    __weak typeof(self) weakSelf = self;
    if([self.delegate respondsToSelector:@selector(OnNewMsg:)]) {
        [weakSelf.delegate OnNewMsg:string];
    }
    
    [self ProcessMsg:string];
}



-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    NSLog(@"Received data: %@", data);
    NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    __weak typeof(self) weakSelf = self;
    if([self.delegate respondsToSelector:@selector(OnNewMsg:)]) {
        [weakSelf.delegate OnNewMsg:msg];
    }
    
    
}


- (void) ProcessMsg:(NSString*)msg{
    
    @try{
        NSData* xmlData = [msg dataUsingEncoding:NSUTF8StringEncoding];
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:nil];
        //获取根节点
        GDataXMLElement *rootElement=doc.rootElement;
        
        NSString* action = @"";
        NSArray *arr=[rootElement nodesForXPath:@"//APP/Action" error:nil];
        if([arr count] > 0){
            action = [[arr objectAtIndex:0] stringValue];
        }
        
        NSLog(@"Action->%@",action);
        
        if([action isEqualToString:@"LoginResponse"] == true){
            NSArray *Values = [rootElement nodesForXPath:@"//APP/Data/@FileUploadUrl" error:nil];
            if([Values count] > 0){
                NSString* FileUploadUrl = [[Values objectAtIndex:0]  stringValue];
                NSLog(@"FileUploadUrl->%@",FileUploadUrl);
                self.FileUploadUrl = FileUploadUrl;
                
            }
            
            else{
                NSLog(@"FileUploadUrl not found in LoginResponse...");
            }
            
            
        }
        
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
    
    
}


+ (NSString*) getUUIDString

{
    
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    NSString *uuidString = (__bridge_transfer NSString*)CFUUIDCreateString(nil, uuidObj);
    
    CFRelease(uuidObj);
    
    return uuidString;
    
}


- (Boolean) VisitorSendVideo:(NSString*) fileName
{
    @try{
        NSLog(@"VisitorSendVideo Start...fileName->%@",fileName);
        if(self.socket.isConnected == false){
            NSLog(@"VisitorSendVideo Start..not Connected to Server...return false...");
            return false;
            
        }
        
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VisitorSay</Action>"
        "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" MsgType=\"video\" "
        " DATA=\"0\">"
        "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        
        NSData* xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:nil];
        //获取根节点
        GDataXMLElement *rootElement=doc.rootElement;
        NSString* xPath = @"//APP/Data/@DATA";
        NSArray *arr=[rootElement nodesForXPath:xPath error:nil];
        if([arr count] > 0){
            [[arr objectAtIndex:0] setStringValue:fileName];
        }
        
        xml =  [[NSString alloc] initWithData:doc.XMLData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",xml);
        
        [self.socket writeString:xml];
        
        return true;
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}


- (Boolean) VisitorSendImage:(NSString*) fileName
{
    @try{
        NSLog(@"VisitorSendImage Start...fileName->%@",fileName);
        if(self.socket.isConnected == false){
            NSLog(@"VisitorSendImage Start..not Connected to Server...return false...");
            return false;
            
        }
        
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VisitorSay</Action>"
        "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" MsgType=\"image\" "
        " DATA=\"0\">"
        "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        
        NSData* xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:nil];
        //获取根节点
        GDataXMLElement *rootElement=doc.rootElement;
        NSString* xPath = @"//APP/Data/@DATA";
        NSArray *arr=[rootElement nodesForXPath:xPath error:nil];
        if([arr count] > 0){
            [[arr objectAtIndex:0] setStringValue:fileName];
        }
        
        xml =  [[NSString alloc] initWithData:doc.XMLData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",xml);
        
        [self.socket writeString:xml];
        
        return true;
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

- (Boolean) VisitorSay:(NSString*)msg
{
    @try{
        NSLog(@"VisitorSay Start...msg->%@",msg);
        if(self.socket.isConnected == false){
            NSLog(@"VisitorSay Start..not Connected to Server...return false...");
            return false;
            
        }
        
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VisitorSay</Action>"
            "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" MsgType=\"text\" "
            " DATA=\"0\">"
            "</Data></APP>";

        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        
        NSData* xmlData = [xml dataUsingEncoding:NSUTF8StringEncoding];
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:nil];
        //获取根节点
        GDataXMLElement *rootElement=doc.rootElement;
        NSString* xPath = @"//APP/Data/@DATA";
        NSArray *arr=[rootElement nodesForXPath:xPath error:nil];
        if([arr count] > 0){
            [[arr objectAtIndex:0] setStringValue:msg];
        }
        
        xml =  [[NSString alloc] initWithData:doc.XMLData encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",xml);
        
        [self.socket writeString:xml];
        
        return true;
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

- (Boolean) CallEnd{
    @try{
        NSLog(@"CallEnd Start...");
        self.Chating = false;
        
        if(self.socket.isConnected == false){
            NSLog(@"CallEnd Start..not Connected to Server...return false...");
            return false;
            
        }
        
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>EndCall</Action>"
            "<Data vTag=\"#vTag#\" chTag=\"#chTag#\"  vName=\"#vName#\" ></Data></APP>";
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        xml = [xml stringByReplacingOccurrencesOfString :@"#vName#" withString:self.vName];
        
        NSLog(xml);
        
        [self.socket writeString:xml];
        
        return true;

    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

- (Boolean) VideoGuestQuit
{
    @try{
        NSLog(@"VideoGuestQuit Start...");
        if(self.socket.isConnected == false){
            NSLog(@"VideoGuestQuit Start..not Connected to Server...return false...");
            return false;
            
        }
        
        
        //发送呼叫信息
        //<?xml version="1.0" encoding="UTF-8"?><APP><Action>VisitorCall</Action><Data vTag="#vTag#" StartTime="#StartTime#" DATA="0"/></APP>
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VideoGuestQuit</Action>"
        "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" >"
        "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        
        NSLog(xml);
        
        
        [self.socket writeString:xml];
        
        return true;
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

- (Boolean) VideoGuestJoinSucc
{
    @try{
        NSLog(@"VideoGuestJoinSucc Start...");
        if(self.socket.isConnected == false){
            NSLog(@"VideoGuestJoinSucc Start..not Connected to Server...return false...");
            return false;
            
        }
        
        
        //发送呼叫信息
        //<?xml version="1.0" encoding="UTF-8"?><APP><Action>VisitorCall</Action><Data vTag="#vTag#" StartTime="#StartTime#" DATA="0"/></APP>
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VideoGuestJoinSucc</Action>"
        "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" >"
        "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        
        NSLog(xml);
        
        
        [self.socket writeString:xml];
        
        return true;
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}


- (Boolean) VideoGuestJoinFailed

{
    @try{
        NSLog(@"VideoGuestJoinFailed Start...");
        if(self.socket.isConnected == false){
            NSLog(@"VideoGuestJoinFailed Start..not Connected to Server...return false...");
            return false;
            
        }
        
        
        //发送呼叫信息
        //<?xml version="1.0" encoding="UTF-8"?><APP><Action>VisitorCall</Action><Data vTag="#vTag#" StartTime="#StartTime#" DATA="0"/></APP>
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VideoGuestJoinFailed</Action>"
        "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" >"
        "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        
        NSLog(xml);
        
        
        [self.socket writeString:xml];
        
        return true;
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}


- (Boolean) VideoCallFromChat
{
    @try{
        NSLog(@"VideoCallFromChat Start...");
        if(self.socket.isConnected == false){
            NSLog(@"VideoCallFromChat Start..not Connected to Server...return false...");
            return false;
            
        }
        
        
        //发送呼叫信息
        //<?xml version="1.0" encoding="UTF-8"?><APP><Action>VisitorCall</Action><Data vTag="#vTag#" StartTime="#StartTime#" DATA="0"/></APP>
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VideoCallFromChat</Action>"
            "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" >"
            "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        
        NSLog(xml);
        
        
        [self.socket writeString:xml];
        
        return true;
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

- (Boolean) Call{
    @try{
        
        
        NSLog(@"Call Start...SvcCode->%@...",self.SvcCode);
        if(self.socket.isConnected == false){
            NSLog(@"Call Start..SvcCode->%@...not Connected to Server...return false...",self.SvcCode);
            return false;

        }
        
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VisitorCall</Action>"
            "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" svc=\"#svc#\" "
            " vName=\"#vName#\" "
            " DATA=\"0\"> "
            "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        xml = [xml stringByReplacingOccurrencesOfString :@"#svc#" withString:self.SvcCode];
        NSString* chTag = [ChatX getUUIDString];
        CurrentChTag = chTag;
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:chTag];
        xml = [xml stringByReplacingOccurrencesOfString :@"#vName#" withString:self.vName];
        
        NSLog(xml);
        
        
        [self.socket writeString:xml];
        
        return true;
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

@end

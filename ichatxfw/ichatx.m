//
//  ichatx.m
//  ichatx
//
//  Created by gant on 16/7/21.
//  Copyright © 2016年 integine. All rights reserved.
//

#import "ichatx.h"

#import <UIKit/UIKit.h>
#import "JFRWebSocket.h"
#import <AdSupport/ASIdentifierManager.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import "GDataXMLNode.h"
#import "MyChatViewController.h"
#import "webSocketDeletegate.h"
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIApplication.h>


@implementation ichatx

MyChatViewController *chatviewcontroller;
JFRWebSocket* mysocket;
webSocketDeletegate *wsdelegate;
UIViewController* parentUIViewController;//第三方调用者的VC

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

bool isDisconnectActively = false;//是否主动断开长连接


-(id)init
{
    if(self=[super init])
    {
        
        wsdelegate = [[webSocketDeletegate alloc] init];
        [self GetTelephoneInfo];
        
    }
    return self;
}

- (void) GetTelephoneInfo
{
    //.deviceid = [[[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString] lowercaseString];
    //NSLog(@"GetTelephoneInfo...deviceId->%@",self.deviceid);
    
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
    app_Name = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];
    //app_Name = [infoDictionary objectForKey:@"CFBundleDisplayName"];
    NSLog(@"app_Name: %@",app_Name );
    
    
}

- (void) Connect
{
    @try{
        NSLog(@"ChatX Connect...ServerIP->%@...ServerPort->%d...deviceId->%@...",
              self.ServerIP,self.ServerPort,self.deviceid);
        isDisconnectActively = false;
        NSString* websocketUrl = [NSString stringWithFormat:@"ws://%@:%d",self.ServerIP,self.ServerPort];
        if(mysocket == nil){
            NSLog(@"ChatX Connect...ServerIP->%@...ServerPort->%d...mysocket == nil..will call init...",
                  self.ServerIP,self.ServerPort);
            mysocket = [[JFRWebSocket alloc] initWithURL:[NSURL URLWithString:websocketUrl] protocols:@[@"",@""]];
            
        }
        else{
            NSLog(@"ChatX Connect...ServerIP->%@...ServerPort->%d...mysocket != nil..will not call init...",
                  self.ServerIP,self.ServerPort);

        }
        wsdelegate.chatx = self;
        mysocket.delegate = wsdelegate;
        [mysocket connect];
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
    
}

- (void) DoDisconnect
{
    @try{
        NSLog(@"ChatX DoDisconnect...mysocket.isConnected->%d...",
              mysocket.isConnected);
        isDisconnectActively = true;
        if(mysocket.isConnected == true){
            [mysocket disconnect];
            
            /*
            int tries = 0;
            while (mysocket.isConnected) {
                usleep(1000);
                tries++;
                NSLog(@"ChatX DoDisconnect...disconnect called...still Connected...wait for it");
                if(tries > 5) {
                    break;
                }
            }
            */
            
            
            
        }
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
}

-(void)OnChatActivityQuit
{
    [self.delegate OnChatActivityQuit];
}

-(void)serverConnect
{
    @try{

        NSLog(@"ChatX...serverConnect...");
        //发送LOGIN消息，让服务器和本机id关联
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>Login</Action>"
            "<Data vTag=\"#vTag#\" "
            "providerName=\"#providerName#\" "
            "simserialno=\"#simserialno#\" "
            "simcountrycode=\"#simcountrycode#\" city=\"#city#\" "
            "OS=\"Apple\" osRelease=\"#osRelease#\" "
            "manufacturer=\"Apple\" model=\"#model#\" appname=\"#appname#\" >"
             "</Data></APP>";
        
        if(self.deviceid != nil){
            xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
            xml = [xml stringByReplacingOccurrencesOfString :@"#simserialno#" withString:self.deviceid];
        }
        if(providerName != nil){
            xml = [xml stringByReplacingOccurrencesOfString :@"#providerName#" withString:providerName];
        }
        if(simcountrycode != nil){
        
            xml = [xml stringByReplacingOccurrencesOfString :@"#simcountrycode#" withString:simcountrycode];
        }
        if(city != nil){
            xml = [xml stringByReplacingOccurrencesOfString :@"#city#" withString:city];
        }
        if(osRelease != nil){
            xml = [xml stringByReplacingOccurrencesOfString :@"#osRelease#" withString:osRelease];
        }
        if(model != nil){
            xml = [xml stringByReplacingOccurrencesOfString :@"#model#" withString:model];
        }
        if(app_Name != nil){
            xml = [xml stringByReplacingOccurrencesOfString :@"#appname#" withString:app_Name];
        }
        
        NSLog(xml);
    
    
        [mysocket writeString:xml];
    
        [self.delegate serverConnect];
    }
    @catch(NSException* ex){
        NSLog(@"chatX...serverConnect...exception.name= %@" ,ex.name);
        NSLog(@"chatX...serverConnect...exception.reason= %@" ,ex.reason);
    }
    
    
}


-(void)serverDisconnect:(NSString*)reason
{
    NSLog(@"MyMobileViewController...serverDisconnect...");
    [self.delegate serverDisconnect:reason];
    if(isDisconnectActively == false){
        NSLog(@"MyMobileViewController...serverDisconnect...isDisconnectActively->false...will try to re connect");

        [mysocket connect];
    }
    
    
}

-(void)OnNewMsg:(NSString*)msg
{
    //NSLog(@"MyMobileViewController...OnNewMsg...%@...",msg);
    
    
    if(chatviewcontroller != nil){
        [chatviewcontroller OnNewMsg:msg];
    }
    
    [self ProcessMsg:msg];
    
    [self.delegate OnNewMsg:msg];
    
}



// pragma mark: WebSocket Delegate methods.
/**
 坐席同意了加入视频
 */
-(void)OnVideoGuestJoin:(NSString *)vendor Param1:(NSString*)Param1 Param2:(NSString*)Param2 Param3:(NSString*)Param3
{
    [self.delegate OnVideoGuestJoin:vendor Param1:Param1 Param2:Param2 Param3:Param3 vc:chatviewcontroller];
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
                [self.delegate LoginSucc];
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
        if(mysocket.isConnected == false){
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
        
        [mysocket writeString:xml];
        
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
        if(mysocket.isConnected == false){
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
        
        [mysocket writeString:xml];
        
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
        if(mysocket.isConnected == false){
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
        
        [mysocket writeString:xml];
        
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
        
        if(mysocket.isConnected == false){
            NSLog(@"CallEnd Start..not Connected to Server...return false...");
            return false;
            
        }
        
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>EndCall</Action>"
        "<Data vTag=\"#vTag#\" chTag=\"#chTag#\"  vName=\"#vName#\" ></Data></APP>";
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:CurrentChTag];
        xml = [xml stringByReplacingOccurrencesOfString :@"#vName#" withString:self.vName];
        
        NSLog(xml);
        
        [mysocket writeString:xml];
        
        
        
        
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
        if(mysocket.isConnected == false){
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
        
        
        [mysocket writeString:xml];
        
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
        if(mysocket.isConnected == false){
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
        
        
        [mysocket writeString:xml];
        
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
        if(mysocket.isConnected == false){
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
        
        
        [mysocket writeString:xml];
        
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
        if(mysocket.isConnected == false){
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
        
        
        [mysocket writeString:xml];
        
        return true;
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

- (Boolean) SendVisitorCallReq
{
    @try{
        
        
        NSLog(@"SendVisitorCallReq Start...SvcCode->%@...",self.SvcCode);
        if(mysocket.isConnected == false){
            NSLog(@"SendVisitorCallReq Start..SvcCode->%@...not Connected to Server...return false...",self.SvcCode);
            return false;
            
        }
        
        NSString* xml = @"<?xml version=\"1.0\" encoding=\"UTF-8\"?><APP><Action>VisitorCall</Action>"
        "<Data vTag=\"#vTag#\" chTag=\"#chTag#\" svc=\"#svc#\" "
        " vName=\"#vName#\" "
        " DATA=\"0\"> "
        "</Data></APP>";
        
        xml = [xml stringByReplacingOccurrencesOfString :@"#vTag#" withString:self.deviceid];
        xml = [xml stringByReplacingOccurrencesOfString :@"#svc#" withString:self.SvcCode];
        NSString* chTag = [ichatx getUUIDString];
        CurrentChTag = chTag;
        xml = [xml stringByReplacingOccurrencesOfString :@"#chTag#" withString:chTag];
        xml = [xml stringByReplacingOccurrencesOfString :@"#vName#" withString:self.vName];
        
        NSLog(xml);
        
        
        [mysocket writeString:xml];
        
        return true;
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}

- (Boolean) StartChat:(UIViewController*) viewController
{
    @try{
        
        
        NSLog(@"StartChat Start...");
        parentUIViewController = viewController;
        
        if(chatviewcontroller == nil){
            chatviewcontroller = [MyChatViewController messagesViewController];
        }
        chatviewcontroller.chatx = self;
        chatviewcontroller.delegateModal = self;
        
        UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:chatviewcontroller];
        [viewController presentViewController:nc animated:YES completion:nil];
        
        
        return true;
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
        return false;
    }
}


- (void)didDismissMyChatViewController:(MyChatViewController *)vc
{
    [parentUIViewController dismissViewControllerAnimated:YES completion:nil];
}



@end

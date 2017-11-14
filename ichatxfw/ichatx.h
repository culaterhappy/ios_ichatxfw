//
//  ichatx.h
//  ichatx
//
//  Created by gant on 16/7/21.
//  Copyright © 2016年 integine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKitDefines.h>
#import <UIKit/UIApplication.h>
//#import "JFRWebSocket.h"




@protocol ChatXDelegate <NSObject>

//@optional
/**
 服务器连接上的事件
 */
-(void)serverConnect;

/**
 服务器断开的事件
 */
-(void)serverDisconnect:(NSString*)reason;

/**
 登录服务器成功（建立连接不代表逻辑登录成功）
 */
-(void)LoginSucc;

/**
 登录服务器成功（建立连接不代表逻辑登录成功）
 */
-(void) OnChatActivityQuit;


/**
 收到服务器新消息的事件
 */
-(void)OnNewMsg:(NSString*)msg;


/**
 坐席同意了加入视频
 */
-(void)OnVideoGuestJoin:(NSString *)vendor Param1:(NSString*)Param1 Param2:(NSString*)Param2 Param3:(NSString*)Param3 vc:(UIViewController*)vc;


@end


//@interface ichatx : NSObject <JFRWebSocketDelegate>
@interface ichatx : NSObject

//deletgate 用来向调用的上层返回消息的
@property(nonatomic,weak)id<ChatXDelegate>delegate;
//websokcet
//@property(nonatomic, strong)JFRWebSocket *socket;

//APPProxy的ip地址
@property NSString *ServerIP;
//APPProxy的port
@property NSInteger ServerPort;
//当前ios系统的唯一标识，登录APPProxy时会传递，并且会作为回话的唯一标识
@property NSString *deviceid;
//当前登录用户的昵称
@property NSString *vName;
//发送图像文件或者视频文件的上传路径，在签入到APPProxy时候通过APPProxy的返回消息获取
@property NSString* FileUploadUrl;
//发起Chat时候的技能组ID
@property NSString* SvcCode;
//当前应答Chat的AgentID
@property NSString *AgentID;
//是否当前正在Chatting
@property Boolean Chating;

//连接Chat服务器。注意，Connect操作只是连接到Chat服务器，并不是发起呼叫请求
- (void) Connect;

//主动断开服务器连接
- (void) DoDisconnect;

//发出VisitorCall请求消息,是会通过ChatActivity的创建调用
- (Boolean) SendVisitorCallReq;

//结束Chat
- (Boolean) CallEnd;

//访客发送消息
- (Boolean) VisitorSay:(NSString*)msg;

//访客发送图片文件
- (Boolean) VisitorSendImage:(NSString*) fileName;

//访客发送视频
- (Boolean) VisitorSendVideo:(NSString*) fileName;

//在Chatting过程中发起实时视频
- (Boolean) VideoCallFromChat;

//实时视频访客加入失败
- (Boolean) VideoGuestJoinFailed;

//实时视频访客加入成功
- (Boolean) VideoGuestJoinSucc;

//实时视频访客退出
- (Boolean) VideoGuestQuit;

//发起呼叫
- (Boolean) StartChat:(UIViewController*) viewController;

/**
 坐席同意了加入视频
 */
-(void)OnVideoGuestJoin:(NSString *)vendor Param1:(NSString*)Param1 Param2:(NSString*)Param2 Param3:(NSString*)Param3;


/**
 服务器连接上的事件
 */
-(void)serverConnect;

/**
 服务器断开的事件
 */
-(void)serverDisconnect:(NSString*)reason;

-(void)OnChatActivityQuit;

/*

 登录服务器成功（建立连接不代表逻辑登录成功）
 */
-(void)LoginSucc;


/**
 收到服务器新消息的事件
 */
-(void)OnNewMsg:(NSString*)msg;



@end

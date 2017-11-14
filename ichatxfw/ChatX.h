//
//  ChatX.h
//  MyMobile
//
//  Created by gant on 16/6/17.
//
//

#import <Foundation/Foundation.h>
#import "JFRWebSocket.h"


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
 收到服务器新消息的事件
 */
-(void)OnNewMsg:(NSString*)msg;

@end

@interface ChatX : NSObject <JFRWebSocketDelegate>

@property(nonatomic,weak)id<ChatXDelegate>delegate;
@property(nonatomic, strong)JFRWebSocket *socket;

@property NSString *ServerIP;
@property NSInteger ServerPort;
@property NSString *deviceid;
@property NSString *vName;
@property NSString* FileUploadUrl;
@property NSString* SvcCode;
@property NSString *AgentID;
@property Boolean Chating;

- (void) Connect;
- (Boolean) Call;
- (Boolean) CallEnd;
- (Boolean) VisitorSay:(NSString*)msg;
- (Boolean) VisitorSendImage:(NSString*) fileName;
- (Boolean) VisitorSendVideo:(NSString*) fileName;
- (Boolean) VideoCallFromChat;
- (Boolean) VideoGuestJoinFailed;
- (Boolean) VideoGuestJoinSucc;
- (Boolean) VideoGuestQuit;

@end



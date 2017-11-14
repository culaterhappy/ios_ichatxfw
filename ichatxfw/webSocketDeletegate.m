//
//  webSocketDeletegate.m
//  ichatx
//
//  Created by gant on 16/8/2.
//  Copyright © 2016年 integine. All rights reserved.
//

#import "webSocketDeletegate.h"

@implementation webSocketDeletegate

// pragma mark: WebSocket Delegate methods.

-(void)websocketDidConnect:(JFRWebSocket*)socket {
    NSLog(@"websocket is connected");
    [self.chatx serverConnect];
    
    
}

-(void)websocketDidDisconnect:(JFRWebSocket*)socket error:(NSError*)error {
    NSLog(@"websocket is disconnected: %@...", [error localizedDescription]);
    [self.chatx serverDisconnect:[error localizedDescription]];
    
}

-(void)websocket:(JFRWebSocket*)socket didReceiveMessage:(NSString*)string {
    NSLog(@"Received text: %@", string);
    [self.chatx OnNewMsg:string];
    
}



-(void)websocket:(JFRWebSocket*)socket didReceiveData:(NSData*)data {
    NSLog(@"Received data: %@", data);
    NSString* msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    [self.chatx OnNewMsg:msg];
    
    
}

@end

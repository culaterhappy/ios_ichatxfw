//
//  webSocketDeletegate.h
//  ichatx
//
//  Created by gant on 16/8/2.
//  Copyright © 2016年 integine. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JFRWebSocket.h"
#import "ichatx.h"

@interface webSocketDeletegate : NSObject <JFRWebSocketDelegate>
    @property ichatx *chatx;
@end

//
//  DemoModelData.h
//  MyMobile
//
//  Created by gant on 16/6/17.
//
//

#ifndef DemoModelData_h
#define DemoModelData_h

#import "JSQMessages.h"
/**
 *  This is for demo/testing purposes only.
 *  This object sets up some fake model data.
 *  Do not actually do anything like this.
 */

static NSString * const kJSQDemoAvatarDisplayNameSquires = @"Jesse Squires";
static NSString * const kJSQDemoAvatarDisplayNameAgent = @"坐席";
static NSString * const kJSQDemoAvatarDisplayNameJobs = @"Jobs";
static NSString * const kJSQDemoAvatarDisplayNameWoz = @"Steve Wozniak";

static NSString * const kJSQDemoAvatarIdSquires = @"053496-4509-289";
static NSString * const kJSQDemoAvatarIdAgent = @"468-768355-23123";
static NSString * const kJSQDemoAvatarIdJobs = @"707-8956784-57";
static NSString * const kJSQDemoAvatarIdWoz = @"309-41802-93823";



@interface DemoModelData : NSObject

@property (strong, nonatomic) NSMutableArray *messages;

@property (strong, nonatomic) NSDictionary *avatars;

@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageDataNotice;

@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageDataAlarm;


@property (strong, nonatomic) NSDictionary *users;

@property  NSString* vName;
@property  NSString* SenderId;

- (void)addPhotoMediaMessage;

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion;

- (void)addVideoMediaMessage;

- (void)addAudioMediaMessage;

- (void)loadFakeMessages;
- (void)initAvatars;

@end

#endif /* DemoModelData_h */

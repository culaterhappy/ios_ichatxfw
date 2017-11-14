//
//  DemoModelData.m
//  MyMobile
//
//  Created by gant on 16/6/17.
//
//

#import <Foundation/Foundation.h>
#import "DemoModelData.h"

/**
 *  This is for demo/testing purposes only.
 *  This object sets up some fake model data.
 *  Do not actually do anything like this.
 */

@implementation DemoModelData

- (instancetype)init
{
    self = [super init];
    
    /*
    if (self) {
        
        
        [self loadFakeMessages];
        
    }
    */
    
    return self;
}

- (void)initAvatars
{
    /**
     *  Create avatar images once.
     *
     *  Be sure to create your avatars one time and reuse them for good performance.
     *
     *  If you are not using avatars, ignore this.
     */
    
    NSLog(@"initAvatars Start...");
    JSQMessagesAvatarImageFactory *avatarFactory = [[JSQMessagesAvatarImageFactory alloc] initWithDiameter:kJSQMessagesCollectionViewAvatarSizeDefault];
    
    /*
    JSQMessagesAvatarImage *jsqImage = [avatarFactory avatarImageWithUserInitials:self.vName
                                                                  backgroundColor:[UIColor colorWithWhite:0.85f alpha:1.0f]
                                                                        textColor:[UIColor colorWithWhite:0.60f alpha:1.0f]
                                                                             font:[UIFont systemFontOfSize:14.0f]];
    */
    
    UIImage *img = [UIImage imageNamed:@"avatarvisitor.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    
    //JSQMessagesAvatarImage *SenderImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"avatarvisitor.png"]];
    JSQMessagesAvatarImage *SenderImage = [avatarFactory avatarImageWithImage:img];
    
    img = [UIImage imageNamed:@"avataragent.png" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    //JSQMessagesAvatarImage *agentImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"avataragent.png"]];
    JSQMessagesAvatarImage *agentImage = [avatarFactory avatarImageWithImage:img];
    
    img = [UIImage imageNamed:@"demo_avatar_jobs" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    //JSQMessagesAvatarImage *jobsImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_jobs"]];
    JSQMessagesAvatarImage *jobsImage = [avatarFactory avatarImageWithImage:img];
    
    img = [UIImage imageNamed:@"demo_avatar_woz" inBundle:[NSBundle bundleForClass:[self class]] compatibleWithTraitCollection:[UITraitCollection traitCollectionWithDisplayScale:[UIScreen mainScreen].scale]];
    JSQMessagesAvatarImage *wozImage = [avatarFactory avatarImageWithImage:img];
    //JSQMessagesAvatarImage *wozImage = [avatarFactory avatarImageWithImage:[UIImage imageNamed:@"demo_avatar_woz"]];
    
    
    
    self.avatars = @{ self.SenderId : SenderImage,
                      kJSQDemoAvatarIdAgent : agentImage,
                      kJSQDemoAvatarIdJobs : jobsImage,
                      kJSQDemoAvatarIdWoz : wozImage };
    
    
    self.users = @{ kJSQDemoAvatarIdJobs : kJSQDemoAvatarDisplayNameJobs,
                    kJSQDemoAvatarIdAgent : kJSQDemoAvatarDisplayNameAgent,
                    kJSQDemoAvatarIdWoz : kJSQDemoAvatarDisplayNameWoz,
                    kJSQDemoAvatarIdSquires : kJSQDemoAvatarDisplayNameSquires
                    };
    
    
    /**
     *  Create message bubble images objects.
     *
     *  Be sure to create your bubble images one time and reuse them for good performance.
     *
     */
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleGreenColor]];
    self.incomingBubbleImageDataNotice = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageDataAlarm = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleRedColor]];
    
    NSLog(@"initAvatars Succ...");
    
}

- (void)loadFakeMessages
{
    /**
     *  Load some fake messages for demo.
     *
     *  You should have a mutable array or orderedSet, or something.
     */
    self.messages = [[NSMutableArray alloc] initWithObjects:
                     /*
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdAgent
                                        senderDisplayName:@"系统"
                                                     date:[NSDate distantPast]
                                                     text:NSLocalizedString(@"#NOTICE#转接座席中,请稍候.", nil)],
                      */
                     /*
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdWoz
                                        senderDisplayName:kJSQDemoAvatarDisplayNameWoz
                                                     date:[NSDate distantPast]
                                                     text:NSLocalizedString(@"#NOTICE#It is simple", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate distantPast]
                                                     text:NSLocalizedString(@"It even has data detectors. You can call me tonight. My cell number is 123-456-7890. My website is www.hexedbits.com.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdJobs
                                        senderDisplayName:kJSQDemoAvatarDisplayNameJobs
                                                     date:[NSDate date]
                                                     text:NSLocalizedString(@"JSQMessagesViewController is nearly an exact replica of the iOS Messages App. And perhaps, better.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdCook
                                        senderDisplayName:kJSQDemoAvatarDisplayNameCook
                                                     date:[NSDate date]
                                                     text:NSLocalizedString(@"It is unit-tested, free, open-source, and documented.", nil)],
                     
                     [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdSquires
                                        senderDisplayName:kJSQDemoAvatarDisplayNameSquires
                                                     date:[NSDate date]
                                                     text:NSLocalizedString(@"Now with media messages!", nil)],
                     */
                     
                     nil];
    
    //[self addPhotoMediaMessage];
    //[self addAudioMediaMessage];
    
    /**
     *  Setting to load extra messages for testing/demo
     */
    
    /*
        NSArray *copyOfMessages = [self.messages copy];
        for (NSUInteger i = 0; i < 4; i++) {
            [self.messages addObjectsFromArray:copyOfMessages];
        }
    */
    
    
    /**
     *  Setting to load REALLY long message for testing/demo
     *  You should see "END" twice
     */
    
    /*
    if (true) {
        JSQMessage *reallyLongMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                            displayName:kJSQDemoAvatarDisplayNameSquires
                                                                   text:@"Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit, sed quia non numquam eius modi tempora incidunt ut labore et dolore magnam aliquam quaerat voluptatem. Ut enim ad minima veniam, quis nostrum exercitationem ullam corporis suscipit laboriosam, nisi ut aliquid ex ea commodi consequatur? Quis autem vel eum iure reprehenderit qui in ea voluptate velit esse quam nihil molestiae consequatur, vel illum qui dolorem eum fugiat quo voluptas nulla pariatur? END"];
        
        [self.messages addObject:reallyLongMessage];
     
    
    }
     */
    
}

- (void)addAudioMediaMessage
{
    NSString * sample = [[NSBundle mainBundle] pathForResource:@"jsq_messages_sample" ofType:@"m4a"];
    NSData * audioData = [NSData dataWithContentsOfFile:sample];
    JSQAudioMediaItem *audioItem = [[JSQAudioMediaItem alloc] initWithData:audioData];
    JSQMessage *audioMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:audioItem];
    [self.messages addObject:audioMessage];
}

- (void)addPhotoMediaMessage
{
    JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:[UIImage imageNamed:@"goldengate"]];
    JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:photoItem];
    [self.messages addObject:photoMessage];
}

- (void)addLocationMediaMessageCompletion:(JSQLocationMediaItemCompletionBlock)completion
{
    CLLocation *ferryBuildingInSF = [[CLLocation alloc] initWithLatitude:37.795313 longitude:-122.393757];
    
    JSQLocationMediaItem *locationItem = [[JSQLocationMediaItem alloc] init];
    [locationItem setLocation:ferryBuildingInSF withCompletionHandler:completion];
    
    JSQMessage *locationMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                      displayName:kJSQDemoAvatarDisplayNameSquires
                                                            media:locationItem];
    [self.messages addObject:locationMessage];
}

- (void)addVideoMediaMessage
{
    // don't have a real video, just pretending
    NSURL *videoURL = [NSURL URLWithString:@"file://"];
    
    JSQVideoMediaItem *videoItem = [[JSQVideoMediaItem alloc] initWithFileURL:videoURL isReadyToPlay:YES];
    JSQMessage *videoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdSquires
                                                   displayName:kJSQDemoAvatarDisplayNameSquires
                                                         media:videoItem];
    [self.messages addObject:videoMessage];
}

@end

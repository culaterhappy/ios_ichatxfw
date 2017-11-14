//
//  MyChatViewController.m
//  MyMobile
//
//  Created by gant on 16/6/16.
//
//

#import <Foundation/Foundation.h>
#import "MyChatViewController.h"
#import "GDataXMLNode.h"
#import "UIImageView+WebCache.h"
#import "ASIFormDataRequest.h"
#import <MobileCoreServices/MobileCoreServices.h>

@implementation MyChatViewController

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods

NSString* currentUploadFileName = @"";
NSUInteger currentUploadType = 0;//0->photo,1->video
Boolean bLogOuted = false;


- (void)ShowOperatorMsg:(NSString *)msg displayName:(NSString *)displayName
{
    
    JSQMessage * newMessage = [[JSQMessage alloc] initWithSenderId:kJSQDemoAvatarIdAgent
                                                 senderDisplayName:displayName
                                                              date:[NSDate date]
                                                              text:NSLocalizedString(msg, nil)];
    
    [self.demoData.messages addObject:newMessage];
    //[self finishSendingMessageAnimated:YES];
    [self finishReceivingMessageAnimated:YES];
}

/**
 *  Override point for customization.
 *
 *  Customize your view.
 *  Look at the properties on `JSQMessagesViewController` and `JSQMessagesCollectionView` to see what is possible.
 *
 *  Customize your layout.
 *  Look at the properties on `JSQMessagesCollectionViewFlowLayout` to see what is possible.
 */
- (void)viewDidLoad
{
    NSLog(@"MyChatViewController...viewDidLoad");
    bLogOuted = false;
    
    [super viewDidLoad];
    
    self.title = @"APP Chat";
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    
    /**
     *  Load up our fake data for the demo
     */
    
    self.demoData = [[DemoModelData alloc] init];
    self.demoData.vName = self.chatx.vName;
    self.demoData.SenderId = self.chatx.deviceid;
    [self.demoData initAvatars];
    [self.demoData loadFakeMessages];
    
    
    /**
     *  You can set custom avatar sizes
     */
    if (false) {
        self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
    }
    
    if (false) {
        self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
    }
    
    self.showLoadEarlierMessagesHeader = NO;
    
    /*
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage jsq_defaultTypingIndicatorImage]
                                                                              style:UIBarButtonItemStyleBordered
                                                                             target:self
                                                                             action:@selector(receiveMessagePressed:)];
    */
    
    /**
     *  Register custom menu actions for cells.
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(customAction:)];
    
    
    /**
     *  OPT-IN: allow cells to be deleted
     */
    [JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    self.collectionView.collectionViewLayout.messageBubbleFont = [UIFont systemFontOfSize:12.0f];
    
    [self.demoData.messages removeAllObjects];
    
    NSString* msg = @"#NOTICE#转接座席中,请稍候.";
    NSString* displayName = @"系统";
    
    [self ShowOperatorMsg:msg displayName:displayName];
    
    
    //self.chatx.SvcCode = @"投诉";
    [self.chatx SendVisitorCallReq];
    

    

}



- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.delegateModal) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop
                                                                                              target:self
                                                                                              action:@selector(closePressed:)];
    }
    
    
    
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"MyChatViewController...viewDidAppear");
    [super viewDidAppear:animated];
    
    /**
     *  Enable/disable springy bubbles, default is NO.
     *  You must set this from `viewDidAppear:`
     *  Note: this feature is mostly stable, but still experimental
     */
    
    //self.collectionView.collectionViewLayout.springinessEnabled = true;
    
    /*
    if(self.isDismissing){
        return;
    }
    */
    
    if(bLogOuted == false){
        //maybe select images cause didAppear
        NSLog(@"MyChatViewController...viewDidAppear...bLogOuted->true...wont call chatx.call...");
        return;
    }
    
    bLogOuted = false;
    
    @try{
        [self.demoData.messages removeAllObjects];
        
        NSString* msg = @"#NOTICE#转接座席中,请稍候.";
        NSString* displayname = @"系统";
        
        [self ShowOperatorMsg:msg displayName:displayname];
        //self.chatx.SvcCode = @"";
        [self.chatx SendVisitorCallReq];
        
        
        
        //[self UploadFile:@"chat.png"];
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
    
    
}


- (void) viewDidDisappear:(BOOL)animated
{
    @try{
        NSLog(@"MyChatViewController...viewDidDisappear");
        
        if(bLogOuted == false){
            //maybe select images cause didAppear
            return;
        }
        
        [super viewDidDisappear:animated];
    
        [self.chatx CallEnd];
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
    
    
}

#pragma mark - Custom menu actions for cells

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification
{
    /**
     *  Display custom menu actions for cells.
     */
    UIMenuController *menu = [notification object];
    menu.menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Custom Action" action:@selector(customAction:)] ];
}



#pragma mark - Testing

- (void)pushMainViewController
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *nc = [sb instantiateInitialViewController];
    [self.navigationController pushViewController:nc.topViewController animated:YES];
}



#pragma mark - Actions

- (void)receiveMessagePressed:(UIBarButtonItem *)sender
{
    /**
     *  DEMO ONLY
     *
     *  The following is simply to simulate received messages for the demo.
     *  Do not actually do this.
     */
    
    
    /**
     *  Show the typing indicator to be shown
     */
    self.showTypingIndicator = !self.showTypingIndicator;
    
    /**
     *  Scroll to actually view the indicator
     */
    [self scrollToBottomAnimated:YES];
    
    /**
     *  Copy last sent message, this will be the new "received" message
     */
    JSQMessage *copyMessage = [[self.demoData.messages lastObject] copy];
    
    if (!copyMessage) {
        copyMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdJobs
                                          displayName:kJSQDemoAvatarDisplayNameJobs
                                                 text:@"First received!"];
    }
    
    /**
     *  Allow typing indicator to show
     */
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        NSMutableArray *userIds = [[self.demoData.users allKeys] mutableCopy];
        [userIds removeObject:self.senderId];
        NSString *randomUserId = userIds[arc4random_uniform((int)[userIds count])];
        
        JSQMessage *newMessage = nil;
        id<JSQMessageMediaData> newMediaData = nil;
        id newMediaAttachmentCopy = nil;
        
        if (copyMessage.isMediaMessage) {
            /**
             *  Last message was a media message
             */
            id<JSQMessageMediaData> copyMediaData = copyMessage.media;
            
            if ([copyMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                JSQPhotoMediaItem *photoItemCopy = [((JSQPhotoMediaItem *)copyMediaData) copy];
                photoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [UIImage imageWithCGImage:photoItemCopy.image.CGImage];
                
                /**
                 *  Set image to nil to simulate "downloading" the image
                 *  and show the placeholder view
                 */
                photoItemCopy.image = nil;
                
                newMediaData = photoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                JSQLocationMediaItem *locationItemCopy = [((JSQLocationMediaItem *)copyMediaData) copy];
                locationItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [locationItemCopy.location copy];
                
                /**
                 *  Set location to nil to simulate "downloading" the location data
                 */
                locationItemCopy.location = nil;
                
                newMediaData = locationItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                JSQVideoMediaItem *videoItemCopy = [((JSQVideoMediaItem *)copyMediaData) copy];
                videoItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [videoItemCopy.fileURL copy];
                
                /**
                 *  Reset video item to simulate "downloading" the video
                 */
                videoItemCopy.fileURL = nil;
                videoItemCopy.isReadyToPlay = NO;
                
                newMediaData = videoItemCopy;
            }
            else if ([copyMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                JSQAudioMediaItem *audioItemCopy = [((JSQAudioMediaItem *)copyMediaData) copy];
                audioItemCopy.appliesMediaViewMaskAsOutgoing = NO;
                newMediaAttachmentCopy = [audioItemCopy.audioData copy];
                
                /**
                 *  Reset audio item to simulate "downloading" the audio
                 */
                audioItemCopy.audioData = nil;
                
                newMediaData = audioItemCopy;
            }
            else {
                NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
            }
            
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                   media:newMediaData];
        }
        else {
            /**
             *  Last message was a text message
             */
            newMessage = [JSQMessage messageWithSenderId:randomUserId
                                             displayName:self.demoData.users[randomUserId]
                                                    text:copyMessage.text];
        }
        
        /**
         *  Upon receiving a message, you should:
         *
         *  1. Play sound (optional)
         *  2. Add new id<JSQMessageData> object to your data source
         *  3. Call `finishReceivingMessage`
         */
        
        // [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        
        [self.demoData.messages addObject:newMessage];
        [self finishReceivingMessageAnimated:YES];
        
        
        if (newMessage.isMediaMessage) {
            /**
             *  Simulate "downloading" media
             */
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                /**
                 *  Media is "finished downloading", re-display visible cells
                 *
                 *  If media cell is not visible, the next time it is dequeued the view controller will display its new attachment data
                 *
                 *  Reload the specific item, or simply call `reloadData`
                 */
                
                if ([newMediaData isKindOfClass:[JSQPhotoMediaItem class]]) {
                    ((JSQPhotoMediaItem *)newMediaData).image = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQLocationMediaItem class]]) {
                    [((JSQLocationMediaItem *)newMediaData)setLocation:newMediaAttachmentCopy withCompletionHandler:^{
                        [self.collectionView reloadData];
                    }];
                }
                else if ([newMediaData isKindOfClass:[JSQVideoMediaItem class]]) {
                    ((JSQVideoMediaItem *)newMediaData).fileURL = newMediaAttachmentCopy;
                    ((JSQVideoMediaItem *)newMediaData).isReadyToPlay = YES;
                    [self.collectionView reloadData];
                }
                else if ([newMediaData isKindOfClass:[JSQAudioMediaItem class]]) {
                    ((JSQAudioMediaItem *)newMediaData).audioData = newMediaAttachmentCopy;
                    [self.collectionView reloadData];
                }
                else {
                    NSLog(@"%s error: unrecognized media item", __PRETTY_FUNCTION__);
                }
                
            });
        }
        
    });
}


- (void)closePressed:(UIBarButtonItem *)sender
{
    bLogOuted = true;
    [self.delegateModal didDismissMyChatViewController:self];
}

- (void) VidyeStart
{
    [self ShowVisitorMsg:@"#NOTICE#已向对方发出视频请求,等待对方的回应."];
    
    [self.chatx VideoCallFromChat];
    
}

- (void)VideoGuestJoinSucc
{
    [self.chatx VideoGuestJoinSucc];
}

- (void)VideoGuestQuit
{
    [self.chatx VideoGuestQuit];
}


#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    
    /*
    if(self.chatx.Chating == false)
        return;
    */
    
    /**
     *  Sending a message. Your implementation of this method should do *at least* the following:
     *
     *  1. Play sound (optional)
     *  2. Add new id<JSQMessageData> object to your data source
     *  3. Call `finishSendingMessage`
     */
    
    // [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    
    [self ShowVisitorMsg:text];
    
    [self.chatx VisitorSay:text];
    
    
}

- (void)didPressAccessoryButton:(UIButton *)sender
{
    /*
    if(self.chatx.Chating == false)
        return;
    */
     
    [self.inputToolbar.contentView.textView resignFirstResponder];
    
    UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"媒体选择", nil)
                                                       delegate:self
                                              cancelButtonTitle:NSLocalizedString(@"取消", nil)
                                         destructiveButtonTitle:nil
                                              otherButtonTitles:NSLocalizedString(@"发送图片", nil), NSLocalizedString(@"发送视频", nil), NSLocalizedString(@"实时视频", nil), nil];
    
    sheet.tag = 0;
    [sheet showFromToolbar:self.inputToolbar];
}

- (void) SelectImage
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍照",@"从相册选择" , nil];
        
    }
    
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 1;
    
    [sheet showInView:self.view];
    
}

- (void) SelectVideo
{
    UIActionSheet *sheet;
    
    // 判断是否支持相机
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
        
    {
        sheet  = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"拍摄",@"从相册选择" , nil];
        
    }
    
    else {
        
        sheet = [[UIActionSheet alloc] initWithTitle:@"选择" delegate:self cancelButtonTitle:nil destructiveButtonTitle:@"取消" otherButtonTitles:@"从相册选择", nil];
        
    }
    
    sheet.tag = 2;
    
    [sheet showInView:self.view];
    
}


- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    
    if(actionSheet.tag == 0){
        //First level to select media
        if (buttonIndex == actionSheet.cancelButtonIndex) {
            [self.inputToolbar.contentView.textView becomeFirstResponder];
            return;
        }
        
        switch (buttonIndex) {
            case 0:
                //[self.demoData addPhotoMediaMessage];
                [self SelectImage];
                break;
                
            case 1:
                //[self.demoData addVideoMediaMessage];
                [self SelectVideo];
                break;
                
            case 2:
            {
                /*
                __weak UICollectionView *weakView = self.collectionView;
                
                [self.demoData addLocationMediaMessageCompletion:^{
                    [weakView reloadData];
                }];
                 */
                
                [self VidyeStart];
                 
            }
                break;
                
            
                
            case 3:
                [self.demoData addAudioMediaMessage];
                break;
        }
        
        // [JSQSystemSoundPlayer jsq_playMessageSentSound];
        
        [self finishSendingMessageAnimated:YES];
    }
    else if(actionSheet.tag == 1){
        
        //select image
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        
        
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
        
        
    }
    else if(actionSheet.tag == 2){
        
        //select video
        NSUInteger sourceType = 0;
        
        // 判断是否支持相机
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
            
            switch (buttonIndex) {
                case 0:
                    // 取消
                    return;
                case 1:
                    // 相机
                    sourceType = UIImagePickerControllerSourceTypeCamera;
                    break;
                    
                case 2:
                    // 相册
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                    break;
            }
        }
        else {
            if (buttonIndex == 0) {
                
                return;
            } else {
                sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
            }
        }
        
        UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
        
        imagePickerController.delegate = self;
        
        imagePickerController.allowsEditing = YES;
        
        imagePickerController.sourceType = sourceType;
        imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects: (NSString *)kUTTypeMovie, nil];
        
        
        [self presentViewController:imagePickerController animated:YES completion:^{}];
        
        
        
    }
    
}


#pragma mark - image picker delegte
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    /* 此处info 有六个值
     * UIImagePickerControllerMediaType; // an NSString UTTypeImage)
     * UIImagePickerControllerOriginalImage;  // a UIImage 原始图片
     * UIImagePickerControllerEditedImage;    // a UIImage 裁剪后图片
     * UIImagePickerControllerCropRect;       // an NSValue (CGRect)
     * UIImagePickerControllerMediaURL;       // an NSURL
     * UIImagePickerControllerReferenceURL    // an NSURL that references an asset in the AssetsLibrary framework
     * UIImagePickerControllerMediaMetadata    // an NSDictionary containing metadata from a captured photo
     */
    
    [picker dismissViewControllerAnimated:YES completion:^{}];
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]) {//如果是拍照
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self UploadImageFromImage:image];
    }
    else if([mediaType isEqualToString:(NSString *)kUTTypeMovie]){//如果是录制视频
        
        NSURL *videoURL = info[UIImagePickerControllerMediaURL];
        __weak typeof(self) weakSelf = self;
        NSLog(@"media %@",info);
        NSURL    *movieURL = [info valueForKey:UIImagePickerControllerMediaURL];
        NSDictionary *opts = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO]
                                                         forKey:AVURLAssetPreferPreciseDurationAndTimingKey];
        
        AVURLAsset *urlAsset = [AVURLAsset URLAssetWithURL:movieURL options:opts];  // 初始化视频媒体文件
        
        long long  second = 0;
        
        second = urlAsset.duration.value / urlAsset.duration.timescale; // 获取视频总时长,单位秒
        
        NSLog(@"movie duration : %lld", second);
        
        
        NSURL *mp4 = [self convert2Mp4:videoURL];
        NSFileManager *fileman = [NSFileManager defaultManager];
        if ([fileman fileExistsAtPath:videoURL.path]) {
            NSError *error = nil;
            [fileman removeItemAtURL:videoURL error:&error];
            if (error) {
                NSLog(@"failed to remove file, error:%@.", error);
            }
        }
        
         
        [self UploadVideoFromFilePath:mp4.path];
        
        
    }
    
    
    
}
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{}];
}


- (NSURL *)convert2Mp4:(NSURL *)movUrl {
    NSURL *mp4Url = nil;
    AVURLAsset *avAsset = [AVURLAsset URLAssetWithURL:movUrl options:nil];
    NSArray *compatiblePresets = [AVAssetExportSession exportPresetsCompatibleWithAsset:avAsset];
    
    if ([compatiblePresets containsObject:AVAssetExportPresetHighestQuality]) {
        AVAssetExportSession *exportSession = [[AVAssetExportSession alloc]
                                               initWithAsset:avAsset
                                               presetName:AVAssetExportPreset640x480];
        mp4Url = [movUrl copy];
        mp4Url = [mp4Url URLByDeletingPathExtension];
        mp4Url = [mp4Url URLByAppendingPathExtension:@"mp4"];
        exportSession.outputURL = mp4Url;
        exportSession.shouldOptimizeForNetworkUse = YES;
        exportSession.outputFileType = AVFileTypeMPEG4;
        dispatch_semaphore_t wait = dispatch_semaphore_create(0l);
        //        [self showHudInView:self.view hint:@"正在压缩"];
        //        __weak typeof(self) weakSelf = self;
        [exportSession exportAsynchronouslyWithCompletionHandler:^{
            //            [weakSelf hideHud];
            switch ([exportSession status]) {
                case AVAssetExportSessionStatusFailed: {
                    NSLog(@"convert2Mp4 failed, error:%@.", exportSession.error);
                } break;
                case AVAssetExportSessionStatusCancelled: {
                    NSLog(@"convert2Mp4 cancelled.");
                } break;
                case AVAssetExportSessionStatusCompleted: {
                    NSLog(@"convert2Mp4 completed.");
                } break;
                default: {
                    NSLog(@"convert2Mp4 others.");
                } break;
            }
            dispatch_semaphore_signal(wait);
        }];
        long timeout = dispatch_semaphore_wait(wait, DISPATCH_TIME_FOREVER);
        if (timeout) {
            NSLog(@"convert2Mp4 timeout.");
        }
        if (wait) {
            //dispatch_release(wait);
            wait = nil;
        }
    }
    
    return mp4Url;
}


#pragma mark - JSQMessages Col

- (NSString *)senderId {
    return self.chatx.deviceid;
}

- (NSString *)senderDisplayName {
    return self.chatx.vName;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.demoData.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath
{
    [self.demoData.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.demoData.outgoingBubbleImageData;
    }
    else if([message.text hasPrefix:@"#NOTICE#"] == 1){
        return self.demoData.incomingBubbleImageDataNotice;
    }
    else if([message.text hasPrefix:@"#ALARM#"] == 1){
        return self.demoData.incomingBubbleImageDataAlarm;
    }
    
    
    return self.demoData.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        if (false) {
            return nil;
        }
    }
    else {
        if (false) {
            return nil;
        }
    }
    
    
    return [self.demoData.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     *  The other label text delegate methods should follow a similar pattern.
     *
     *  Show a timestamp for every 3rd message
     */
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    /*
    if([message.text containsString:@"转接座席中"]){
        return [[NSAttributedString alloc] initWithString:message.text];
        
    }
    else */
    if (indexPath.item % 3 == 0) {
        
        return [[JSQMessagesTimestampFormatter sharedFormatter] attributedTimestampForDate:message.date];
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    
    JSQMessage *message = [self.demoData.messages objectAtIndex:indexPath.item];
    
    
    /**
     *  iOS7-style sender name labels
     */
    
    /*
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    */
    
    /**
     *  Don't specify attributes to use the defaults.
     */
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.demoData.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Override point for customizing cells
     */
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
    /**
     *  Configure almost *anything* on the cell
     *
     *  Text colors, label text, label colors, etc.
     *
     *
     *  DO NOT set `cell.textView.font` !
     *  Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`
     *
     *
     *  DO NOT manipulate cell layout information!
     *  Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`
     */
    
    JSQMessage *msg = [self.demoData.messages objectAtIndex:indexPath.item];
    
    if (!msg.isMediaMessage) {
        
        if ([msg.senderId isEqualToString:self.senderId]) {
            cell.textView.textColor = [UIColor blackColor];
        }
        else {
            cell.textView.textColor = [UIColor whiteColor];
        }
        
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    
    if([msg.text hasPrefix:@"#NOTICE#"] == 1){
        NSString* newText = [msg.text substringFromIndex:8];
        cell.textView.text = newText;
        cell.textView.textColor = [UIColor blackColor];
        /*
        [cell.messageBubbleImageView setHidden:true];
        [cell.textView setHidden:true];
        [cell.avatarImageView setHidden:true];
        UIFont *customFont = [UIFont fontWithName:@"Tahoma" size:11];
        cell.cellTopLabel.font = customFont;
        cell.cellTopLabel.text = newText;
        [cell.cellTopLabel setHidden:false];
        */
        
        
    }
    else if([msg.text hasPrefix:@"#ALARM#"] == 1){
        NSString* newText = [msg.text substringFromIndex:7];
        cell.textView.text = newText;
        
        
        
    }
    
    
    
    return cell;
}



#pragma mark - UICollectionView Delegate

#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        return YES;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(customAction:)) {
        [self customAction:sender];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)customAction:(id)sender
{
    NSLog(@"Custom action received! Sender: %@", sender);
    
    [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Custom Action", nil)
                                message:nil
                               delegate:nil
                      cancelButtonTitle:NSLocalizedString(@"OK", nil)
                      otherButtonTitles:nil]
     show];
}



#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
     */
    
    /**
     *  This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     *  The other label height delegate methods should follow similarly
     *
     *  Show a timestamp for every 3rd message
     */
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  iOS7-style sender name labels
     */
    
    /*
    JSQMessage *currentMessage = [self.demoData.messages objectAtIndex:indexPath.item];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.demoData.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    */
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath
{
    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender
{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"Tapped message bubble!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        JSQPhotoMediaItem *item = [[JSQPhotoMediaItem alloc] initWithImage:[UIPasteboard generalPasteboard].image];
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                             media:item];
        [self.demoData.messages addObject:message];
        [self finishSendingMessage];
        return NO;
    }
    return YES;
}


+(NSString*) getXmlNodeValue:(GDataXMLElement*) rootElement xPath:(NSString*) xPath
{
    NSArray *arr=[rootElement nodesForXPath:xPath error:nil];
    if([arr count] > 0){
        return [[arr objectAtIndex:0] stringValue];
    }
    else{
        return nil;
    }

}

-(void)OnNewMsg:(NSString*)msg
{
    //NSLog(@"MyChatViewController...OnNewMsg...%@...",msg);
    @try{
        NSData* xmlData = [msg dataUsingEncoding:NSUTF8StringEncoding];
        
        GDataXMLDocument *doc = [[GDataXMLDocument alloc] initWithData:xmlData
                                                               options:0 error:nil];
        //获取根节点
        GDataXMLElement *rootElement=doc.rootElement;
        
        NSString* action = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Action"];
        /*
        NSArray *arr=[rootElement nodesForXPath:@"//APP/Action" error:nil];
        if([arr count] > 0){
            action = [[arr objectAtIndex:0] stringValue];
        }
         */
        
        
        
        
        if([action isEqualToString:@"CallResult"] == true){
            NSString* Result = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@Result"];
            NSString* Reason = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@Reason"];
            if([Result isEqualToString:@"-1"] == true) {
                NSString* sReason = @"";
                if ([Reason isEqualToString:@"No Agent Avail"]) {
                    
                    sReason = @"沒有空閒坐席";
                    
                } else {
                    sReason = Reason;
                }
                
                [self ShowOperatorMsg:sReason displayName:@"系统"];
    
            }
            else if([Result isEqualToString:@"0"] == true){
                NSString* sReason = [@"#NOTICE#" stringByAppendingString:Reason];
                
                [self ShowOperatorMsg:sReason displayName:@"系统"];
                
                self.chatx.Chating = true;
                
            }
            else{
                NSLog(@"Result not found in CallResult...");
            }
            
            
        }
        //OperatorCloseCall
        else if([action isEqualToString:@"OperatorCloseCall"] == true){
            NSString* Reason = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@Reason"];
            NSString* sReason = [@"#ALARM#" stringByAppendingString:Reason];
            
            [self ShowOperatorMsg:sReason displayName:@"系统"];
            
            self.chatx.Chating = false;
            
        }
        //OperatorSay
        else if([action isEqualToString:@"OperatorSay"] == true){
            NSString* Msg = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@Msg"];
            NSString* AgentID = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@AgentID"];
            self.chatx.AgentID = AgentID;
            
            [self ShowOperatorMsg:Msg displayName:AgentID];
            
        }
        else if([action isEqualToString:@"VideoGuestJoin"] == true)
        {
            
            [self ShowOperatorMsg:@"#NOTICE#对方已经接受视频请求" displayName:@"系统"];
            
            NSString* RoomKey = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@RoomKey"];
            NSString* RoomPin = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@RoomPin"];
            
            NSString* host = @"http://vidyochina.cn";
            
            
            //[self ShowVideoView:self.chatx.vName guestVPortal:host guestVRoomKey:RoomKey guestVRoomPin:RoomPin];
            [self.chatx OnVideoGuestJoin:@"vidyo" Param1:RoomKey Param2:RoomPin Param3:self.chatx.vName];
            
        }
        else if([action isEqualToString:@"VideoQuit"] == true)
        {
            /*
            if(videoviewcontroller != nil){
                [videoviewcontroller VidyoQuit];
                
            }
             */
        }
        else if([action isEqualToString:@"OperatorSendImage"] == true)
        {
            NSString* imageId = [MyChatViewController getXmlNodeValue:rootElement xPath:@"//APP/Data/@imageId"];
            
            NSString* imageurl = [NSString stringWithFormat:@"%@WXData/%@",self.chatx.FileUploadUrl,imageId];
            
            NSLog(@"OperatorSendImage...imageUrl->%@",imageurl);
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:imageurl]
                                  options:kNilOptions
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize)
             {
                 // update a progress view
                 NSLog(@"downloadImageWithURL progress...receivedSize->%d...expectedSize->%d...",receivedSize,expectedSize);
             }
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL* imageURL)
             {
                 NSLog(@"downloadImageWithURL complete...");
                 if (image)
                 {
                     NSLog(@"downloadImageWithURL complete...image downloaded succ");
                     // Do something with the image; cacheType tells you if it was cached or not.
                     JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
                     
                     JSQMessage *photoMessage = [JSQMessage messageWithSenderId:kJSQDemoAvatarIdAgent
                                                                    displayName:self.chatx.AgentID
                                                                          media:photoItem];
                     photoItem.appliesMediaViewMaskAsOutgoing = false;
                     
                     [self.demoData.messages addObject:photoMessage];
                     [self finishSendingMessageAnimated:YES];
                     
                     
                 }
                 else{
                     NSLog(@"downloadImageWithURL complete...image downloaded failed..%@",error.description);
                 }
             }];
            

        }
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
}

-(NSString*)getTimeAndRandom{
    int iRandom=arc4random();
    if (iRandom<0) {
        iRandom=-iRandom;
    }
    
    NSDateFormatter *tFormat=[[NSDateFormatter alloc] init] ;
    [tFormat setDateFormat:@"yyyyMMddHHmmss"];
    NSString *tResult=[NSString stringWithFormat:@"%@%d",[tFormat stringFromDate:[NSDate date]],iRandom];
    return tResult;
}

- (void)UploadImageFromImage:(UIImage*) image
{
    @try{
        //FileUpload.aspx
        NSString* url = [self.chatx.FileUploadUrl stringByAppendingString: @"FileUpload.aspx"];
        NSLog(@"UploadImageFromFilePath url->%@...",url);
        
        
        
        NSData *data = UIImagePNGRepresentation(image);
        NSString* fileName = [[self getTimeAndRandom] stringByAppendingString:@".png"];
        
        
        
        fileName = [self.chatx.deviceid stringByAppendingString:fileName];
        
        currentUploadType = 0;
        currentUploadFileName = fileName;
        
        /*
         NSData *data2 = UIImageJPEGRepresentation(image, 1);
         就是运用这两个方法中的一个把图片转化为二进制数据data
         然后就是吧data上传到网络上。在这里我用了一个网络请求的第三方库 ASIFormDataRequest
         具体代码如下
         */
        
        // 用URL初始化请求
        ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
        // 设置代理
        [request setDelegate:self];
        // 为上传对象添加数据 数据
        [request addData:data withFileName:fileName andContentType:@"image/png" forKey:@"File1"];
        // 上传后保存的名字 // 保存类型 // 表单名 和 相应的php 文件相对
        [request startAsynchronous];//开始。异步
        
        JSQPhotoMediaItem *photoItem = [[JSQPhotoMediaItem alloc] initWithImage:image];
        
        JSQMessage *photoMessage = [JSQMessage messageWithSenderId:self.senderId
                                                       displayName:self.senderDisplayName
                                                             media:photoItem];
        photoItem.appliesMediaViewMaskAsOutgoing = true;
        
        [self.demoData.messages addObject:photoMessage];
        [self finishSendingMessageAnimated:YES];

        
        
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
    
    
}

- (void) UploadVideoFromFilePath:(NSString*) filePath
{
    @try{
        //FileUpload.aspx
        NSString* url = [self.chatx.FileUploadUrl stringByAppendingString: @"FileUpload.aspx"];
        NSLog(@"UploadVideoFromFilePath url->%@...filePath->%@",url,filePath);
        
        
        
        
        
        NSData  *data=[NSData dataWithContentsOfFile:filePath];  //二进制数据
        NSString* fileName = [[self getTimeAndRandom] stringByAppendingString:@".mp4"];
        
        //NSString *fileName=[filePath lastPathComponent];
        //文件名
        
        currentUploadType = 1;
        currentUploadFileName = fileName;
        
        
        // 用URL初始化请求
        ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
        // 设置代理
        [request setDelegate:self];
        // 为上传对象添加数据 数据
        
        [request addData:data withFileName:fileName andContentType:@"multipart/form-data" forKey:@"File1"];
        // 上传后保存的名字 // 保存类型 // 表单名 和 相应的php 文件相对
        [request setTimeOutSeconds:500];
        [request setRequestMethod:@"POST"];
        [request setUploadProgressDelegate:self];
        request.showAccurateProgress = true;
        [request startAsynchronous];//开始。异步
        
        //filePath = [@"file://" stringByAppendingString:filePath];
        
        
        
        NSString* sReason = [NSString stringWithFormat:@"#NOTICE#视频上传中"];
        
        
        [self ShowVisitorMsg:sReason];
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
}




- (void) UploadImageFromFilePath:(NSString*) filePath
{
    @try{
        //FileUpload.aspx
        NSString* url = [self.chatx.FileUploadUrl stringByAppendingString: @"FileUpload.aspx"];
        NSLog(@"UploadImageFromFilePath url->%@...filePath->%@",url,filePath);
        
        
        
        UIImage *image = [UIImage imageNamed:filePath];
        
        NSData *data = UIImagePNGRepresentation(image);
        NSString* fileName = [filePath lastPathComponent];
        /*
        NSData *data2 = UIImageJPEGRepresentation(image, 1);
        就是运用这两个方法中的一个把图片转化为二进制数据data
        然后就是吧data上传到网络上。在这里我用了一个网络请求的第三方库 ASIFormDataRequest
        具体代码如下
         */
        
        currentUploadType = 0;
        currentUploadFileName = fileName;
        
        // 用URL初始化请求
        ASIFormDataRequest *request=[[ASIFormDataRequest alloc] initWithURL:[NSURL URLWithString:url]];
        // 设置代理
        [request setDelegate:self];
        // 为上传对象添加数据 数据
        [request addData:data withFileName:fileName andContentType:@"image/png" forKey:@"File1"];
        // 上传后保存的名字 // 保存类型 // 表单名 和 相应的php 文件相对
        [request startAsynchronous];//开始。异步
        
    
        
        
        
    }
    @catch(NSException* ex){
        NSLog(@"exception.name= %@" ,ex.name);
        NSLog(@"exception.reason= %@" ,ex.reason);
    }
    
    
}

-(void)setProgress:(float)newProgress{
    
    
    NSLog(@"uploadFile...%@",[NSString stringWithFormat:@"%0.f%%",newProgress*100]);
    
}

- (void)ShowVisitorMsg:(NSString *)sReason {
    JSQMessage * newMessage = [[JSQMessage alloc] initWithSenderId:self.senderId
                                                 senderDisplayName:self.senderDisplayName
                                                              date:[NSDate date]
                                                              text:NSLocalizedString(sReason, nil)];
    
    [self.demoData.messages addObject:newMessage];
    [self finishSendingMessageAnimated:YES];
}

- (void)requestFinished:(ASIHTTPRequest *)request {
    
    // Use when fetching text data
    
    //NSString *responseString = [request responseString];
    NSLog(@"UploadFile requestFinished...currentUploadFileName->%@",currentUploadFileName);
    
    if(currentUploadType == 0){
        [self.chatx VisitorSendImage:currentUploadFileName];
    }
    else{
        [self.chatx VisitorSendVideo:currentUploadFileName];
    }
    
    
    NSString* sReason = [NSString stringWithFormat:@"#NOTICE#文件上传成功"];
    
    
    [self ShowVisitorMsg:sReason];
    
    // Use when fetching binary data
    
    //NSData *responseData = [request responseData];
    
}
- (void)requestFailed:(ASIHTTPRequest *)request {
    
    NSError *error = [request error];
    NSLog(@"UploadFile requestFailed...%@",error.description);
    
    NSString* sReason = [NSString stringWithFormat:@"#NOTICE#文件上传失败:%@", error.description];
    
    
    [self ShowVisitorMsg:sReason];
    
}

@end


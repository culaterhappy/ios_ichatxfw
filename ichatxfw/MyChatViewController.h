//
//  MyChatViewController.h
//  MyMobile
//
//  Created by gant on 16/6/16.
//
//

#ifndef MyChatViewController_h
#define MyChatViewController_h

#import "JSQMessages.h"
#import "DemoModelData.h"
#import "ichatx.h"
//#import "MyVideoViewController.h"

@class MyChatViewController;

@protocol MyChatViewControllerDelegate <NSObject>

- (void)didDismissMyChatViewController:(MyChatViewController *)vc;


@end


@interface MyChatViewController : JSQMessagesViewController <UIActionSheetDelegate, JSQMessagesComposerTextViewPasteDelegate, UIImagePickerControllerDelegate,UINavigationControllerDelegate>


@property (weak, nonatomic) id<MyChatViewControllerDelegate> delegateModal;
@property (strong, nonatomic) DemoModelData *demoData;
@property (nonatomic, strong) ichatx *chatx;


- (void)receiveMessagePressed:(UIBarButtonItem *)sender;

- (void)closePressed:(UIBarButtonItem *)sender;

-(void)OnNewMsg:(NSString*)msg;

@end



#endif /* MyChatViewController_h */

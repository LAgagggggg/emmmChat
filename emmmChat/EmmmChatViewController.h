//
//  EmmmChatViewController.h
//  emmmChat
//
//  Created by 李嘉银 on 15/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmmmContact.h"
#import <Masonry.h>
#import "EmmmAttachmentWrapperView.h"

@interface EmmmChatViewController : UIViewController<UITextViewDelegate,UIGestureRecognizerDelegate>

-(instancetype)initWithContact:(EmmmContact *)contact;

@end

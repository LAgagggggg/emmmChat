//
//  EmmmMainViewController.h
//  emmmChat
//
//  Created by 李嘉银 on 14/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import "MyDataBase.h"
#import "EmmmContactCell.h"
#import "EmmmContact.h"
#import "EmmmChatViewController.h"

@interface EmmmMainViewController : UIViewController<UITableViewDataSource,UITableViewDelegate,UIGestureRecognizerDelegate>
@property(strong,nonatomic)NSString * userName;

@end

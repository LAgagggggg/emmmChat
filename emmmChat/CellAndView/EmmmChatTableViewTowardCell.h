//
//  EmmmChatTableViewTowardCell.h
//  emmmChat
//
//  Created by 李嘉银 on 27/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>
#import "EmmmMessage.h"

@interface EmmmChatTableViewTowardCell : UITableViewCell
@property(strong,nonatomic)UILabel * textView;
@property(strong,nonatomic)UIImageView * iconView;

-(void)setWithIcon:(UIImage *)icon andMessage:(EmmmMessage *)message;

@end

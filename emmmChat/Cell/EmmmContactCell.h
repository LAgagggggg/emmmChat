//
//  emmmContacterCell.h
//  emmmChat
//
//  Created by 李嘉银 on 14/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EmmmContact.h"
#import <Masonry.h>

@interface EmmmContactCell : UITableViewCell
@property(strong,nonatomic)UIImageView * iconImageView;
@property(strong,nonatomic)UILabel * nameLabel;
@property(strong,nonatomic)UILabel * timeLabel;
@property(strong,nonatomic)UILabel * lastMessageLabel;
@property(strong,nonatomic)UILabel * unReaderCountView;

-(void)SetWithContact:(EmmmContact *)contact;

@end

//
//  EmmmPullMenuView.h
//  emmmChat
//
//  Created by 李嘉银 on 30/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

@interface EmmmPullMenuView : UIView
@property (strong,nonatomic)UIView * actualMenuView;
@property(strong,nonatomic)UIImageView * iconImageView;
@property CGFloat setedPushWidth;

-(instancetype)initWithIcon:(UIImage *)icon andTapGestureRecognizer:(UITapGestureRecognizer *)tap;
-(void)setAvatar:(UIImage *)avatar;
@end

//
//  EmmmPullMenuView.m
//  emmmChat
//
//  Created by 李嘉银 on 30/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//
#define WIDTH ([UIScreen mainScreen].bounds.size.width*3/4)
#define PAN_DETECTED_ZONEWIDTH 44
#import "EmmmPullMenuView.h"

@implementation EmmmPullMenuView

- (instancetype)initWithIcon:(UIImage *)icon andTapGestureRecognizer:(UITapGestureRecognizer *)tap
{
    self = [super init];
    if (self) {
        self.setedPushWidth=WIDTH;
        self.frame=CGRectMake(-WIDTH, 0, PAN_DETECTED_ZONEWIDTH+WIDTH, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor=[UIColor clearColor];
        self.actualMenuView=[[UIView alloc]init];
        self.actualMenuView.backgroundColor=[UIColor darkGrayColor];
        [self addSubview:self.actualMenuView];
        [self.actualMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.right.equalTo(self.mas_right).with.offset(-PAN_DETECTED_ZONEWIDTH);
        }];
        self.iconImageView=[[UIImageView alloc]init];
        [self.actualMenuView addSubview:self.iconImageView];
        [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.actualMenuView.mas_centerX);
            make.centerY.equalTo(self.actualMenuView.mas_centerY);
            make.width.equalTo(@(80));
            make.height.equalTo(@(80));
        }];
        [self setAvatar:icon];
        self.iconImageView.userInteractionEnabled=YES;
        [self.iconImageView addGestureRecognizer:tap];
    }
    return self;
}

-(void)setAvatar:(UIImage *)icon{
    //设置图像边框
    CGFloat borderW = 10;
    CGSize size = CGSizeMake(icon.size.width + 2 *borderW, icon.size.height + 2 * borderW);
    UIGraphicsBeginImageContextWithOptions(size,NO,0);
    UIBezierPath *path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, size.width, size.height)];
    [[UIColor whiteColor] set];
    [path fill];
    path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(borderW, borderW, icon.size.width, icon.size.height)];
    [path addClip];
    [icon drawAtPoint:CGPointMake(borderW, borderW)];
    UIImage *clipIcon = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [self.iconImageView setImage:clipIcon];
}

@end

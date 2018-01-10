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
        self.logoutBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        self.logoutBtn.backgroundColor=[UIColor whiteColor];
        self.logoutBtn.layer.cornerRadius=10.f;
        [self.logoutBtn setTitle:@"注销" forState:UIControlStateNormal];
        [self.actualMenuView addSubview:self.logoutBtn];
        [self.logoutBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.actualMenuView.mas_right).with.offset(-10);
            make.bottom.equalTo(self.actualMenuView.mas_bottom).with.offset(-20);
            make.width.equalTo(@(100));
            make.height.equalTo(@(50));
        }];
        self.changePasswordBtn=[UIButton buttonWithType:UIButtonTypeSystem];
        self.changePasswordBtn.backgroundColor=[UIColor whiteColor];
        self.changePasswordBtn.layer.cornerRadius=10.f;
        [self.changePasswordBtn setTitle:@"修改密码" forState:UIControlStateNormal];
        [self.actualMenuView addSubview:self.changePasswordBtn];
        [self.changePasswordBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.logoutBtn.mas_left).with.offset(-10);
            make.bottom.equalTo(self.actualMenuView.mas_bottom).with.offset(-20);
            make.width.equalTo(@(100));
            make.height.equalTo(@(50));
        }];
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

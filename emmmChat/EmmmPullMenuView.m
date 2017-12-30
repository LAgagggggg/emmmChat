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

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.setedPushWidth=WIDTH;
        self.frame=CGRectMake(-WIDTH, 0, PAN_DETECTED_ZONEWIDTH+WIDTH, [UIScreen mainScreen].bounds.size.height);
        self.backgroundColor=[UIColor clearColor];
        self.actualMenuView=[[UIView alloc]init];
        self.actualMenuView.backgroundColor=[UIColor yellowColor];
        [self addSubview:self.actualMenuView];
        [self.actualMenuView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left);
            make.top.equalTo(self.mas_top);
            make.bottom.equalTo(self.mas_bottom);
            make.right.equalTo(self.mas_right).with.offset(-PAN_DETECTED_ZONEWIDTH);
        }];
    }
    return self;
}

@end

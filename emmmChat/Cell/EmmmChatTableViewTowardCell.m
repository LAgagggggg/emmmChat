//
//  EmmmChatTableViewTowardCell.m
//  emmmChat
//
//  Created by 李嘉银 on 27/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//
#define TEXTINSETS 10
#import "EmmmChatTableViewTowardCell.h"

@implementation EmmmChatTableViewTowardCell

-(void)setWithIcon:(UIImage *)icon andMessage:(EmmmMessage *)message{
    for (UIView *subview in [self.contentView subviews]) {
        [subview removeFromSuperview];
    }
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right);
        make.left.equalTo(self.mas_left);
        make.top.equalTo(self.mas_top);
        make.bottom.equalTo(self.mas_bottom);
    }];
    self.backgroundColor=[UIColor clearColor];
    self.iconView=[[UIImageView alloc]initWithImage:icon];
    [self.contentView addSubview:self.iconView];
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.contentView.mas_right).with.offset(-15);
        make.top.equalTo(self.contentView.mas_top).with.offset(7.5);
        make.height.equalTo(@(45));
        make.width.equalTo(@(45));
    }];
    self.iconView.layer.cornerRadius=10.f;
    self.iconView.layer.masksToBounds=YES;
    self.textView=[[UILabel alloc]init];
    self.textView.text=message.text;
    self.textView.numberOfLines=0;
    [self.textView setFont:[UIFont systemFontOfSize:14]];
    self.textView.lineBreakMode=NSLineBreakByCharWrapping;
    self.textView.preferredMaxLayoutWidth=[UIScreen mainScreen].bounds.size.width*2/3;
    self.textView.backgroundColor=[UIColor clearColor];
    self.textView.textColor=[UIColor blackColor];
    UIView * textViewWrapperView=[[UIView alloc]init];
    textViewWrapperView.backgroundColor=[UIColor whiteColor];
    textViewWrapperView.layer.cornerRadius=10.f;
    [self.contentView addSubview:textViewWrapperView];
    [self.contentView addSubview:self.textView];
    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.mas_right).with.offset(-(67.5+TEXTINSETS));
        make.top.equalTo(self.iconView.mas_top).with.offset(TEXTINSETS);
    }];
    [textViewWrapperView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.textView.mas_right).with.offset(TEXTINSETS);
        make.left.equalTo(self.textView.mas_left).with.offset(-TEXTINSETS);
        make.top.equalTo(self.textView.mas_top).with.offset(-TEXTINSETS);
        make.bottom.equalTo(self.textView.mas_bottom).with.offset(TEXTINSETS);
    }];
//    [self.textView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.right.equalTo(self.mas_right).with.offset(-67.5);
//        make.top.equalTo(self.iconView.mas_top).with.offset(7.5);
//    }];
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.greaterThanOrEqualTo(self.iconView.mas_bottom).with.offset(7.5);
        make.bottom.greaterThanOrEqualTo(self.textView.mas_bottom).with.offset(7.5+TEXTINSETS);
    }];
}

@end

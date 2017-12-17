//
//  EmmmAttachmentWrapperView.m
//  emmmChat
//
//  Created by 李嘉银 on 17/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import "EmmmAttachmentWrapperView.h"

@implementation EmmmAttachmentWrapperView

-(instancetype)initWithImage:(UIImage *)image{
    self=[super init];
    self.frame=CGRectMake(0, 0, 90, 90);
    self.layer.cornerRadius=10.f;
    self.backgroundColor=[UIColor whiteColor];
    self.image=image;
    UIImageView * imageView=[[UIImageView alloc]initWithImage:self.image];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(10);
        make.left.equalTo(self.mas_left).with.offset(10);
        make.right.equalTo(self.mas_right).with.offset(-10);
        make.bottom.equalTo(self.mas_bottom).with.offset(-10);
    }];
    return self;
}

@end

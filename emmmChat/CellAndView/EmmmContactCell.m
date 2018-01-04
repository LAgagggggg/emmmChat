//
//  emmmContacterCell.m
//  emmmChat
//
//  Created by 李嘉银 on 14/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//
#define lightBlueColor [UIColor colorWithRed:225/255. green:238/255. blue:253/255. alpha:1]
#import "EmmmContactCell.h"

@implementation EmmmContactCell

-(void)SetWithContact:(EmmmContact *)contact{
    for (UIView *subview in [self.contentView subviews]) {
        [subview removeFromSuperview];
    }
    self.selectedBackgroundView.layer.cornerRadius=10.f;
    self.selectedBackgroundView.layer.masksToBounds=YES;
    self.backgroundColor=lightBlueColor;
    self.layer.cornerRadius=10.f;
    //icon
    self.iconImageView=[[UIImageView alloc]initWithImage:contact.iconImage];
    [self addSubview:self.iconImageView];
    [self.iconImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(8.5);
        make.left.equalTo(self.mas_left).with.offset(11);
        make.bottom.equalTo(self.mas_bottom).with.offset(-8.5);
        make.width.equalTo(self.iconImageView.mas_height);
    }];
    self.iconImageView.layer.cornerRadius=10.f;
    self.iconImageView.layer.masksToBounds=YES;
    self.iconImageView.backgroundColor=[UIColor whiteColor];
    //名字
    self.nameLabel=[[UILabel alloc]init];
    self.nameLabel.text=contact.name;
    [self addSubview:self.nameLabel];
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.mas_top).with.offset(6);
        make.left.equalTo(self.iconImageView.mas_right).with.offset(14);
        make.right.equalTo(self.mas_right).with.offset(-40);
        make.height.equalTo(@(20));
    }];
    [self.nameLabel setFont:[UIFont systemFontOfSize:18 weight:UIFontWeightSemibold]];
    //最后一条消息
    self.lastMessageLabel=[[UILabel alloc]init];
    self.lastMessageLabel.text=contact.lastMessage;
    [self addSubview:self.lastMessageLabel];
    self.lastMessageLabel.textColor=[UIColor darkGrayColor];
    [self.lastMessageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).with.offset(2.5);
        make.left.equalTo(self.iconImageView.mas_right).with.offset(14);
        make.right.equalTo(self.mas_right).with.offset(-40);
        make.height.equalTo(@(20));
    }];
    [self.lastMessageLabel setFont:[UIFont systemFontOfSize:16 weight:UIFontWeightRegular]];
    //时间
    self.timeLabel=[[UILabel alloc]init];
    self.timeLabel.text=contact.lastMessageTime;
    [self addSubview:self.timeLabel];
    self.timeLabel.textColor=[UIColor grayColor];
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
         make.top.equalTo(self.lastMessageLabel.mas_bottom).with.offset(4);
         make.left.equalTo(self.iconImageView.mas_right).with.offset(14);
         make.right.equalTo(self.mas_right).with.offset(-40);
         make.height.equalTo(@(12));
     }];
     [self.timeLabel setFont:[UIFont systemFontOfSize:10 weight:UIFontWeightThin]];
    //右边小蓝点
    if (contact.unReaderCount>0) {
        self.unReaderCountView=[[UILabel alloc]init];
        [self addSubview:self.unReaderCountView];
        [self.unReaderCountView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mas_top).with.offset(24);
            make.bottom.equalTo(self.mas_bottom).with.offset(-24);
            make.right.equalTo(self.mas_right).with.offset(-19.5);
            make.width.equalTo(self.unReaderCountView.mas_height);
        }];
        self.unReaderCountView.layer.backgroundColor=[UIColor colorWithRed:70/255. green:128/255. blue:247/255. alpha:1].CGColor;
        if (contact.unReaderCount<10) {
            self.unReaderCountView.text=[@(contact.unReaderCount) stringValue];
        }
        else{
            self.unReaderCountView.text=@"……";
        }
        //获取layout后的height
        [self layoutIfNeeded];
        CGFloat height = [self.unReaderCountView systemLayoutSizeFittingSize:
                          UILayoutFittingCompressedSize].height;
        self.unReaderCountView.textAlignment=NSTextAlignmentCenter;
        self.unReaderCountView.layer.cornerRadius=height/3;
        self.unReaderCountView.textColor=[UIColor whiteColor];
        [self.unReaderCountView setFont:[UIFont systemFontOfSize:11]];
    }
}

- (void)setFrame:(CGRect)frame {
    frame.size.height -= 7.5;    // 减掉的值就是分隔线的高度
    [super setFrame:frame];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end

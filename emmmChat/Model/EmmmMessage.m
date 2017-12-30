//
//  EmmmMessage.m
//  emmmChat
//
//  Created by 李嘉银 on 27/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import "EmmmMessage.h"

@implementation EmmmMessage


-(instancetype)initMessageWithText:(NSString *)text andFrom:(NSString *)fromUser To:(NSString *)toUser{
    self=[super init];
    self.text=text;
    self.fromUser=fromUser;
    self.toUser=toUser;
    self.sentDate=[NSDate date];
    return self;
}

@end

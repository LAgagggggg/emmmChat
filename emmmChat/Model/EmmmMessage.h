//
//  EmmmMessage.h
//  emmmChat
//
//  Created by 李嘉银 on 27/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EmmmMessage : NSObject
@property(strong,nonatomic)NSString * text;
@property(strong,nonatomic)NSString * fromUser;
@property(strong,nonatomic)NSString * toUser;
@property(strong,nonatomic)NSDate * sentDate;

-(instancetype)initMessageWithText:(NSString *)text andFrom:(NSString *)fromUser To:(NSString *)toUser;
@end

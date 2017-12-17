//
//  EmmmContacter.h
//  emmmChat
//
//  Created by 李嘉银 on 14/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface EmmmContact : NSObject
@property(strong,nonatomic)UIImage * iconImage;
@property(strong,nonatomic)NSString * name;
@property(strong,nonatomic)NSString * lastMessage;
@property(strong,nonatomic)NSString * lastMessageTime;
@property int unReaderCount;
@end

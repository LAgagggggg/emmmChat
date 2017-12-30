//
//  EmmmContacter.m
//  emmmChat
//
//  Created by 李嘉银 on 14/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import "EmmmContact.h"

@implementation EmmmContact
-(BOOL)WriteWithFMDB:(MyDataBase *)db andTableName:(NSString *)tableName{
    BOOL result;
    NSData * imageData=UIImagePNGRepresentation(self.iconImage);
    NSString * sql=[NSString stringWithFormat:@"insert into %@(name,iconImage,lastMessage,lastMessageTime,unReaderCount) VALUES(?,?,?,?,?);",tableName];
    NSNumber * unReaderCount = [NSNumber numberWithInt:self.unReaderCount];
    result=[db executeUpdate:sql,self.name,imageData,self.lastMessage,self.lastMessageTime, unReaderCount];
    return result;
}

@end

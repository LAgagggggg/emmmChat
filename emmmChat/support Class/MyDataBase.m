//
//  MyFMDB.m
//  testApp
//
//  Created by 李嘉银 on 23/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import "MyDataBase.h"


@implementation MyDataBase

+(instancetype)sharedInstance{
    
    static FMDatabase *db = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *doc =[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES)  lastObject];
        NSString *fileName = [doc stringByAppendingPathComponent:@"contact.sqlite"];
        db = [FMDatabase databaseWithPath:fileName];
        NSLog(@"-----------db---------\n%@",fileName);
    });
    return db;
}

@end

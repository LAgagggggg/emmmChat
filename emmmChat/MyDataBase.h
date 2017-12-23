//
//  MyFMDB.h
//  testApp
//
//  Created by 李嘉银 on 23/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB.h>

@interface MyDataBase : FMDatabase
+(instancetype)sharedInstance;
@end

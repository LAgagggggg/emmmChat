//
//  AppDelegate.m
//  emmmChat
//
//  Created by 李嘉银 on 13/12/2017.
//  Copyright © 2017 李嘉银. All rights reserved.
//

#import "AppDelegate.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window=[[UIWindow alloc]initWithFrame:[UIScreen mainScreen].bounds];
    NSUserDefaults * defaults=[NSUserDefaults standardUserDefaults];
    UINavigationController * nvc=[[UINavigationController alloc]init];
    LoginViewController * loginvc=[[LoginViewController alloc]init];
    if ([defaults boolForKey:@"loginSuccessJudge"]) {
        NSString * userName=[defaults objectForKey:@"loginSuccessUserName"];
        EmmmMainViewController * mainvc=[[EmmmMainViewController alloc]initWithUserName:userName];
        [nvc setViewControllers:@[loginvc,mainvc] animated:YES];
    }
    else{
        [nvc pushViewController:loginvc animated:YES];
    }
    self.window.rootViewController = nvc;
    nvc.navigationBar.hidden=YES;
    [self.window makeKeyAndVisible];
    //检测网络状态
    AFNetworkReachabilityManager *reachabilityManager = [AFNetworkReachabilityManager sharedManager];
    [reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status==AFNetworkReachabilityStatusNotReachable) {
            UIAlertController * alert=[UIAlertController alertControllerWithTitle:@"无连接" message:@"emmm网络似乎有问题" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            }];
            [alert addAction:defaultAction];
            [nvc presentViewController:alert animated:YES completion:nil];
            NSLog(@"%@",nvc.presentingViewController);
        }
    }];
    [reachabilityManager startMonitoring];
    return YES;
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end

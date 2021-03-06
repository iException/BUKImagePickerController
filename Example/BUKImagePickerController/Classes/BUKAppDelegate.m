//
//  BUKAppDelegate.m
//  BUKImagePickerController
//
//  Created by Yiming Tang on 07/08/2015.
//  Copyright (c) 2015 Yiming Tang. All rights reserved.
//

#import "BUKAppDelegate.h"
#import "BUKViewController.h"

@implementation BUKAppDelegate

#pragma mark - Accessors

@synthesize window = _window;

- (UIWindow *)window {
    if (!_window) {
        _window = [[UIWindow alloc] init];
        _window.frame = [[UIScreen mainScreen] bounds];
        _window.backgroundColor = [UIColor whiteColor];
    }
    return _window;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:[[BUKViewController alloc] init]];
    self.window.rootViewController = navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

@end

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
        _window.rootViewController = [[BUKViewController alloc] init];
    }
    return _window;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self.window makeKeyAndVisible];
    return YES;
}

@end

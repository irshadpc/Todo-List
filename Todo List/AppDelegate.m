//
//  AppDelegate.m
//  Todo List
//
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"
#import "ApiKey.h"
@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        NSDictionary *navbarTitleTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                                   [UIColor whiteColor],UITextAttributeTextColor,
                                                   [UIColor blackColor], UITextAttributeTextShadowColor,
                                                   [NSValue valueWithUIOffset:UIOffsetMake(-1, 0)], UITextAttributeTextShadowOffset, nil];
        
        [[UINavigationBar appearance] setTitleTextAttributes:navbarTitleTextAttributes];
        
        UISplitViewController *splitViewController = (UISplitViewController *)self.window.rootViewController;
        DetailViewController *detailViewController = (DetailViewController*)[(UINavigationController*)[splitViewController.viewControllers lastObject] topViewController];
        splitViewController.delegate = detailViewController;
    }
    [Appacitive appacitiveWithApiKey:API_KEY];
    return YES;
}
@end

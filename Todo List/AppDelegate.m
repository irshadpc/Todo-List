//
//  AppDelegate.m
//  Todo List
//
//  Created by Nikhil Prasad on 28/01/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "AppDelegate.h"
#import "DetailViewController.h"

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
    [Appacitive appacitiveWithApiKey:@"ukaAo61yoZoeTJsGacH9TDRHnhf/J9/kH2TStR5sD3k="];
    return YES;
}
@end

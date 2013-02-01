//
//  LoginViewController.h
//  Todo List
//
//  Created by Sandeep Dhull on 01/02/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^LoginSuccessfull) ();

@interface LoginViewController : UIViewController
@property (nonatomic, copy) LoginSuccessfull loginSuccessful;
@end

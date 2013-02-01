//
//  LoginViewController.m
//  Todo List
//
//  Created by Sandeep Dhull on 01/02/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "LoginViewController.h"
#import "UIImage+iPhone5.h"

@interface LoginViewController ()<UITextFieldDelegate> {
    UITextField *_activeTextField;
}
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordTextView;

@end

@implementation LoginViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.hidesBackButton = YES;
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage tallImageNamed:@"ipad-BG-pattern.png"]];
    [self.view setBackgroundColor:bgColor];

    
    self.userNameTextField.delegate = self;
    self.userPasswordTextView.delegate = self;
}

-(void)viewDidAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void) viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter]
     removeObserver:self];
}


- (void)keyboardWillHide:(NSNotification*) notification {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - UITextFiedlDelegate Method
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 20) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField.tag == 1) {
        [self.userPasswordTextView becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

- (IBAction)onLoginButtonClick:(id)sender {
    NSString *userName = self.userNameTextField.text;
    NSString *userPassword = self.userPasswordTextView.text;
    
    [APUser authenticateUserWithUserName:userName password:userPassword successHandler:^(){
        [self.navigationController popViewControllerAnimated:YES];
        if(self.loginSuccessful != nil) {
            self.loginSuccessful();
        }
    }failureHandler:^(APError *error) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Login Failed" message:error.description  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
        
    
}
@end

//
//  RegisterViewController.m
//  Todo List
//
//  Created by Sandeep Dhull on 01/02/13.
//  Copyright (c) 2013 Appacitive Software Pvt. Ltd. All rights reserved.
//

#import "RegisterViewController.h"
#import "UIImage+iPhone5.h"

@interface RegisterViewController ()<UITextFieldDelegate> {
    
}

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userEmailTextField;
@property (weak, nonatomic) IBOutlet UITextField *userFirstNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *userPasswordTextField;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@end

@implementation RegisterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor* bgColor = [UIColor colorWithPatternImage:[UIImage tallImageNamed:@"ipad-BG-pattern.png"]];
    [self.view setBackgroundColor:bgColor];
    
    self.userNameTextField.delegate = self;
    self.userPasswordTextField.delegate = self;
    self.userFirstNameTextField.delegate =  self;
    self.userEmailTextField.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (IBAction)onRegisterButtonClick:(id)sender {
    
    NSString *userName = self.userNameTextField.text;
    NSString *userEmail = self.userEmailTextField.text;
    NSString *firstName = self.userFirstNameTextField.text;
    NSString *userPassword = self.userPasswordTextField.text;
    
    APUserDetails *details = [[APUserDetails alloc] init];
    [details setUsername:userName];
    [details setFirstName:firstName];
    [details setEmail:userEmail];
    [details setPassword:userPassword];
    
    [APUser createUserWithDetails:details successHandler:^(APUser *user) {
        [self.navigationController popViewControllerAnimated:YES];
    } failuderHandler:^(APError *error) {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Error" message:error.description  delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }];
    
}

- (void)keyboardWillHide:(NSNotification*) notification {
    [_scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
}


#pragma mark - UITextFiedlDelegate Method
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_scrollView setContentOffset:CGPointMake(0, textField.frame.origin.y - 10) animated:YES];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    if(textField == self.userNameTextField) {
        [self.userEmailTextField becomeFirstResponder];
    } else if(textField == self.userEmailTextField){
        [self.userFirstNameTextField becomeFirstResponder];
    } else if(textField == self.userFirstNameTextField){
        [self.userPasswordTextField becomeFirstResponder];
    } else {
        [textField resignFirstResponder];
    }
    return YES;
}

@end

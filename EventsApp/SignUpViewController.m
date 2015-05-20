//
//  SignUpViewController.m
//  BeerMe
//
//  Created by Charley Luckhardt on 2/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "SignUpViewController.h"
#import <Parse/Parse.h>
#import "Comms.h"

@interface SignUpViewController () <CommsDelegate> {
    
    __weak IBOutlet UITextField *usernameTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UIButton *signUpButton;
    __weak IBOutlet UILabel *errorLabel;
    __weak IBOutlet UIActivityIndicatorView *activitySignUp;
}

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleSignUp:(id)sender {
    // Disable the Login button to prevent multiple touches
    [signUpButton setEnabled:NO];
    
    // Show an activity indicator
    [activitySignUp startAnimating];
    
    // Do the login
    [Comms signUp:self withUsername:usernameTextField.text password:passwordTextField.text];
}

- (void)commsDidSignUp:(BOOL)signedUp withError:(NSError *)error {
    // Re-enable the Login button
    [signUpButton setEnabled:YES];
    
    // Stop the activity indicator
    [activitySignUp stopAnimating];
    
    // Did we login successfully ?
    if (signedUp) {
        // Seque to the Image Wall
        [self performSegueWithIdentifier:@"SignUpSuccessful" sender:self];
    } else {
        // Show error alert
        errorLabel.text = [error localizedDescription];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

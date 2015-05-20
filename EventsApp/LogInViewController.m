//
//  LogInViewController.m
//  BeerMe
//
//  Created by Charley Luckhardt on 2/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "LogInViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "Comms.h"

@interface LogInViewController () <CommsDelegate> {
    
    __weak IBOutlet UITextField *usernameTextField;
    __weak IBOutlet UITextField *passwordTextField;
    __weak IBOutlet UIButton *loginButton;
    __weak IBOutlet UIButton *facebookConnectButton;
    __weak IBOutlet UILabel *errorLabel;
    __weak IBOutlet UIActivityIndicatorView *activityLogin;
}

@end

@implementation LogInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleLogIn:(id)sender {
    // Disable the Login button to prevent multiple touches
    [loginButton setEnabled:NO];
    
    // Show an activity indicator
    [activityLogin startAnimating];
    NSLog(@"%@, %@", usernameTextField.text, passwordTextField.text);
    // Do the login
    [Comms login:self withUsername:usernameTextField.text password:passwordTextField.text];
}

- (void)commsDidLogin:(BOOL)loggedIn withError:(NSError *)error{
    // Re-enable the Login button
    [loginButton setEnabled:YES];
    
    // Stop the activity indicator
    [activityLogin stopAnimating];
    
    // Did we login successfully ?
    if (loggedIn) {
        // Seque to the Image Wall
        [self performSegueWithIdentifier:@"LoginSuccessful" sender:self];
    } else {
        // Show error alert
        errorLabel.text = [error localizedDescription];
    }
}

- (IBAction)handleFBLogin:(id)sender {
    // Disable the Login button to prevent multiple touches
    [facebookConnectButton setEnabled:NO];
    
    // Show an activity indicator
    [activityLogin startAnimating];
    
    // Do the login
    [Comms loginWithFB:self];
}

- (void) commsDidLoginWithFB:(BOOL)loggedIn {
    // Re-enable the Login button
    [facebookConnectButton setEnabled:YES];
    
    // Stop the activity indicator
    [activityLogin stopAnimating];
    
    // Did we login successfully ?
    if (loggedIn) {
        // Seque to the Image Wall
        [self performSegueWithIdentifier:@"LoginSuccessful" sender:self];
    } else {
        // Show error alert
        [[[UIAlertView alloc] initWithTitle:@"Login Failed"
                                    message:@"Facebook Login failed. Please try again"
                                   delegate:nil
                          cancelButtonTitle:@"Ok"
                          otherButtonTitles:nil] show];
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

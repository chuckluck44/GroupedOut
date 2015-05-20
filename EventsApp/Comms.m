//
//  Comms.m
//  BeerMe
//
//  Created by Charley Luckhardt on 2/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "Comms.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@implementation Comms

+ (void)login:(id<CommsDelegate>)delegate withUsername:(NSString *)username password:(NSString *)password{
    
    [PFUser logInWithUsernameInBackground:username password:password block:^(PFUser *user, NSError *error) {
        if (user) {
            if ([delegate respondsToSelector:@selector(commsDidLogin:withError:)]) {
                [delegate commsDidLogin:YES withError:nil];
            }
        } else {
            // The login failed. Check error to see why.
            if ([delegate respondsToSelector:@selector(commsDidLogin:withError:)]) {
                [delegate commsDidLogin:NO withError:error];
            }
        }
    }];
}

+ (void) loginWithFB:(id<CommsDelegate>)delegate
{
    // Basic User information and your friends are part of the standard permissions
    // so there is no reason to ask for additional permissions
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"user_friends"] block:^(PFUser *user, NSError *error) {
        // Was login successful ?
        if (!user) {
            if (!error) {
                NSLog(@"The user cancelled the Facebook login.");
            } else {
                NSLog(@"An error occurred: %@", error.localizedDescription);
            }
            
            // Callback - login failed
            if ([delegate respondsToSelector:@selector(commsDidLoginWithFB:)]) {
                [delegate commsDidLoginWithFB:NO];
            }
        } else {
            if (user.isNew) {
                NSLog(@"User signed up and logged in through Facebook!");
            } else {
                NSLog(@"User logged in through Facebook!");
            }
            
            // Callback - login successful
            if ([delegate respondsToSelector:@selector(commsDidLoginWithFB:)]) {
                [delegate commsDidLoginWithFB:YES];
            }
        }
    }];
}

+ (void)signUp:(id<CommsDelegate>)delegate withUsername:(NSString *)username password:(NSString *)password {
    PFUser *user = [PFUser user];
    user.username = username;
    user.password = password;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            if ([delegate respondsToSelector:@selector(commsDidSignUp:withError:)]) {
                [delegate commsDidSignUp:YES withError:nil];
            }
        } else {
            if ([delegate respondsToSelector:@selector(commsDidSignUp:withError:)]) {
                [delegate commsDidSignUp:NO withError:error];
            }
        }
    }];
}

@end

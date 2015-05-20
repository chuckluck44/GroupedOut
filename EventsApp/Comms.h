//
//  Comms.h
//  BeerMe
//
//  Created by Charley Luckhardt on 2/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CommsDelegate <NSObject>

@optional

- (void) commsDidLogin:(BOOL)loggedIn withError:(NSError *)error;
- (void) commsDidLoginWithFB:(BOOL)loggedIn;

- (void) commsDidSignUp:(BOOL)signedUp withError:(NSError *)error;

@end

@interface Comms : NSObject

+ (void)login:(id<CommsDelegate>)delegate withUsername:(NSString *)username password:(NSString *)password;
+ (void) loginWithFB:(id<CommsDelegate>)delegate;

+ (void)signUp:(id<CommsDelegate>)delegate withUsername:(NSString *)username password:(NSString *)password;

@end

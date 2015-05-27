//
//  Comms.h
//  BeerMe
//
//  Created by Charley Luckhardt on 2/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataStore.h"
#import "GOMessagesViewController.h"

extern NSString *const N_UserLocationFound;
extern NSString *const N_ProfilePictureLoaded;

@protocol CommsDelegate <NSObject>

@optional

- (void)commsDidLoginWithFB:(BOOL)loggedIn;

- (void)commsDidUpdateUserLocation:(BOOL)success;
- (void)commsDidSendInvite:(BOOL)success;

- (void)commsUploadEventComplete:(BOOL)success withId:(NSString *)eventId;
- (void)commsUpdateEventComplete:(BOOL)success;
- (void)commsDeleteEventComplete:(BOOL)success;

- (void)commsAddUserToEventComplete:(BOOL)success;
- (void)commsRemoveUserFromEventComplete:(BOOL)success;

- (void)commsUploadEventCommentComplete:(BOOL)success;

- (void)commsDidGetNewEvents:(BOOL)success;
- (void)commsDidGetNewWallUpdates:(BOOL)success;
- (void)commsDidGetNewNotifications:(BOOL)success;

- (void)commsDidGetPreviousWallUpdates:(BOOL)success;

- (void)commsDidGetWallUpdatesForUser:(BOOL)success;
- (void)commsDidGetPreviousWallUpdatesForUser:(BOOL)success;

- (void)commsDidGetNewEventComments:(BOOL)success;

- (void)commsSendMessageComplete:(BOOL)success;
- (void)commsDidGetNewMessages:(BOOL)success;

- (void)commsDidGetFBProfiles:(BOOL)success;

//- (void)commsDidLogin:(BOOL)loggedIn withError:(NSError *)error;
//- (void)commsDidSignUp:(BOOL)signedUp withError:(NSError *)error;

@end

@interface Comms : NSObject


+ (void)loginWithFB:(id<CommsDelegate>)delegate;

+ (void)uploadEvent:(GOEvent *)event forDelegate:(id<CommsDelegate>)delegate;
+ (void)updateEvent:(NSString *)eventId withEvent:(GOEvent *)event forDelegate:(id<CommsDelegate>)delegate;
+ (void)deleteEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate;

+ (void)uploadEventComment:(NSString *)comment onEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate;
+ (void)addUserToEvent:(NSString *)eventId withUser:(NSDictionary *)secondUser forDelegate:(id<CommsDelegate>)delegate;
+ (void)removeUserFromEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate;

+ (void) getEventsSinceLastUpdateForDelegate:(id<CommsDelegate>)delegate;

+ (void)getWallUpdatesSinceLastUpdateForDelegate:(id<CommsDelegate>)delegate;
+ (void)getPreviousWallUpdatesForDelegate:(id<CommsDelegate>)delegate;
+ (void)getWallUpdatesForUser:(NSString *)userId forDelegate:(id<CommsDelegate>)delegate;
+ (void)getPreviousWallUpdatesForUser:(NSString *)userId forDelegate:(id<CommsDelegate>)delegate;

+ (void)getNotificationsSinceLastUpdateForDelegate:(id<CommsDelegate>)delegate;
+ (void)getCommentsForEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate;

+ (void)sendMessage:(GOMessage *)message forEvent:(NSString *)eventId forDelegate:(GOMessagesViewController<CommsDelegate> *)delegate;
+ (void)getMessagesForEvent:(NSString *)eventId forDelegate:(GOMessagesViewController<CommsDelegate> *)delegate;

+ (void)updateUserLocationForDelegate:(id<CommsDelegate>)delegate;

+ (void)getFBProfilesForIds:(NSArray *)fbIds forDelegate:(id<CommsDelegate>)delegate;

+ (void)inviteUsers:(NSArray *)userIds toEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate;

//+ (void)login:(id<CommsDelegate>)delegate withUsername:(NSString *)username password:(NSString *)password;
//+ (void)signUp:(id<CommsDelegate>)delegate withUsername:(NSString *)username password:(NSString *)password;

@end

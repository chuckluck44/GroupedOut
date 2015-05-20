//
//  Comms.m
//  BeerMe
//
//  Created by Charley Luckhardt on 2/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "Comms.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "DataStore.h"
#import <Parse/Parse.h>
#import "Event.h"
#import "NSOperationQueue+SharedQueue.h"
#import "GOLocationManager.h"

NSString *const N_UserLocationFound = @"N_UserLocationFound";
NSString * const N_ProfilePictureLoaded = @"N_ProfilePictureLoaded";

@interface Comms ()

+ (void)getFBFriends;
+ (void)getProfilePictureForUser:(GOUser *)user;

@end

@implementation Comms

+ (void) loginWithFB:(id<CommsDelegate>)delegate
{
    [PFFacebookUtils logInWithPermissions:@[@"public_profile", @"user_friends"] block:^(PFUser *user, NSError *error) {
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
            [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    NSDictionary<FBGraphUser> *me = (NSDictionary<FBGraphUser> *)result;
                    // Store the Facebook Id
                    [[PFUser currentUser] setObject:me.objectID forKey:@"fbId"];
                    [[PFUser currentUser] setObject:me.name forKey:@"fbUsername"];
                    [[PFUser currentUser] saveInBackground];
                    
                    GOUser *user = [[GOUser alloc] initWithPFUser:[PFUser currentUser]];
                    // Add the User to the list of friends in the DataStore
                    [[DataStore instance].fbFriends setObject:user forKey:user.fbId];
                    
                    [self getProfilePictureForUser:[GOUser currentUser]];
                }
                
                [Comms getFBFriends];
                
                if (user.isNew) {
                    
                    GOActivity *activity = [GOActivity object];
                    
                    activity.type = @"newUser";
                    activity.fromUserId = [[PFUser currentUser] objectForKey:@"fbId"];
                    activity.toUserIds = [[DataStore instance].fbFriends allKeys];
                    activity.content = [NSString stringWithFormat:@"%@ just joined groupedOut", [[PFUser currentUser] objectForKey:@"fbUsername"]];
                    
                    [activity saveEventually];
                    
                    NSData *imageData = UIImagePNGRepresentation([GOUser currentUser].profilePicture);
                    PFFile *imageFile = [PFFile fileWithName:@"profile_picture.png" data:imageData];
                    
                    [[PFUser currentUser] setObject:imageFile forKey:@"fbProfilePicture"];
                    [[PFUser currentUser] saveInBackground];
                }

                // Callback - login successful
                if ([delegate respondsToSelector:@selector(commsDidLoginWithFB:)]) {
                    [delegate commsDidLoginWithFB:YES];
                }
            }];
        }
    }];
}

+ (void)getFBFriends {
    FBRequest *friendsRequest = [FBRequest requestForMyFriends];
    [friendsRequest startWithCompletionHandler: ^(FBRequestConnection *connection, NSDictionary* result, NSError *error) {
        
        NSArray *friends = result[@"data"];
        for (NSDictionary<FBGraphUser>* friend in friends) {
            NSLog(@"Found a friend: %@", friend.name);
            
            GOUser *user = [[GOUser alloc] init];
            user.name = friend.name;
            user.fbId = friend.objectID;
            
            // Add the friend to the list of friends in the DataStore
            [[DataStore instance].fbFriends setObject:user forKey:user.fbId];
            
            [self getProfilePictureForUser:([DataStore instance].fbFriends[user.fbId])];
        }
    }];
}

+ (void)getProfilePictureForUser:(GOUser *)user {
    
    // Launch another thread to handle the download of the user's Facebook profile picture
    [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
        // Build a profile picture URL from the user's Facebook user id
        NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", user.fbId];
        NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
        UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
        
        // Set the profile picture into the user object
        if (profilePicture) {
            user.profilePicture = profilePicture;
        }
        // Notify that the profile picture has been downloaded, using NSNotificationCenter
        [[NSNotificationCenter defaultCenter] postNotificationName:N_ProfilePictureLoaded object:nil];
        
        
    }];
}

+ (void)uploadEvent:(GOEvent *)event forDelegate:(id<CommsDelegate>)delegate {
    NSLog(@"Uploading Event");
    
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        
        __block BOOL success;
        
        if (!error) {
            NSLog(@"got location for event");
            
            [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
            [[PFUser currentUser] saveInBackground];
            
            event[@"userLocation"] = geoPoint;
            event.going = @[[GOUser currentUser].fbId];
            event.invited = @[];
            event.comments = @[];
            
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    success = YES;
                    [[DataStore instance].allEventsMap setObject:event forKey:event.objectId];
                    
                    GOActivity *activity = [GOActivity object];
                    activity.goEvent = event;
                    activity.eventId = event.objectId;
                    activity.eventName = event.name;
                    activity.fromUserId = [[PFUser currentUser] objectForKey:@"fbId"];
                    activity.toUserIds = [[DataStore instance].fbFriends allKeys];
                    activity.type = @"going";
                    activity.content = [NSString stringWithFormat:@"%@ is going to %@", [[PFUser currentUser] objectForKey:@"fbUsername"], activity.eventName];
                    
                    [activity saveEventually];
                    
                } else {
                    success = NO;
                }
            }];
        }
        else {
            success = NO;
            NSLog(@"failed to get location for event");
        }
        //Callback
        if ([delegate respondsToSelector:@selector(commsUploadEventComplete:withId:)]) {
            [delegate commsUploadEventComplete:success withId:event.objectId];
        }
    }];
    
}

+ (void)updateEvent:(NSString *)eventId withEvent:(GOEvent *)event forDelegate:(id<CommsDelegate>)delegate {
    
    NSLog(@"Updating Event");
    
    PFQuery *eventQuery = [GOEvent query];
    [eventQuery whereKey:@"objectId" equalTo:eventId];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            GOEvent *fetchedEvent = [objects firstObject];
            fetchedEvent.name = event.name;
            fetchedEvent.details = event.details;
            fetchedEvent.startDate = event.startDate;
            fetchedEvent.endDate = event.endDate;
            fetchedEvent.location = event.location;
            fetchedEvent.privacyType = event.privacyType;
            
            
            [fetchedEvent saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    [[DataStore instance].allEventsMap setObject:fetchedEvent forKey:fetchedEvent.objectId];
                    
                    GOActivity *activity = [GOActivity object];
                    
                    activity.goEvent = fetchedEvent;
                    activity.eventId = fetchedEvent.objectId;
                    activity.eventName = fetchedEvent.name;
                    activity.fromUserId = [[PFUser currentUser] objectForKey:@"fbId"];
                    activity.toUserIds = fetchedEvent.going;
                    activity.type = @"updated";
                    activity.content = [NSString stringWithFormat:@"%@ updated the details of %@", [[PFUser currentUser] objectForKey:@"fbUsername"], fetchedEvent.name];
                    
                    
                    [activity saveEventually];
                        
                    if ([delegate respondsToSelector:@selector(commsUpdateEventComplete:)]) {
                        [delegate commsUpdateEventComplete:YES];
                    }

                    
                } else {
                    
                    if ([delegate respondsToSelector:@selector(commsUpdateEventComplete:)]) {
                        [delegate commsUpdateEventComplete:YES];
                    }
                }
            }];
        }
        else {
            NSLog(@"failed to get location for event");
            if ([delegate respondsToSelector:@selector(commsUploadEventComplete:withId:)]) {
                [delegate commsUploadEventComplete:NO withId:nil];
            }
        }
    }];
    
}

+ (void)deleteEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate{
    
    PFQuery *eventQuery = [GOEvent query];
    [eventQuery whereKey:@"objectId" equalTo:eventId];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            
            GOEvent *event = [objects firstObject];
            event.details = @"<CANCELED>";
            
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (!error) {
                    
                    [[DataStore instance].allEventsMap removeObjectForKey:event.objectId];
                    
                    GOActivity *activity = [GOActivity object];
                    
                    activity.goEvent = event;
                    activity.eventId = eventId;
                    activity.eventName = event.name;
                    activity.fromUserId = [[PFUser currentUser] objectForKey:@"fbId"];
                    activity.toUserIds = event.going;
                    activity.type = @"canceled";
                    activity.content = [NSString stringWithFormat:@"%@ canceled %@", [[PFUser currentUser] objectForKey:@"fbUsername"], event.name];
                    
                    [activity saveEventually];
                        
                    if ([delegate respondsToSelector:@selector(commsDeleteEventComplete:)]) {
                        [delegate commsDeleteEventComplete:YES];
                    }
                    
                }else {
                    if ([delegate respondsToSelector:@selector(commsDeleteEventComplete:)]) {
                        [delegate commsDeleteEventComplete:NO];
                    }
                }
            }];
        }else {
            if ([delegate respondsToSelector:@selector(commsDeleteEventComplete:)]) {
                [delegate commsDeleteEventComplete:NO];
            }
        }
    }];

}

+ (void)uploadEventComment:(NSString *)comment onEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate {
    
    GOActivity *activity = [GOActivity object];
    
    activity.eventId = eventId;
    activity.fromUserId = [[PFUser currentUser] objectForKey:@"fbId"];
    activity.type = @"comment";
    activity.content = comment;
    
    [activity saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            if ([delegate respondsToSelector:@selector(commsUploadEventCommentComplete:)]) {
                [delegate commsUploadEventCommentComplete:YES];
            }
        }else {
            if ([delegate respondsToSelector:@selector(commsUploadEventCommentComplete:)]) {
                [delegate commsUploadEventCommentComplete:NO];
            }
        }
    }];
}

+ (void)inviteUsers:(NSArray *)userIds toEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate{
    
    PFQuery *eventQuery = [GOEvent query];
    [eventQuery whereKey:@"objectId" equalTo:eventId];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        if (error) {
             NSLog(@"Objects error: %@", error.localizedDescription);
        }else {
            
            GOEvent *event = [objects firstObject];
            for (NSString *userId in userIds) {
                
                [event addUniqueObject:userId forKey:@"invited"];
            }
            
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                
                if (!error) {
                    
                    GOActivity *activity = [GOActivity object];
                    
                    activity.goEvent = event;
                    activity.eventId = event.objectId;
                    activity.eventName = event.name;
                    activity.fromUserId = [[PFUser currentUser] objectForKey:@"fbId"];
                    activity.toUserIds = userIds;
                    activity.type = @"invite";
                    activity.content = [NSString stringWithFormat:@"%@ wants you to go to %@", [[PFUser currentUser  ]objectForKey:@"fbUsername"], event.name];
                    
                    [activity saveEventually];
                        
                    if ([delegate respondsToSelector:@selector(commsDidSendInvite:)]) {
                        [delegate commsDidSendInvite:YES];
                    }
                    
                }else {
                    
                    if ([delegate respondsToSelector:@selector(commsDidSendInvite:)]) {
                        [delegate commsDidSendInvite:NO];
                    }
                }
             }];
            
        }
    }];
}

+ (void) addUserToEvent:(NSString *)eventId withUser:(NSDictionary *)secondUser forDelegate:(id<CommsDelegate>)delegate {
    //Query for event
    PFQuery *query = [GOEvent query];
    [query whereKey:@"objectId" equalTo:eventId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //Relate user to event
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
            
            if([delegate respondsToSelector:@selector(commsAddUserToEventComplete:)]) {
                [delegate commsAddUserToEventComplete:NO];
            }
            
        }else {
            GOEvent *event = [objects firstObject];
            
            NSString *userId = [[PFUser currentUser] objectForKey:@"fbId"];
            
            [event addUniqueObject:userId forKey:@"going"];
            
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    [[DataStore instance].allEventsMap setObject:event forKey:event.objectId];
                    [[DataStore instance] sortEventsByDate];
                    
                    PFQuery *activityQuery = [GOActivity query];
                    [activityQuery whereKey:@"type" equalTo:@"invite"];
                    [activityQuery whereKey:@"toUserIds" equalTo:userId];
                    
                    [activityQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                        
                        if (error) {
                            NSLog(@"Objects error: %@", error.localizedDescription);
                        }else {
                            
                            GOActivity *activity = [GOActivity object];
                            
                            activity.goEvent = event;
                            activity.eventId = event.objectId;
                            activity.eventName = event.name;
                            activity.fromUserId = userId;
                            activity.type = @"joined";
                            if ([event.privacyType isEqualToString:@"PrivacyTypeInviteOnly"]) {
                                activity.private = YES;
                            }else activity.private = NO;
                            
                            [objects enumerateObjectsUsingBlock:^(GOActivity *obj, NSUInteger idx, BOOL *stop) {
                                
                                [activity addObject:obj.fromUserId forKey:@"toUserIds"];
                                
                            }];
                            
                            [activity saveEventually];
                        }
                        
                    }];
                    
                    if ([delegate respondsToSelector:@selector(commsAddUserToEventComplete:)]) {
                        [delegate commsAddUserToEventComplete:YES];
                    }
                    
                }else {
                    if([delegate respondsToSelector:@selector(commsAddUserToEventComplete:)]) {
                        [delegate commsAddUserToEventComplete:NO];
                    }
                }
            }];
        }
    }];
}

+ (void)removeUserFromEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate {
    //Query for event
    PFQuery *eventQuery = [GOEvent query];
    [eventQuery whereKey:@"objectId" equalTo:eventId];
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        //Relate user to event
        
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        }else {
            GOEvent *event = [objects firstObject];
            
            [event removeObject:[[PFUser currentUser] objectForKey:@"fbId"] forKey:@"going"];
            
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    
                    [[DataStore instance].allEventsMap setObject:event forKey:event.objectId];
                    
                    [[DataStore instance] sortEventsByDate];
                    
                    if ([delegate respondsToSelector:@selector(commsRemoveUserFromEventComplete:)]) {
                        [delegate commsRemoveUserFromEventComplete:YES];
                    }
                }else {
                    if([delegate respondsToSelector:@selector(commsRemoveUserFromEventComplete:)]) {
                        [delegate commsRemoveUserFromEventComplete:NO];
                    }
                }
            }];
        }
        
       
    }];
}

+ (void)sendMessage:(GOMessage *)message forEvent:(NSString *)eventId forDelegate:(GOMessagesViewController *)delegate{
    
    [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!error) {
            
            if ([delegate respondsToSelector:@selector(commsSendMessageComplete:)]) {
                [delegate commsSendMessageComplete:YES];
            }
        }else {
            [delegate.messages addObject:message];
            
            if ([delegate respondsToSelector:@selector(commsSendMessageComplete:)]) {
                [delegate commsSendMessageComplete:NO];
            }
        }
    }];
}

#pragma mark - COM Fetch Methods


/*
 ===========================================================================
 
 Fetch Methods
 
 ===========================================================================
 */



+ (void) getEventsSinceLastUpdateForDelegate:(id<CommsDelegate>)delegate
{
    NSLog(@"Comms Getting Events");
    PFQuery *eventQuery = [GOEvent queryForEventsSinceLastUpdate];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        BOOL success;
        __block NSDate *newLastUpdate = [DataStore instance].lastEventUpdate;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            // Go through the returned PFObjects
            success = YES;
            [objects enumerateObjectsUsingBlock:^(GOEvent *event, NSUInteger idx, BOOL *stop) {
                
                NSLog(@"FOUND Event %@", event.name);
                
                // Check if friends are going or event is public
                if ([event friendsGoing].count > 0 || [event.privacyType isEqualToString: @"EventPrivacyTypePublic"]) {
                    NSLog(@"Found event %@", event.name);

                    // Update the last update timestamp with the most recent update
                    if ([event.updatedAt compare:newLastUpdate] == NSOrderedDescending) {
                        newLastUpdate = event.updatedAt;
                    }

                    // Store the GOEvent object in the DataStore collections
                    if ([event.description isEqualToString:@"<CANCELED>"]) {
                        [[DataStore instance].allEventsMap removeObjectForKey:event.objectId];
                    }else {
                        [[DataStore instance].allEventsMap setObject:event forKey:event.objectId];
                    }
                }
                
            }];
            
            [[DataStore instance] sortEventsByDate];
            [DataStore instance].lastEventUpdate = newLastUpdate;
        }
        
        // Callback
        if ([delegate respondsToSelector:@selector(commsDidGetNewEvents:)]) {
            [delegate commsDidGetNewEvents:success];
        }
    }];
}

+ (void) getEventsForUser:(NSString *)userId forDelegate:(id<CommsDelegate>)delegate {
    
    [[DataStore instance].userEvents removeAllObjects];
    PFQuery *eventQuery = [GOEvent queryForEventsForUser:userId];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            // Go through the returned PFObjects
            [objects enumerateObjectsUsingBlock:^(GOEvent *event, NSUInteger idx, BOOL *stop) {
                
                [[DataStore instance].allEventsMap setObject:event forKey:event.objectId];
                [[DataStore instance].userEvents addObject:event];
            }];
        }
        
        // Callback
        
    }];
}

+ (void) getWallUpdatesSinceLastUpdateForDelegate:(id<CommsDelegate>)delegate
{
    NSLog(@"Comms getting wall updates");
    PFQuery *updateQuery = [GOActivity queryForWallUpdatesSinceLastUpdate];
    
    [updateQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        // 3
        BOOL success = NO;
        __block NSDate *newLastUpdate = [DataStore instance].lastWallUpdate;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            success = YES;
            
            //Empty wallUpdates array if max updates are fetched
            if (objects.count == 30) {
                [[DataStore instance].wallUpdates removeAllObjects];
            }
            
            [objects enumerateObjectsUsingBlock:^(GOActivity *wallUpdate, NSUInteger idx, BOOL *stop) {
                
                // Update the last update timestamp with the most recent update
                if ([wallUpdate.updatedAt compare:newLastUpdate] == NSOrderedDescending) {
                    newLastUpdate = wallUpdate.updatedAt;
                }

                // Store the WallImage object in the DataStore collections
                [[DataStore instance].wallUpdates insertObject:wallUpdate atIndex:idx];
            }];
            
            [DataStore instance].lastWallUpdate = newLastUpdate;
        }
        
        // Callback
        if ([delegate respondsToSelector:@selector(commsDidGetNewWallUpdates:)]) {
            [delegate commsDidGetNewWallUpdates:success];
        }
    }];
}

+ (void) getPreviousWallUpdatesForDelegate:(id<CommsDelegate>)delegate
{
    NSLog(@"Comms getting wall updates");
    
    PFQuery *eventQuery = [GOActivity queryForPreviousWallUpdates];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        BOOL success;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            success = YES;
            [objects enumerateObjectsUsingBlock:^(GOActivity *wallUpdate, NSUInteger idx, BOOL *stop) {
                NSLog(@"Found previous update");
                
                [[DataStore instance].wallUpdates addObject:wallUpdate];
            }];
        }
        //Callback
        if ([delegate respondsToSelector:@selector(commsDidGetPreviousWallUpdates:)]) {
            [delegate commsDidGetPreviousWallUpdates:success];
        }
    }];
}

+ (void) getWallUpdatesForUser:(NSString *)userId forDelegate:(id<CommsDelegate>)delegate
{
    [[DataStore instance].userWallUpdates removeAllObjects];
    
    NSLog(@"Comms getting wall updates");

    PFQuery *updateQuery = [GOActivity queryForWallUpdatesForUser:userId];
    
    [updateQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        BOOL success;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            success = YES;
            [objects enumerateObjectsUsingBlock:^(GOActivity *wallUpdate, NSUInteger idx, BOOL *stop) {
                
                [[DataStore instance].userWallUpdates addObject:wallUpdate];
            }];
        }
        //Callback
        if ([delegate respondsToSelector:@selector(commsDidGetWallUpdatesForUser:)]) {
            [delegate commsDidGetWallUpdatesForUser:success];
        }
    }];
}

+ (void) getPreviousWallUpdatesForUser:(NSString *)userId forDelegate:(id<CommsDelegate>)delegate
{
    NSLog(@"Comms getting wall updates");

    // Create a PFQuery, Parse Query object
    PFQuery *eventQuery = [GOActivity queryForPreviousWallUpdatesForUser:userId];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        BOOL success;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        } else {
            success = YES;
            // Go through the returned PFObjects
            [objects enumerateObjectsUsingBlock:^(GOActivity *wallUpdate, NSUInteger idx, BOOL *stop) {
                
                NSLog(@"Found old update");
                
                [[DataStore instance].userWallUpdates addObject:wallUpdate];
            }];
        }
        // Callback
        if ([delegate respondsToSelector:@selector(commsDidGetPreviousWallUpdatesForUser:)]) {
            [delegate commsDidGetPreviousWallUpdatesForUser:success];
        }
    }];
}


+ (void) getNotificationsSinceLastUpdateForDelegate:(id<CommsDelegate>)delegate {
    
    PFQuery *notificationQuery = [GOActivity queryForNotificationsSinceLastUpdate];
    [notificationQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        BOOL success;
        __block NSDate *newLastUpdate = [DataStore instance].lastNotificationUpdate;
        __block BOOL newUser = NO;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        }else {
            success = YES;
            [objects enumerateObjectsUsingBlock:^(GOActivity *notification, NSUInteger idx, BOOL *stop) {
                
                NSLog(@"Found Notification %@", notification.type);
            
                if (objects.count == 30) {
                    [[DataStore instance].notifications removeAllObjects];
                }
                if ([notification.updatedAt compare:newLastUpdate] == NSOrderedDescending) {
                    newLastUpdate = notification.updatedAt;
                }
                
                [[DataStore instance].notifications insertObject:notification atIndex:idx];
                
                if ([notification.type isEqualToString:@"newUser"]) {
                    newUser = YES;
                }
                
            }];
            //If there is a new user get fb friends
            if (newUser == YES) {
                [Comms getFBFriends];
            }
            
            [DataStore instance].lastNotificationUpdate = newLastUpdate;
        }
        //Callback
        if ([delegate respondsToSelector:@selector(commsDidGetNewNotifications:)]) {
            [delegate commsDidGetNewNotifications:success];
        }
    }];
    
}

+ (void)getCommentsForEvent:(NSString *)eventId forDelegate:(id<CommsDelegate>)delegate {
    
    PFQuery *commentQuery = [GOActivity queryForCommentsForEvent:eventId];
    
    [commentQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        [[DataStore instance].eventComments removeAllObjects];
        BOOL success;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        }else {
            success = YES;
            [objects enumerateObjectsUsingBlock:^(GOActivity *comment, NSUInteger idx, BOOL *stop) {
                NSLog(@"Found Comment %@", comment);
                [[DataStore instance].eventComments addObject:comment];
            }];
        }
        //Callback
        if ([delegate respondsToSelector:@selector(commsDidGetNewEventComments:)]) {
            [delegate commsDidGetNewEventComments:success];
        }
    }];
}

+ (void)updateUserLocationForDelegate:(id<CommsDelegate>)delegate {
    [PFGeoPoint geoPointForCurrentLocationInBackground:^(PFGeoPoint *geoPoint, NSError *error) {
        BOOL success;
        if (!error) {
            success = YES;
            [[PFUser currentUser] setObject:geoPoint forKey:@"location"];
        }else {
            success = NO;
        }
        if ([delegate respondsToSelector:@selector(commsDidUpdateUserLocation:)]) {
            [delegate commsDidUpdateUserLocation:success];
        }
    }];
}



+ (void)getFBProfilesForIds:(NSArray *)fbIds forDelegate:(id<CommsDelegate>)delegate{
    
    NSMutableSet *fbIdSet = [NSMutableSet setWithArray:fbIds];
    NSSet *cachedIdSet = [NSSet setWithArray:[[DataStore instance].fbUsers allKeys]];
    [fbIdSet minusSet:cachedIdSet];
    
    if ([fbIdSet count] == 0) {
        
        if ([delegate respondsToSelector:@selector(commsDidGetFBProfiles:)]) {
            [delegate commsDidGetFBProfiles:YES];
        }
        return;
    }
    
    NSArray *uncachedIds = [fbIdSet allObjects];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery whereKey:@"fbId" containedIn:uncachedIds];
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        
        BOOL success;
        
        if (!error) {
            success = YES;
            [objects enumerateObjectsUsingBlock:^(PFUser *userObject, NSUInteger idx, BOOL *stop) {
                
                GOUser *user = [[GOUser alloc] initWithPFUser:userObject];
                [[DataStore instance].fbUsers setObject:user forKey:user.fbId];
                
                [[NSOperationQueue profilePictureOperationQueue] addOperationWithBlock:^ {
                    // Build a profile picture URL from the friend's Facebook user id
                    NSString *profilePictureURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture", user.fbId];
                    NSData *profilePictureData = [NSData dataWithContentsOfURL:[NSURL URLWithString:profilePictureURL]];
                    UIImage *profilePicture = [UIImage imageWithData:profilePictureData];
                    
                    // Set the profile picture into the user object
                    if (profilePicture) user.profilePicture = profilePicture;
                    
                    // Notify that the profile picture has been downloaded, using NSNotificationCenter
                    [[NSNotificationCenter defaultCenter] postNotificationName:N_ProfilePictureLoaded object:nil];
                }];
            }];
        }else {
            success = NO;
        }
        //Callback
        if ([delegate respondsToSelector:@selector(commsDidGetFBProfiles:)]) {
            [delegate commsDidGetFBProfiles:success];
        }
    }];
}

+ (void)getMessagesForEvent:(NSString *)eventId forDelegate:(GOMessagesViewController *)delegate{
    PFQuery *messageQuery = [GOMessage queryForMessagesForEvent:eventId];
    [messageQuery whereKey:@"createdAt" greaterThan:delegate.lastMessageUpdate];
    [messageQuery whereKey:@"senderId" notEqualTo:@"1063931693624048"];
    
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        BOOL success;
        __block NSDate *newLastUpdate = delegate.lastMessageUpdate;
        
        if (error) {
            success = NO;
            NSLog(@"Objects error: %@", error.localizedDescription);
        }else {
            success = YES;
            [objects enumerateObjectsUsingBlock:^(GOMessage *message, NSUInteger idx, BOOL *stop) {
                NSLog(@"Found Message %@", message);
                [delegate.messages addObject:message];
                
                if ([message.updatedAt compare:newLastUpdate] == NSOrderedDescending) {
                    newLastUpdate = message.updatedAt;
                }
            }];
        }
        delegate.lastMessageUpdate = newLastUpdate;
        
        //Callback
        if ([delegate respondsToSelector:@selector(commsDidGetNewMessages:)]) {
            [delegate commsDidGetNewMessages:success];
        }
    }];
}

/*
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
*/

@end

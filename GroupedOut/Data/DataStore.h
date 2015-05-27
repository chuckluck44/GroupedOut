//
//  DataStore.h
//  EventsApp
//
//  Created by Charley Luckhardt on 3/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import <FacebookSDK/FacebookSDK.h>
#import "JSQMessages.h"
//#import "Event.h"
#import "EventDateMap.h"

typedef NS_ENUM(NSInteger, WallUpdateType) {
    WallUpdateTypeCreate,
    WallUpdateTypeJoin
};


/*
 ====================== GOUser ===========================
 =========================================================
*/

@interface GOUser : NSObject

@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) UIImage *profilePicture;
@property (strong, nonatomic) NSString *fbId;

- (id)initWithPFUser:(PFUser *)user;
+ (GOUser *)currentUser;

@end

/*
 ====================== GOEvent ==========================
 =========================================================
*/

@interface GOEvent : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *details;
@property (nonatomic, strong) NSString *location;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSString *privacyType;
@property (nonatomic, strong) NSString *userId;
@property (nonatomic, strong) NSArray *comments;
@property (nonatomic, strong) NSArray *going;
@property (nonatomic, strong) NSArray *invited;

+ (PFQuery *)queryForEventsSinceLastUpdate;
+ (PFQuery *) queryForEventsForUser:(NSString *)userId;

- (NSArray *)friendsGoing;
- (NSArray *)usersGoing;

- (BOOL)currentUserGoing;
- (BOOL)currentUserInvited;

@end

/*
==================== GOAvtivity =========================
=========================================================
*/

@interface GOActivity: PFObject<PFSubclassing>

@property (retain) PFObject *goEvent;
@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSString *eventName;
@property (nonatomic, strong) NSString *fromUserId;
@property (nonatomic, strong) NSArray *toUserIds;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, assign) BOOL private;

+ (PFQuery *)queryForWallUpdatesSinceLastUpdate;
+ (PFQuery *)queryForPreviousWallUpdates;
+ (PFQuery *)queryForWallUpdatesForUser:(NSString *)userId;
+ (PFQuery *)queryForPreviousWallUpdatesForUser:(NSString *)userId;

+ (PFQuery *)queryForNotificationsSinceLastUpdate;

+ (PFQuery *)queryForCommentsForEvent:(NSString *)eventId;

@end

/*
==================== GOMessage =========================
=========================================================
*/

@interface GOMessage: PFObject<PFSubclassing, JSQMessageData>

@property (nonatomic, strong) NSString *eventId;
@property (nonatomic, strong) NSString *senderId;
@property (nonatomic, strong) NSString *senderDisplayName;
@property (nonatomic, strong) NSString *text;
@property (nonatomic) BOOL isMediaMessage;
@property (nonatomic, strong) NSDate *date;

- (NSString *)senderId;
- (NSString *)senderDisplayName;
//- (NSDate *)date;
- (BOOL)isMediaMessage;
- (NSUInteger)messageHash;
- (NSString *)text;
+ (PFQuery *)queryForMessagesForEvent:(NSString *)eventId;

@end

/*
 ===================== DataStore =========================
 =========================================================
*/

@interface DataStore : NSObject

@property (nonatomic, strong) NSMutableDictionary *fbFriends;
@property (nonatomic, strong) NSMutableDictionary *fbUsers;

@property (nonatomic, strong) NSMutableArray *wallUpdates;
@property (nonatomic, strong) NSMutableArray *notifications;

@property (nonatomic, strong) NSMutableArray *userEvents;
@property (nonatomic, strong) NSMutableArray *userWallUpdates;

@property (nonatomic, strong) NSMutableDictionary *allEventsMap;

@property (nonatomic, strong) EventDateMap *friendEventDateMap;
@property (nonatomic, strong) EventDateMap *publicEventDateMap;
@property (nonatomic, strong) EventDateMap *invitedEventDateMap;

@property (nonatomic, strong) NSMutableArray *eventComments;

@property (nonatomic, strong) NSDate *lastEventUpdate;
@property (nonatomic, strong) NSDate *lastWallUpdate;
@property (nonatomic, strong) NSDate *lastNotificationUpdate;

- (void)sortEventsByDate;

//+ (NSMutableArray *)eventsForUserId:(NSString *)fbId;
//+ (NSMutableArray *)wallUpdatesForUserId:(NSString *)fbId;

- (GOUser *)userForId:(NSString *)fbId;
- (GOEvent *)eventForId:(NSString *)eventId;

+ (DataStore *) instance;
- (void) reset;

@end
//
//  DataStore.m
//  EventsApp
//
//  Created by Charley Luckhardt on 3/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "DataStore.h"
#import <Parse/Parse.h>
#import "GODateFormatter.h"
//#import "Event.h"

/*
 ====================== GOUser ===========================
 =========================================================
*/

@implementation GOUser

- (id)initWithPFUser:(PFUser *)user {
    self = [super init];
    if (self) {
        _name = user[@"fbUsername"];
        _fbId = user[@"fbId"];
    }
    
    return self;
}

+ (GOUser *)currentUser {
    return [[DataStore instance].fbFriends objectForKey:[[PFUser currentUser] objectForKey:@"fbId"]];
}

@end

/*
 ====================== GOEvent ==========================
 =========================================================
 */

@implementation GOEvent

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"GOEvent";
}

@dynamic name, details, location, startDate, endDate, privacyType, userId, going, invited, comments;


+ (PFQuery *) queryForEventsSinceLastUpdate {
    
    PFQuery *eventQuery = [GOEvent query];
    
    PFGeoPoint *userGeoPoint = [[PFUser currentUser] objectForKey:@"location"];
    [eventQuery whereKey:@"userLocation" nearGeoPoint:userGeoPoint withinMiles:20];
    [eventQuery orderByAscending:@"createdAt"];
    [eventQuery whereKey:@"updatedAt" greaterThan:[DataStore instance].lastEventUpdate];
    
    return eventQuery;
    
}

+ (PFQuery *) queryForEventsForUser:(NSString *)userId {
    
    PFQuery *nonPrivateQuery = [GOEvent query];
    [nonPrivateQuery whereKey:@"privacyType" notEqualTo:@"PrivacyTypeInviteOnly"];
    
    PFQuery *privateQuery = [GOEvent query];
    [privateQuery whereKey:@"going" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];
    
    PFQuery *eventQuery = [PFQuery orQueryWithSubqueries:@[nonPrivateQuery, privateQuery]];
    
    [eventQuery whereKey:@"going" equalTo:userId];
    [eventQuery whereKey:@"details" notEqualTo:@"<CANCELED>"];
    [eventQuery orderByDescending:@"startDate"];
    
    eventQuery.limit = 30;
    eventQuery.cachePolicy = kPFCachePolicyCacheElseNetwork;
    eventQuery.maxCacheAge = 60 * 5;
    
    return eventQuery;
    
}

- (NSArray *)friendsGoing {
    NSMutableSet *friendSet = [NSMutableSet setWithArray:self.going];
    [friendSet intersectSet:[NSSet setWithArray:[[DataStore instance].fbUsers allKeys]]];
    
    return [friendSet allObjects];
}

- (NSArray *)usersGoing {
    NSMutableSet *friendSet = [NSMutableSet setWithArray:self.going];
    [friendSet intersectSet:[NSSet setWithArray:[[DataStore instance].fbUsers allKeys]]];
    NSMutableSet *otherUserSet = [NSMutableSet setWithArray:self.going];
    [otherUserSet minusSet:friendSet];
    
    return [otherUserSet allObjects];
}

- (BOOL)currentUserGoing {
    
    if ([self.going containsObject:[[PFUser currentUser] objectForKey:@"fbId"]]) {
        return YES;
    }else return NO;
    
}

- (BOOL)currentUserInvited {
    
    if ([self.invited containsObject:[[PFUser currentUser] objectForKey:@"fbId"]]) {
        return YES;
    }else return NO;
    
}

@end

/*
 ==================== GOAvtivity =========================
 =========================================================
 */


@implementation GOActivity

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"GOActivity";
}

@dynamic goEvent, eventId, eventName, fromUserId, toUserIds, type, content, private;


+ (PFQuery *)queryForWallUpdatesSinceLastUpdate {
    
    PFQuery *query = [GOActivity query];
    
    [query whereKey:@"fromUserId" equalTo:[[DataStore instance].fbFriends allKeys]];
    
    [query whereKey:@"type" notEqualTo:@"invite"];
    [query whereKey:@"type" notEqualTo:@"newUser"];
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"updatedAt" greaterThan:[DataStore instance].lastWallUpdate];
    
    query.limit = 30;
    
    return query;
}

+ (PFQuery *)queryForPreviousWallUpdates {
    
    PFQuery *query = [GOActivity query];
    [query orderByDescending:@"createdAt"];
    
    GOActivity *firstUpdate = [[DataStore instance].wallUpdates lastObject];
    [query whereKey:@"createdAt" lessThan:firstUpdate];
    [query whereKey:@"fromUserId" equalTo:[[DataStore instance].fbFriends allKeys]];
    
    [query whereKey:@"type" notEqualTo:@"invite"];
    [query whereKey:@"type" notEqualTo:@"newUser"];
    
    query.limit = 30;
    
    return query;
}

+ (PFQuery *)queryForWallUpdatesForUser:(NSString *)userId {
    
    PFQuery *query = [GOActivity query];
    
    [query whereKey:@"fromUserId" equalTo:userId];
    
    [query whereKey:@"type" notEqualTo:@"invite"];
    [query whereKey:@"type" notEqualTo:@"newUser"];
    [query orderByDescending:@"createdAt"];
    
    query.limit = 30;
    query.cachePolicy = kPFCachePolicyCacheElseNetwork;
    query.maxCacheAge = 600;
    
    return query;
}

+ (PFQuery *)queryForPreviousWallUpdatesForUser:(NSString *)userId {
    
    PFQuery *query = [GOActivity query];
    [query orderByDescending:@"createdAt"];
    
    GOActivity *firstUpdate = [[DataStore instance].userWallUpdates lastObject];
    [query whereKey:@"createdAt" lessThan:firstUpdate];
    [query whereKey:@"fromUserId" equalTo:userId];
    
    [query whereKey:@"type" notEqualTo:@"invite"];
    [query whereKey:@"type" notEqualTo:@"newUser"];
    
    query.limit = 30;
    
    return query;
}

+ (PFQuery *)queryForNotificationsSinceLastUpdate {
    PFQuery *notificationQuery = [GOActivity query];
    [notificationQuery whereKey:@"toUserIds" equalTo:[[PFUser currentUser] objectForKey:@"fbId"]];
    [notificationQuery orderByDescending:@"createdAt"];
    [notificationQuery whereKey:@"updatedAt" greaterThan:[DataStore instance].lastNotificationUpdate];
    
    notificationQuery.limit = 30;
    
    return notificationQuery;
}

+ (PFQuery *)queryForCommentsForEvent:(NSString *)eventId {
    PFQuery *commentQuery = [GOActivity query];
    [commentQuery whereKey:@"eventId" equalTo:eventId];
    [commentQuery whereKey:@"type" equalTo:@"comment"];
    [commentQuery orderByDescending:@"createdAt"];
    
    commentQuery.limit = 30;
    commentQuery.cachePolicy =kPFCachePolicyCacheThenNetwork;
    
    return commentQuery;
}

@end

/*
 ==================== GOMessage =========================
 =========================================================
 */

@implementation GOMessage

+ (void)load {
    [self registerSubclass];
}

+ (NSString *)parseClassName {
    return @"GOActivity";
}

@dynamic eventId, senderId, senderDisplayName, text, isMediaMessage, date;

/*
- (NSString *)senderId {
    return self.senderId;
}

- (NSString *)senderDisplayName {
    return self.senderDisplayName;
}
*/

/*
- (NSDate *)date {
    return self.createdAt;
}
*/
 
/*
- (BOOL)isMediaMessage {
    return self.isMediaMessage;
}
*/
 
- (NSUInteger)messageHash {
    
    return self.hash;
}

- (NSUInteger)hash
{
    NSUInteger contentHash = self.isMediaMessage ? [self.media mediaHash] : self.text.hash;
    return self.senderId.hash ^ self.date.hash ^ contentHash;
}

/*
- (NSString *)text {
    return self.text;
}
*/
+ (PFQuery *)queryForMessagesForEvent:(NSString *)eventId {
    PFQuery *query = [GOMessage query];
    
    [query whereKey:@"eventId" equalTo:eventId];
    [query orderByDescending:@"createdAt"];
    
    query.limit = 30;
    
    return query;
}

@end

/*
 ===================== DataStore =========================
 =========================================================
 */

@implementation DataStore

static DataStore *instance = nil;

+ (DataStore *) instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[DataStore alloc] init];
        }
    }
    return instance;
}

- (id) init
{
    self = [super init];
    if (self) {
        _fbFriends = [[NSMutableDictionary alloc] init];
        _fbUsers = [[NSMutableDictionary alloc] init];
        
        _wallUpdates = [[NSMutableArray alloc] init];
        _userWallUpdates = [[NSMutableArray alloc] init];
        
        _allEventsMap = [[NSMutableDictionary alloc] init];
        _userEvents = [[NSMutableArray alloc] init];
        
        _friendEventDateMap = [[EventDateMap alloc] init];
        _publicEventDateMap = [[EventDateMap alloc] init];
        _invitedEventDateMap = [[EventDateMap alloc] init];

        _eventComments = [[NSMutableArray alloc] init];
        
        _notifications = [[NSMutableArray alloc] init];
        
        _lastEventUpdate = [NSDate distantPast];
        _lastWallUpdate = [NSDate distantPast];
        _lastNotificationUpdate = [NSDate distantPast];
        
    }
    return self;
}

- (void) reset
{
    [_fbFriends removeAllObjects];
    [_fbUsers removeAllObjects];
    
    [_wallUpdates removeAllObjects];
    
    [_allEventsMap removeAllObjects];
    [_userEvents removeAllObjects];
    
    [_friendEventDateMap removeAllObjects];
    [_publicEventDateMap removeAllObjects];
    [_invitedEventDateMap removeAllObjects];
    
    [_eventComments removeAllObjects];

    [_notifications removeAllObjects];
    
    _lastEventUpdate = [NSDate distantPast];
    _lastWallUpdate = [NSDate distantPast];
    _lastNotificationUpdate = [NSDate distantPast];
}

- (void)sortMostPopularEvents:(NSMutableArray *)events {
    NSLog(@"COMMS sorting most popular Events");

    [events sortUsingComparator:^NSComparisonResult(GOEvent *obj1, GOEvent *obj2) {
        //Get friends attending events
        
        if ([obj1 friendsGoing].count > [obj2 friendsGoing].count) {
            return NSOrderedAscending;
        }else if ([obj1 friendsGoing].count < [obj2 friendsGoing].count) {
            return NSOrderedDescending;
        }else return NSOrderedSame;
    }];
}

- (void)sortEventsByDate {
    
    [self.friendEventDateMap removeAllObjects];
    [self.publicEventDateMap removeAllObjects];
    [self.invitedEventDateMap removeAllObjects];
    
    NSMutableArray *popularEvents = [NSMutableArray arrayWithArray:[self.allEventsMap allValues]];
    [self sortMostPopularEvents:popularEvents];
    
    [popularEvents enumerateObjectsUsingBlock:^(GOEvent *event, NSUInteger idx, BOOL *stop) {
        /*
        //Remove old events
        if (!eventObj.event.eventEndDate && ([eventObj.event.eventStartDate timeIntervalSinceNow] < 14400)) {
            
            [[self instance].allEventsMap removeObjectForKey:eventObj.objectId];
            
        }else if ([eventObj.event.eventEndDate timeIntervalSinceNow] < 0) {
            
            [[self instance].allEventsMap removeObjectForKey:eventObj.objectId];
        }
        */
         
        EventDateMap *eventDateMap;
        
        NSInteger days = [GODateFormatter daysFromNowToDate:event.startDate];
        
        if ([event.privacyType isEqualToString:@"PrivacyTypeOpenInvite"]) {
            eventDateMap = self.friendEventDateMap;
        }else if ([event.privacyType isEqualToString:@"PrivacyTypePublic"]) {
            eventDateMap = self.publicEventDateMap;
        }
        if ([event currentUserInvited]) {
            eventDateMap = self.invitedEventDateMap;
        }
        if ([event currentUserGoing]) {
            if (days == 0) {
                [eventDateMap.today addObject:event];
            }else if (days < 7) {
                [eventDateMap.week addObject:event];
            }else if (days < 30) {
                [eventDateMap.month addObject:event];
            }else if (days > 0) {
                [eventDateMap.future addObject:event];
            }else {
                [eventDateMap.passed addObject:event];
            }
        }
     
        
    }];
}

- (GOUser *)userForId:(NSString *)fbId {
    if ([self.fbFriends objectForKey:fbId]) {
        return [self.fbFriends objectForKey:fbId];
    }else if ([self.fbUsers objectForKey:fbId]){
        return [self.fbFriends objectForKey:fbId];
    }else {
        return nil;
    }
    
}

- (GOEvent *)eventForId:(NSString *)eventId {
    return [self.allEventsMap objectForKey:eventId];
}

/*
+ (NSMutableArray *)eventsForUserId:(NSString *)fbId {
    
    NSMutableArray *array = [NSMutableArray array];
    
    [[[self instance].allEventsMap allValues] enumerateObjectsUsingBlock:^(OGOEvent *eventObj, NSUInteger idx, BOOL *stop) {
        if ([eventObj.guests objectForKey:fbId] != nil ) {
            [array addObject:eventObj];
            //&& [eventObj.event.eventStartDate compare:[NSDate date]] == NSOrderedDescending
        }
    }];
    return array;
}

+ (NSMutableArray *)wallUpdatesForUserId:(NSString *)fbId {
    
    NSMutableArray *array = [NSMutableArray array];
    
    [[self instance].wallUpdates enumerateObjectsUsingBlock:^(WallUpdate *wallUpdateObj, NSUInteger idx, BOOL *stop) {
        NSDictionary<FBGraphUser> *user = wallUpdateObj.user;
        if ([user.objectID isEqualToString:fbId]) {
            [array addObject:wallUpdateObj];
        }
    }];
    return array;
}
*/

@end

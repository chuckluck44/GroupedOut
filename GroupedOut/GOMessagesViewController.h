//
//  GOMessagesViewController.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 5/10/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "JSQMessagesViewController.h"
#import "DataStore.h"

@interface GOMessagesViewController : JSQMessagesViewController

@property (nonatomic, strong) GOEvent *event;
@property (nonatomic, strong) NSMutableArray *messages;
@property (nonatomic, strong) NSDate *lastMessageUpdate;

- (void)commsSendMessageComplete:(BOOL)success;
- (void)commsDidGetNewMessages:(BOOL)success;

@end

//
//  GOCustomSegues.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 4/1/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "InviteTableViewController.h"
#import "EventDetailTableViewController.h"
#import "UserProfileTableViewController.h"
#import "NewEventTableViewController.h"
#import "GuestDetailsTableViewController.h"

@interface InviteSegue : UIStoryboardSegue

- (void)perform;

@end

@interface AddEventSegue : UIStoryboardSegue

- (void)perform;

@end

@interface EventDetailSegue : UIStoryboardSegue

- (void)perform;

@end

@interface GuestDetailSegue : UIStoryboardSegue

- (void)perform;

@end

@interface UserProfileSegue : UIStoryboardSegue

- (void)perform;

@end



@protocol GOCustomSeguesDelegate <NSObject>

@end

@interface GOCustomSegues : NSObject

@property (nonatomic, strong) UINavigationController *navController;
@property (nonatomic, strong) InviteTableViewController *inviteViewController;
@property (nonatomic, strong) InviteSegue *inviteSegue;

@property (nonatomic, strong) UINavigationController *addEventNavController;
@property (nonatomic, strong) NewEventTableViewController *addEventViewController;
@property (nonatomic, strong) AddEventSegue *addEventSegue;

@property (nonatomic, strong) EventDetailTableViewController *eventDetailViewController;
@property (nonatomic, strong) EventDetailSegue *eventDetailSegue;

@property (nonatomic, strong) GuestDetailsTableViewController *guestDetailViewController;
@property (nonatomic, strong) GuestDetailSegue *guestDetailSegue;

@property (nonatomic, strong) UserProfileTableViewController *userProfileViewController;
@property (nonatomic, strong) UserProfileSegue *userProfileSegue;

@property (nonatomic, weak) UIViewController *parentController;


- (id)initWithViewController:(UIViewController *)viewController;


@end

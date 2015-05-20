//
//  GOCustomSegues.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 4/1/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "GOCustomSegues.h"
#import "EventTableViewController.h"


@implementation InviteSegue

- (void)perform
{
    // our custom segue is being fired, push the map view controller
    UIViewController *sourceViewController = self.sourceViewController;
    UINavigationController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController presentViewController:destinationViewController animated:YES completion:nil];
}

@end

@implementation AddEventSegue

- (void)perform
{
    // our custom segue is being fired, push the map view controller
    UIViewController *sourceViewController = self.sourceViewController;
    UINavigationController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController presentViewController:destinationViewController animated:YES completion:nil];
}

@end

@implementation EventDetailSegue

- (void)perform
{
    // our custom segue is being fired, push the map view controller
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}



@end

@implementation GuestDetailSegue

- (void)perform
{
    // our custom segue is being fired, push the map view controller
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}



@end

@implementation UserProfileSegue

- (void)perform
{
    // our custom segue is being fired, push the map view controller
    UIViewController *sourceViewController = self.sourceViewController;
    UIViewController *destinationViewController = self.destinationViewController;
    [sourceViewController.navigationController pushViewController:destinationViewController animated:YES];
}

@end


@interface GOCustomSegues ()

@end


@implementation GOCustomSegues

- (id) init
{
    self = [super init];
    if (self) {
        
    }
    return self;
}

- (id)initWithViewController:(UIViewController *)viewController {
    self = [super init];
    if (self) {
        
        _parentController = viewController;
        
        _navController = [[viewController storyboard] instantiateInitialViewController];
        _inviteViewController = [[viewController storyboard] instantiateViewControllerWithIdentifier:@"InviteTableViewController"];
        [_navController setViewControllers:[NSArray arrayWithObject:_inviteViewController]];
        _inviteSegue = [[InviteSegue alloc] initWithIdentifier:@"InviteSegue" source:_parentController destination:_navController];
        
        _addEventNavController = [[viewController storyboard] instantiateViewControllerWithIdentifier:@"AddEventNavController"];
        _addEventViewController = [[viewController storyboard] instantiateViewControllerWithIdentifier:@"AddEventTableViewController"];
        [_addEventNavController setViewControllers:[NSArray arrayWithObject:_addEventViewController]];
        _addEventSegue = [[AddEventSegue alloc] initWithIdentifier:@"AddEventSegue" source:_parentController destination:_addEventNavController];
        
        _eventDetailViewController = [[viewController storyboard] instantiateViewControllerWithIdentifier:@"EventDetailTableViewController"];
        _eventDetailSegue = [[EventDetailSegue alloc] initWithIdentifier:@"EventDetailSegue" source:_parentController destination:_eventDetailViewController];
        
        _guestDetailViewController = [[viewController storyboard] instantiateViewControllerWithIdentifier:@"GuestDetailTableViewController"];
        _guestDetailSegue = [[GuestDetailSegue alloc] initWithIdentifier:@"GuestDetailSegue" source:_parentController destination:_guestDetailViewController];
        
        _userProfileViewController = [[viewController storyboard] instantiateViewControllerWithIdentifier:@"UserProfileTableViewController"];
        _userProfileSegue = [[UserProfileSegue alloc] initWithIdentifier:@"UserProfileSegue" source:_parentController destination:_userProfileViewController];
        
    }
    return self;
}

@end

//
//  InviteTableViewController.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/30/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol InviteTableViewControllerDelegate <NSObject>

- (void)dismissViewController;

@end

@interface InviteTableViewController : UITableViewController

@property (strong, nonatomic) NSString *eventId;
@property (weak) id<InviteTableViewControllerDelegate> delegate;

@end

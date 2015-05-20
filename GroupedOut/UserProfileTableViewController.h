//
//  UserProfileTableViewController.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 4/5/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UserProfileTableViewControllerDelegate <NSObject>

- (void)dismissUserProfileViewController;

@end

@interface UserProfileTableHeaderCell : UITableViewCell
@end

@interface UserProfileTableWallUpdateCell : UITableViewCell
@end

@interface UserProfileTableEventCell : UITableViewCell

@end

@interface UserProfileTableViewController : UITableViewController

@property (strong, nonatomic) NSString *fbId;
@property (weak) id<UserProfileTableViewControllerDelegate> delegate;

@end

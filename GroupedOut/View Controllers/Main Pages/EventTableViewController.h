//
//  EventTableViewController.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/20/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ProfilePictureCollectionViewCellDelegate <NSObject>

- (void)selectedUserWithId:(NSString *)fbId;

@end

@interface EventTableTitleCell : UITableViewCell

@property (strong, nonatomic) NSMutableArray *users;
@property (weak, nonatomic) id<ProfilePictureCollectionViewCellDelegate> delegate;

@end

@interface EventTableProfilePictureCollectionCell : UITableViewCell

@property (strong, nonatomic) NSMutableArray *users;
@property (weak, nonatomic) id<ProfilePictureCollectionViewCellDelegate> delegate;

@end

@interface EventTableCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;


@end

@interface EventTableGoingCell : UITableViewCell

@end


@interface EventTableViewController : UITableViewController

@end

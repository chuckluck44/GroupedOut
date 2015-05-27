//
//  EventDetailTableViewController.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 4/1/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataStore.h"

@protocol EventDetailTableViewControllerDelegate <NSObject>

- (void)dismissEventDetailViewController;

@end

@interface EventDetailTableEventCell : UITableViewCell

@end

@interface EventDetailTableAddCommentCell : UITableViewCell

@end

@interface EventDetailTableCommentCell : UITableViewCell

@end


@interface EventDetailTableViewController : UITableViewController

@property (nonatomic, strong) GOEvent *goEvent;

@property (weak) id<EventDetailTableViewControllerDelegate> delegate;

@end

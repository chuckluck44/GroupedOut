//
//  NewEventTableViewController.h
//  EventsApp
//
//  Created by Charley Luckhardt on 3/2/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"
#import "DataStore.h"

@protocol NewEventViewControllerDelegate <NSObject>

- (void)dismissNewEventViewController;

@end

@interface NewEventTableViewController : UITableViewController

@property GOEvent *userEvent;
@property (weak) id<NewEventViewControllerDelegate> delegate;

- (IBAction)unwindToNewEvent:(UIStoryboardSegue *)segue;

@end

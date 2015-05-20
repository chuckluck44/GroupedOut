//
//  LocationTableViewController.h
//  EventsApp
//
//  Created by Charley Luckhardt on 3/4/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface LocationTableViewController : UITableViewController <CLLocationManagerDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *places;

@end

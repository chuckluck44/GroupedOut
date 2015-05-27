//
//  NotificationTableViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/31/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "NotificationTableViewController.h"
#import "DataStore.h"
#import "Comms.h"
#import "GOCustomSegues.h"
#import "GODateFormatter.h"


@interface NotificationTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *notificationLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel;


@end

@implementation NotificationTableViewCell

@end


@interface NotificationTableViewController () <CommsDelegate, EventDetailTableViewControllerDelegate>

@property (strong, nonatomic) GOCustomSegues *sharedControllers;

@end

@implementation NotificationTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sharedControllers = [[GOCustomSegues alloc] initWithViewController:self];
    self.sharedControllers.eventDetailViewController.delegate = self;
    
    // If we are using iOS 6+, put a pull to refresh control in the table
    if (NSClassFromString(@"UIRefreshControl") != Nil) {
        UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
        refreshControl.attributedTitle = [[NSAttributedString alloc] initWithString:@"Pull to Refresh"];
        [refreshControl addTarget:self action:@selector(refreshImageWall:) forControlEvents:UIControlEventValueChanged];
        self.refreshControl = refreshControl;
    }
    
    [self refreshImageWall:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) refreshImageWall:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing data..."]];
        [refreshControl setEnabled:NO];
    }
    
    [Comms getNotificationsSinceLastUpdateForDelegate:self];
}

- (void)commsDidGetNewNotifications:(BOOL)success {
    
    if (self.refreshControl) {
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [GODateFormatter formattedDateForDatePicker:[NSDate date]]];
        [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
        [self.refreshControl endRefreshing];
    }
    
    [self.tableView reloadData];
}

- (void)dismissEventDetailViewController {
    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    // Return the number of rows in the section.
    NSLog(@"Notification count: %dl", [[DataStore instance].notifications count]);
    
    return [[DataStore instance].notifications count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NotificationCell" forIndexPath:indexPath];
    
    // Configure the cell...
    GOActivity *notification = ([DataStore instance].notifications[indexPath.row]);
    
    GOUser *user = ([DataStore instance].fbFriends[notification.fromUserId]);
    
    //NSString *notString;
    
    /*
    if ([notification.type isEqualToString:@"invited"]) {
        NSString *senderName = user.name;
        notString = [NSString stringWithFormat:@"%@ wants you to go to %@", senderName, notification.eventName];
        
    }else if ([notification.type isEqualToString:@"joined"]) {
        NSString *senderName = user.name;
        notString = [NSString stringWithFormat:@"%@ is going to %@ with you", senderName, notification.eventName];
        
    }else if ([notification.type isEqualToString:@"updated"]) {
        NSString *senderName = user.name;
        notString = [NSString stringWithFormat:@"%@ updated the details of %@", senderName, notification.eventName];
        
    }else if ([notification.type isEqualToString:@"canceled"]) {
        NSString *senderName = user.name;
        notString = [NSString stringWithFormat:@"%@ canceled %@", senderName, notification.eventName];
    }else if ([notification.type isEqualToString:@"newUser"]) {
        NSString *senderName = user.name;
        notString = [NSString stringWithFormat:@"%@ joined GroupedOut", senderName];
    }
     */
    
    
    cell.notificationLabel.text = notification.content;
    cell.postTimeLabel.text = [GODateFormatter formattedDate:notification.createdAt];
    [cell.profilePicture setImage:user.profilePicture];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 65;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    GOActivity *notification = ([DataStore instance].notifications[indexPath.row]);
    
    self.sharedControllers.eventDetailViewController.goEvent = ([DataStore instance].allEventsMap[notification.eventId]);
    
    [self.sharedControllers.eventDetailSegue perform];
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

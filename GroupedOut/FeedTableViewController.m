//
//  FeedTableViewController.m
//  EventsApp
//
//  Created by Charley Luckhardt on 3/2/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "FeedTableViewController.h"
#import <Parse/Parse.h>

#import "Comms.h"
#import "DataStore.h"

#import "NewEventTableViewController.h"

#import "GODateFormatter.h"
#import "GOCustomSegues.h"

@interface EventWallTableUserCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userAction;
@property (weak, nonatomic) IBOutlet UILabel *postTime;
@end

@implementation EventWallTableUserCell
@end

@interface EventWallTableEventCell ()

@property (weak, nonatomic) IBOutlet UILabel *eventName;
@property (weak, nonatomic) IBOutlet UILabel *eventDate;

@end

@implementation EventWallTableEventCell

@end

@interface FeedTableViewController () <CommsDelegate, NewEventViewControllerDelegate, EventDetailTableViewControllerDelegate> {
    
    GOCustomSegues *sharedControllers;
}

@property (strong, nonatomic) UIActivityIndicatorView *indicator;
@property BOOL refreshingPrevious;

@end

@implementation FeedTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Initialize the last updated dates
    
    sharedControllers = [[GOCustomSegues alloc] initWithViewController:self];
    sharedControllers.addEventViewController.delegate = self;
    sharedControllers.eventDetailViewController.delegate = self;
    
    self.refreshingPrevious = NO;
    
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
    // Listen for profile picture downloads so that we can refresh the image wall
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloaded:)
                                                 name:N_ProfilePictureLoaded
                                               object:nil];
    
}

- (IBAction)handleLogOut:(id)sender {
    [PFUser logOut];
}
    
- (void) imageDownloaded:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)commsDidUpdateUserLocation:(BOOL)success {
    if (success) {
        NSLog(@"Updated user Location");
        [Comms getEventsSinceLastUpdateForDelegate:self];
    }else {
        NSLog(@"Failed to Update Location");
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not update feed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
        
        if (self.refreshControl) {
            NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [GODateFormatter formattedDateForDatePicker:[NSDate date]]];
            [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
            [self.refreshControl endRefreshing];
        }
    }
    
}

- (void) commsDidGetNewEvents:(BOOL)success {
    
    [Comms getWallUpdatesSinceLastUpdateForDelegate:self];
    
}

- (void) commsDidGetNewWallUpdates:(BOOL)success {
    NSLog(@"Fetched Wall Updates");
    
    if (self.refreshControl) {
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [GODateFormatter formattedDateForDatePicker:[NSDate date]]];
        [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
        [self.refreshControl endRefreshing];
    }
    
    // Refresh the table data to show the new images
    [self.tableView reloadData];
}

- (void)commsDidGetPreviousWallUpdates:(BOOL)success {
    
    NSLog(@"Comms got previous updates %ld", (unsigned long)[DataStore instance].wallUpdates.count);
    
    [self.indicator stopAnimating];
    
    if (success) {
        [self.tableView reloadData];
        
        self.refreshingPrevious = NO;
        
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not update feed" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    
    // Refresh the table data to show the new images
}

- (IBAction)handleAddEventPress:(id)sender {
    
    [sharedControllers.addEventSegue perform];
    
}

- (void) refreshImageWall:(UIRefreshControl *)refreshControl
{
    if (refreshControl) {
        [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:@"Refreshing data..."]];
        [refreshControl setEnabled:NO];
    }
    
    // Get any new Wall Images since the last update
    [Comms updateUserLocationForDelegate:self];
}

#pragma mark - Event Details Delegate

- (void)dismissEventDetailViewController {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Add Event Delegate

- (void)dismissNewEventViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    [Comms getEventsSinceLastUpdateForDelegate:self];
}

#pragma mark - Table view data source

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView {
    // One section per WallImage
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if ([DataStore instance].wallUpdates.count > 0) {
        return ([DataStore instance].wallUpdates.count + 1);
    }else return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if (indexPath.row == [DataStore instance].wallUpdates.count) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RefreshCell"];
        
        self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell addSubview:self.indicator];
        
        self.indicator.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
        
        return cell;
        
    }
    
    static NSString *UserCellIdentifier = @"UserCell";
    EventWallTableUserCell *userCell = (EventWallTableUserCell *)[tableView dequeueReusableCellWithIdentifier:UserCellIdentifier];
    
    GOActivity *wallUpdate = ([DataStore instance].wallUpdates[indexPath.row]);
    GOUser *user = [[DataStore instance] userForId:wallUpdate.fromUserId];
    
    [userCell.userAction setText:wallUpdate.content];
    
    userCell.userAction.numberOfLines = 0;
    userCell.userAction.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *postTime = [GODateFormatter formattedDate:wallUpdate.createdAt];
    [userCell.postTime setText:postTime];
    
    // Add the user's profile picture to the header cell
    [userCell.profilePicture setImage:user.profilePicture];
    
    return userCell;
}


- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 65;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    
    
    GOActivity *wallUpdate = ([DataStore instance].wallUpdates[indexPath.row]);
    
    sharedControllers.eventDetailViewController.goEvent = [[DataStore instance].allEventsMap objectForKey:wallUpdate.eventId];
    [sharedControllers.eventDetailSegue perform];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    NSInteger currentOffset = scrollView.contentOffset.y;
    NSInteger maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height;
    
    if (maximumOffset - currentOffset <= 0) {
        NSLog(@"reload");
        [self.indicator startAnimating];
        
        if (self.refreshingPrevious == NO) {
            
            self.refreshingPrevious = YES;
            
            [Comms getPreviousWallUpdatesForDelegate:self];
        }
    }
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

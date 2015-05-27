//
//  UserProfileTableViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 4/5/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "UserProfileTableViewController.h"
#import "Comms.h"
#import "DataStore.h"
#import "GOCustomSegues.h"
#import "GODateFormatter.h"

@interface UserProfileTableHeaderCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;

@end

@implementation UserProfileTableHeaderCell

@end

@interface UserProfileTableWallUpdateCell ()

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userActionLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel;

@end

@implementation UserProfileTableWallUpdateCell

@end

@interface UserProfileTableEventCell ()

@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;


@end

@implementation UserProfileTableEventCell

@end

@interface UserProfileTableViewController () <EventDetailTableViewControllerDelegate, CommsDelegate>

@property (strong, nonatomic) GOCustomSegues *sharedControllers;

@property (strong, nonatomic) NSMutableArray *userWallUpdates;
@property (strong, nonatomic) NSMutableArray *userEvents;

@property NSUInteger selectedIndex;

@end

@implementation UserProfileTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sharedControllers = [[GOCustomSegues alloc] initWithViewController:self];
    self.sharedControllers.eventDetailViewController.delegate = self;
    
    self.userWallUpdates = [NSMutableArray array];
    self.userEvents = [NSMutableArray array];
    
    self.selectedIndex = 0;
    
    [Comms getWallUpdatesForUser:self.fbId forDelegate:self];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void) viewWillAppear:(BOOL)animated {
    [Comms getWallUpdatesForUser:self.fbId forDelegate:self];
    //[self.userEvents setArray:[DataStore eventsForUserId:self.fbId]];
    
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)segmentedControlValueChanged:(id)sender {
    if (self.selectedIndex == 0) {
        
        self.selectedIndex = 1;
        
    }else self.selectedIndex = 0;
    
    [self.tableView reloadData];
}

- (void)dismissEventDetailViewController {
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)commsDidGetWallUpdatesForUser:(BOOL)success {
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (self.selectedIndex == 0) {
        return ([DataStore instance].userWallUpdates.count + 1);
    }else return (self.userEvents.count + 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        
        UserProfileTableHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserHeaderCell" forIndexPath:indexPath];
        [cell.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
        
        NSDictionary<FBGraphUser> *user = [[DataStore instance].fbFriends objectForKey:self.fbId];
        [cell.profilePicture setImage:user[@"fbProfilePicture"]];
        cell.nameLabel.text = user.name;
        
        return cell;
        
    }else if (self.selectedIndex == 0) {
        
        UserProfileTableWallUpdateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserWallUpdateCell"];
        
        GOActivity *wallUpdate = ([DataStore instance].userWallUpdates[(indexPath.row - 1)]);
        GOUser *user = [[DataStore instance] userForId:wallUpdate.fromUserId];
        
        cell.userActionLabel.text = wallUpdate.content;
        
        cell.userActionLabel.numberOfLines = 0;
        cell.userActionLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        NSString *postTime = [GODateFormatter formattedDate:wallUpdate.createdAt];
        [cell.postTimeLabel setText:postTime];
        
        // Add the user's profile picture to the header cell
        [cell.profilePicture setImage:user.profilePicture];
        
        return cell;
        
    }else {
        UserProfileTableEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserEventCell"];
        
        GOEvent *event = self.userEvents[(indexPath.row - 1)];
        
        cell.eventNameLabel.text = event.name;
        cell.eventTimeLabel.text = [GODateFormatter formattedDateForDatePicker:event.startDate];
        
        return cell;
    }
    
    
    // Configure the cell...
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return 135.0;
    }else if (self.selectedIndex == 0) {
        
        return 65;
    }else {
        return 55.0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row > 0) {
        if (self.selectedIndex == 0) {
            GOActivity *wallUpdate = [DataStore instance].userWallUpdates[(indexPath.row - 1)];
            
            GOEvent *goEvent = [[DataStore instance] eventForId:wallUpdate.eventId];
            self.sharedControllers.eventDetailViewController.goEvent = goEvent;
        }else {
            self.sharedControllers.eventDetailViewController.goEvent = self.userEvents[(indexPath.row - 1)];
        }
        [self.sharedControllers.eventDetailSegue perform];
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

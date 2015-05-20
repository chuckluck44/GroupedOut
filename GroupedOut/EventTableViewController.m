//
//  EventTableViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/20/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "EventTableViewController.h"
#import <Parse/Parse.h>

#import "DataStore.h"
#import "Comms.h"
#import "GOCustomSegues.h"

#import "Event.h"
#import "EventDateMap.h"
#import "GODateFormatter.h"

#import "GuestDetailsTableViewController.h"
#import "InviteTableViewController.h"
#import "EventDetailTableViewController.h"


@interface EventTableTitleCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
    
@property (nonatomic, weak) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property  (weak, nonatomic) IBOutlet UIButton *friendsGoingButton;
@property  (weak, nonatomic) IBOutlet UIButton *peopleGoingButton;

@end

@implementation EventTableTitleCell

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.users count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GOUser *user = [self.users objectAtIndex:indexPath.row];
    
    EventTableCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ProfilePictureCollectionCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell.profilePicture setImage:user.profilePicture];
    
    NSArray *array = [user.name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cell.userNameLabel.text = [array firstObject];
    
    return cell;
}
// 4
/*- (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }*/

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    GOUser *user = [self.users objectAtIndex:indexPath.row];
    
    [self.delegate selectedUserWithId:user.fbId];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout {
    return CGSizeMake(30, self.frame.size.height - 10);
}


// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

@end

/*
@interface EventTableProfilePictureCollectionCell () <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

@implementation EventTableProfilePictureCollectionCell

#pragma mark - UICollectionView Datasource
// 1
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.users count];
}
// 2
- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}
// 3
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    GOUser *user = [self.users objectAtIndex:indexPath.row];
    
    EventTableCollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"ProfilePictureCollectionCell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor whiteColor];
    [cell.profilePicture setImage:user.profilePicture];
    //[cell.profilePicture.layer setBorderWidth:3.0];
    //[cell.profilePicture.layer setBorderColor:(__bridge CGColorRef)([UIColor colorWithRed:242 green:133 blue:0 alpha:1])];
    
    NSArray *array = [user.name componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    cell.userNameLabel.text = [array firstObject];
    
    return cell;
}
// 4
 (UICollectionReusableView *)collectionView:
 (UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
 {
 return [[UICollectionReusableView alloc] init];
 }

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
     GOUser *user = [self.users objectAtIndex:indexPath.row];
    
    [self.delegate selectedUserWithId:user.fbId];
}
- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    // TODO: Deselect item
}

#pragma mark – UICollectionViewDelegateFlowLayout

// 1
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout {
    return CGSizeMake(30, self.frame.size.height - 10);
}


// 3
- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(0, 0, 0, 0);
}
@end

@interface EventTableCollectionViewCell ()

@end

@implementation EventTableCollectionViewCell

@end


@interface EventTableGoingCell ()
    
@property  (weak, nonatomic) IBOutlet UIButton *friendsGoingButton;
@property  (weak, nonatomic) IBOutlet UIButton *peopleGoingButton;

@end

@implementation EventTableGoingCell

@end

*/



@interface EventTableViewController () <CommsDelegate, InviteTableViewControllerDelegate, EventDetailTableViewControllerDelegate, NewEventViewControllerDelegate, ProfilePictureCollectionViewCellDelegate, UserProfileTableViewControllerDelegate, UISearchBarDelegate, UISearchDisplayDelegate> {
    GOCustomSegues *segues;
    
}
@property (weak, nonatomic) UIButton *activatedButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentedControl;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@property (strong, nonatomic) EventDateMap *eventsForTable;
@property (strong, nonatomic) NSMutableArray *filteredSearchArray;


@end

@implementation EventTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    segues = [[GOCustomSegues alloc] initWithViewController:self];
    segues.inviteViewController.delegate = self;
    segues.addEventViewController.delegate = self;
    segues.eventDetailViewController.delegate =self;
    segues.userProfileViewController.delegate = self;
    
    self.eventsForTable =  [DataStore instance].friendEventDateMap;
    
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    
    self.searchBar.scopeButtonTitles = [NSArray arrayWithObjects:@"Events", @"Friends", nil];
    self.searchBar.showsScopeBar = YES;
    [self.searchBar setSelectedScopeButtonIndex:0];
    self.filteredSearchArray = [NSMutableArray array];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloaded:)
                                                 name:N_ProfilePictureLoaded
                                               object:nil];
    
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

- (void) imageDownloaded:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (void)commsDidUpdateUserLocation:(BOOL)success {
    if (success) {
        NSLog(@"%@ Updated user Location", self);
        [Comms getEventsSinceLastUpdateForDelegate:self];
        
    }else {
        NSLog(@"%@ Failed to Update Location",self);
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
    
    NSLog(@" %@ Fetched Event Updates", self);
    // Update the update timestamp
    
    if (self.refreshControl) {
        NSString *lastUpdated = [NSString stringWithFormat:@"Last updated on %@", [GODateFormatter formattedDateForDatePicker:[NSDate date]]];
        [self.refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
        [self.refreshControl endRefreshing];
    }
    
    
    // Refresh the table data to sh
    [self.tableView reloadData];
    
}

- (void)commsAddUserToEventComplete:(BOOL)success {
    [self.activatedButton setEnabled:YES];
    if (success) {
        [self.activatedButton setTitle:@"Joined" forState:UIControlStateNormal];
        [self.tableView reloadData];
        
        [segues.inviteSegue perform];
        
    }else {
        NSLog(@"%@ Failed to Join",self);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Join" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    self.activatedButton = nil;
}

- (void)commsRemoveUserFromEventComplete:(BOOL)success {
    NSLog(@"User Left event");
    [self.activatedButton setEnabled:YES];
    if (success) {
        [self.activatedButton setTitle:@"Join" forState:UIControlStateNormal];
        [self.tableView reloadData];
    }else {
        segues.inviteViewController.eventId = nil;
        
        NSLog(@"%@ Failed to Leave",self);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Leave" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
    self.activatedButton = nil;
}

- (IBAction)handleJoinButton:(id)sender {
    
    int section = [sender tag] / 100;
    int row = [sender tag] % 100;
    
    GOEvent *event = [self.eventsForTable eventForRow:row inSection:section];
    self.activatedButton = sender;
    
    if ([event currentUserGoing] == NO) {
        
        segues.inviteViewController.eventId = event.objectId;
        
        [sender setEnabled:NO];
        [Comms addUserToEvent:event.objectId withUser:nil forDelegate:self];
        
    }else {
        [sender setEnabled:NO];
        [Comms removeUserFromEvent:event.objectId forDelegate:self];
    }
}

- (IBAction)handleAddEventButton:(id)sender {
    [segues.addEventSegue perform];
    
}

- (IBAction)handleFriendsButton:(id)sender {
    
    int section = [sender tag] / 100;
    int row = [sender tag] % 100;
    
    GOEvent *event = [self.eventsForTable eventForRow:row inSection:section];
    
    segues.guestDetailViewController.going = event.going;
    segues.guestDetailViewController.eventId = event.objectId;
    
    segues.guestDetailViewController.startAtTop = YES;
    [segues.guestDetailSegue perform];
    
}

- (IBAction)handlePeopleButton:(id)sender {
    
    int section = [sender tag] / 100;
    int row = [sender tag] % 100;

    GOEvent *event = [self.eventsForTable eventForRow:row inSection:section];
    
    segues.guestDetailViewController.going = event.going;
    segues.guestDetailViewController.eventId = event.objectId;
    
    segues.guestDetailViewController.startAtTop = NO;
    [segues.guestDetailSegue perform];
}

- (IBAction)handleSegmentedControl:(id)sender {
    if (self.segmentedControl.selectedSegmentIndex == 0) {
        
        self.eventsForTable = [DataStore instance].publicEventDateMap;
        
    }else if (self.segmentedControl.selectedSegmentIndex == 1){
        
        self.eventsForTable = [DataStore instance].friendEventDateMap;
        
    }
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

- (void)segmentedControlValueChanged:(id)sender {
    
    if (self.segmentedControl.selectedSegmentIndex == 1) {
        
        self.eventsForTable =  [DataStore instance].publicEventDateMap;
        
    }else self.eventsForTable =  [DataStore instance].friendEventDateMap;
    
    [self.tableView reloadData];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    int section = [sender tag] / 100;
    int row = [sender tag] % 100;

    if ([segue.identifier isEqualToString:@"GuestDetailSegue"]) {

        GOEvent *event = [self.eventsForTable eventForRow:row inSection:section];
        
        segues.guestDetailViewController.going = event.going;
        segues.guestDetailViewController.eventId = event.objectId;
        
    }
}

- (void)selectedUserWithId:(NSString *)fbId {

    segues.userProfileViewController.fbId = fbId;
    
    [segues.userProfileSegue perform];
}

- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
    segues.inviteViewController.eventId = nil;
}

- (void)dismissEventDetailViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissNewEventViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissUserProfileViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return 1;
    }
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            return [self.filteredSearchArray count];
        }else return [self.filteredSearchArray count];
    }
    
    switch (section) {
        case 0:
            return [self.eventsForTable.today count];
            
        case 1:
            return [self.eventsForTable.week count];
            
        case 2:
            return [self.eventsForTable.month count];
            
        case 3:
            return [self.eventsForTable.future count];
            
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.searchBar.selectedScopeButtonIndex == 1) {
        
        UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"UserSearchCell"];
        NSDictionary<FBGraphUser> *user = self.filteredSearchArray[indexPath.row];
        
        cell.textLabel.text = user.name;
        [cell.imageView setImage:user[@"fbProfilePicture"]];
        
        return cell;
        
    }
    else {
        
        EventTableTitleCell *cell = (EventTableTitleCell *)[self.tableView dequeueReusableCellWithIdentifier:@"EventHeaderCell"];
        
        GOEvent *event;
        
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            event = self.filteredSearchArray[indexPath.row];
        }else {
            event = [self.eventsForTable eventForRow:indexPath.row inSection:indexPath.section];
        }
        NSLog(@"EVENT NAME %@", event.name);
        cell.eventTitleLabel.text = event.name;
        cell.eventTimeLabel.text = [GODateFormatter formattedDateForDatePicker:event.startDate];
        
        if ([event.userId isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
            [cell.joinButton setHidden:YES];
        }
        if ([event currentUserGoing]) {
            [cell.joinButton setTitle:@"Joined" forState:UIControlStateNormal];
        }else
            [cell.joinButton setTitle:@"+Join" forState:UIControlStateNormal];
        
        [cell.joinButton setTag:(indexPath.row + indexPath.section * 100)];
        
        //Profile Collection View
        cell.users = [NSMutableArray array];
        cell.delegate = self;
        
        for (NSString *fbId in event.going) {
            GOUser *user = [[DataStore instance].fbFriends objectForKey:fbId];
            [cell.users addObject:user];
        }
        [cell.collectionView reloadData];
        
        //Going
        [cell.friendsGoingButton setTitle:[NSString stringWithFormat:@"%ld FRIENDS", (unsigned long)[event friendsGoing].count] forState:UIControlStateNormal];
        [cell.friendsGoingButton setTag:(indexPath.row + indexPath.section * 100)];
        [cell.peopleGoingButton setTitle:[NSString stringWithFormat:@"%ld PEOPLE", (unsigned long)[event usersGoing].count] forState:UIControlStateNormal];
        [cell.peopleGoingButton setTag:(indexPath.row + indexPath.section * 100)];
        
        return cell;
    }
    
    
    
    

}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView && self.searchBar.selectedScopeButtonIndex == 1) {
        return 45;
    }
    else {
        return 145.0;
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return nil;
    }
    
    if (section == 0 && [self.eventsForTable.today count] > 0) {
        return @"Today";
    }
    if (section == 1 && [self.eventsForTable.week count] > 0) {
        return @"This Week";
    }
    if (section == 2 && [self.eventsForTable.month count] > 0) {
        return @"This Month";
    }
    if (section == 3 && [self.eventsForTable.future count] > 0) {
        return @"In the Future";
    }
    return @"";
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        if (self.searchBar.selectedScopeButtonIndex == 0) {
            GOEvent *event = self.filteredSearchArray[indexPath.row];
            segues.eventDetailViewController.goEvent = event;
            [segues.eventDetailSegue perform];
        }else {
            GOUser *user = self.filteredSearchArray[(indexPath.row)];
            segues.userProfileViewController.fbId = user.fbId;
            [segues.userProfileSegue perform];
        }
    }else {
        
        GOEvent *event = [self.eventsForTable eventForRow:indexPath.row inSection:indexPath.section];
        segues.eventDetailViewController.goEvent = event;
        [segues.eventDetailSegue perform];
        
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

#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredSearchArray removeAllObjects];
    // Filter the array using NSPredicate
    
    if ([scope isEqualToString:@"Events"]) {
        
        NSPredicate *eventPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains[c] %@",searchText];
        self.filteredSearchArray = [NSMutableArray arrayWithArray:[[[DataStore instance].allEventsMap allValues] filteredArrayUsingPredicate:eventPredicate]];
    }else {
        
        NSPredicate *userPredicate = [NSPredicate predicateWithFormat:@"SELF.name contains %@", searchText];
        self.filteredSearchArray = [NSMutableArray arrayWithArray:[[[DataStore instance].fbFriends allValues] filteredArrayUsingPredicate:userPredicate]];
    }
    
    
}

#pragma mark - Search Bar Delegate Methods

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end

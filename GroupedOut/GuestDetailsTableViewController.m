//
//  GuestDetailsTableViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/28/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "GuestDetailsTableViewController.h"
#import "Comms.h"
#import "DataStore.h"
#import "GOCustomSegues.h"

@interface GuestDetailsTableViewController () <InviteTableViewControllerDelegate ,UserProfileTableViewControllerDelegate, CommsDelegate> {
    
    
    NSArray *friendIds;
    NSArray *peopleIds;
}

@property (strong, nonatomic) GOCustomSegues *sharedControllers;
@property (strong, nonatomic) NSMutableArray *friends;
@property (strong, nonatomic) NSMutableArray *users;

@property BOOL loading;

@end

@implementation GuestDetailsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sharedControllers = [[GOCustomSegues alloc] initWithViewController:self];
    self.sharedControllers.userProfileViewController.delegate = self;
    self.sharedControllers.inviteViewController.delegate = self;
    
    self.loading = YES;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(imageDownloaded:)
                                                 name:N_ProfilePictureLoaded
                                               object:nil];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    NSArray *meAndMyFriends = [DataStore instance].fbFriends.allKeys;
    NSMutableSet *friendSet = [NSMutableSet setWithArray:self.going];
    [friendSet intersectSet:[NSSet setWithArray:meAndMyFriends]];
    NSMutableSet *peopleSet = [NSMutableSet setWithArray:self.going];
    [peopleSet minusSet:friendSet];
    
    friendIds = [friendSet allObjects];
    peopleIds = [peopleSet allObjects];
    
    [Comms getFBProfilesForIds:peopleIds forDelegate:self];
}

- (void)viewWillDisappear:(BOOL)animated {
    self.loading = YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) imageDownloaded:(NSNotification *)notification {
    [self.tableView reloadData];
}


- (IBAction)handleInvitePress:(id)sender {
    
    self.sharedControllers.inviteViewController.eventId = self.eventId;
    [self.sharedControllers.inviteSegue perform];
    
}

- (void)dismissViewController {
    self.sharedControllers.inviteViewController.eventId = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)dismissUserProfileViewController {
    self.sharedControllers.userProfileViewController.fbId = nil;
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)commsDidGetFBProfiles:(BOOL)success {
    if (success) {
        
        self.loading = NO;
        [self.tableView reloadData];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return friendIds.count;
    }
    return peopleIds.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (self.loading == YES) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RefreshCell"];
        
        UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [cell addSubview:indicator];
        
        indicator.center = CGPointMake(cell.frame.size.width / 2, cell.frame.size.height / 2);
        
        return cell;
    }else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GuestDetailCell" forIndexPath:indexPath];
        
        // Configure the cell...
        if (indexPath.section == 0) {
            
            NSDictionary<FBGraphUser> *user = [[DataStore instance].fbFriends objectForKey:friendIds[indexPath.row]];
            
            cell.textLabel.text = user.name;
            [cell.imageView setImage:user[@"fbProfilePicture"]];
        }else {
            
            /*
            if (indexPath.row % 30 == 0) {
                
                NSArray *idArray;
                
                if (indexPath.row + 29 <= people.count) {
                    idArray = [people subarrayWithRange:NSMakeRange(indexPath.row, 30)];
                }else {
                    idArray = [people subarrayWithRange:NSMakeRange(indexPath.row, (people.count - indexPath.row))];
                }
                
                [Comms getFBProfilesForIds:idArray];
            }
             */
             
            NSDictionary<FBGraphUser> *user = [[DataStore instance].fbUsers objectForKey:peopleIds[indexPath.row]];
            cell.textLabel.text = user.name;
        }
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.sharedControllers.userProfileViewController.fbId = friendIds[indexPath.row];
        [self.sharedControllers.userProfileSegue perform];
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

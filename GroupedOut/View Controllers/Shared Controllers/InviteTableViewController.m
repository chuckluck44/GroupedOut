//
//  InviteTableViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/30/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "InviteTableViewController.h"
#import "DataStore.h"
#import "Comms.h"

@interface InviteTableViewController () <CommsDelegate> {
    
    __weak IBOutlet UIBarButtonItem *inviteButton;
    
    NSMutableArray *idArray;
    NSUInteger *selections;
}
@end

@implementation InviteTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [inviteButton setEnabled:NO];
    
    idArray = [NSMutableArray array];
    selections = 0;
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)handleInvite:(id)sender {
    [sender setEnabled:NO];
    [Comms inviteUsers:idArray toEvent:self.eventId forDelegate:self];
}

- (IBAction)handleCancel:(id)sender {
    [self.delegate dismissViewController];
}

- (void)commsDidSendInvite:(BOOL)success {
    [inviteButton setEnabled:YES];
    if (success) {
        [inviteButton setEnabled:YES];
        [self.delegate dismissViewController];
    }else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Could not send invite" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ([[DataStore instance].fbFriends count]);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InviteCell" forIndexPath:indexPath];
    
    // Configure the cell...
    NSArray *fbIds = [[DataStore instance].fbFriends allKeys];
    NSDictionary<FBGraphUser> *friend = [[DataStore instance].fbFriends objectForKey:fbIds[indexPath.row]];
    cell.textLabel.text = friend.name;
    [cell.imageView setImage:friend[@"fbProfilePicture"]];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSArray *fbIds = [[DataStore instance].fbFriends allKeys];
    
    UITableViewCell *selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    
    if (selectedCell.accessoryType == UITableViewCellAccessoryNone){
        selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;
        [idArray addObject:fbIds[indexPath.row]];
        if (selections == 0) [inviteButton setEnabled:YES];
        selections++;
        
    }else if (selectedCell.accessoryType == UITableViewCellAccessoryCheckmark){
        selectedCell.accessoryType = UITableViewCellAccessoryNone;
        [idArray removeObject:fbIds[indexPath.row]];
        if (selections == 0) [inviteButton setEnabled:NO];
        
    }
    
    double delayInSeconds = 0.8;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
    });
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

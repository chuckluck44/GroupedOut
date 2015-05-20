//
//  EventDetailTableViewController.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 4/1/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "EventDetailTableViewController.h"
#import <Parse/Parse.h>
#import "Comms.h"
#import "GODateFormatter.h"
#import "GOCustomSegues.h"


@interface EventDetailTableEventCell ()

@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventLocationLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDetailsLabel;
@property (weak, nonatomic) IBOutlet UIButton *eventFriendsButton;
@property (weak, nonatomic) IBOutlet UIButton *eventGoingButton;
@property (weak, nonatomic) IBOutlet UIButton *joinButton;
@property (weak, nonatomic) IBOutlet UILabel *commentLabel;

@end

@implementation EventDetailTableEventCell
@end

@interface EventDetailTableAddCommentCell ()

@property (weak, nonatomic) IBOutlet UITextField *addCommentTextField;
@property (weak, nonatomic) IBOutlet UIButton *postButton;

@end

@implementation EventDetailTableAddCommentCell
@end

@interface EventDetailTableCommentCell ()
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UILabel *userActionLabel;
@property (weak, nonatomic) IBOutlet UILabel *postTimeLabel;

@end

@implementation EventDetailTableCommentCell
@end





@interface EventDetailTableViewController () <CommsDelegate, InviteTableViewControllerDelegate, NewEventViewControllerDelegate>

@property (strong, nonatomic) GOCustomSegues *sharedControllers;
@property (weak, nonatomic) UIButton *joinButton;

@property (weak, nonatomic) UITextField *addCommentTextField;
@property (weak, nonatomic) UIButton *postButton;
@property (strong, nonatomic) UIActivityIndicatorView *indicator;

@property (strong, nonatomic) NSMutableDictionary *lastCommentUpdatesforEvent;
@property (strong, nonatomic) NSDate *lastEventUpdate;
@property (strong, nonatomic) NSDate *lastCommentUpdate;

@end

@implementation EventDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sharedControllers = [[GOCustomSegues alloc] initWithViewController:self];
    self.sharedControllers.inviteViewController.delegate = self;
    self.sharedControllers.addEventViewController.delegate = self;
    
    self.indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    
    self.lastCommentUpdate = [NSDate distantPast];
    self.lastEventUpdate = [NSDate distantPast];
    
    self.lastCommentUpdatesforEvent = [[NSMutableDictionary alloc] init];
    [self.lastCommentUpdatesforEvent setObject:self.lastCommentUpdate forKey:self.goEvent.objectId];
    
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
    
    self.navigationItem.title = self.goEvent.name;
    [self.tableView reloadData];
    
    [Comms getCommentsForEvent:self.goEvent.objectId forDelegate:self];
}

- (void)viewDidDisappear:(BOOL)animated {
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) imageDownloaded:(NSNotification *)notification {
    [self.tableView reloadData];
}

- (IBAction)handleLocationPress:(id)sender {
}

- (IBAction)handleFriendsPress:(id)sender {
    
    self.sharedControllers.guestDetailViewController.startAtTop = YES;
    
    self.sharedControllers.guestDetailViewController.going = self.goEvent.going;
    self.sharedControllers.guestDetailViewController.eventId = self.goEvent.objectId;
    
    [self.sharedControllers.guestDetailSegue perform];
    
}

- (IBAction)handleGoingPress:(id)sender {
    
    self.sharedControllers.guestDetailViewController.startAtTop = NO;
    [self.sharedControllers.guestDetailSegue perform];
    
}

- (IBAction)handleJoinPress:(id)sender {
    
    if ([self.goEvent.userId isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
        
        self.sharedControllers.addEventViewController.userEvent = self.goEvent;
        [self.sharedControllers.addEventSegue perform];
        
    }
    
    else if (![self.goEvent.going containsObject:[[PFUser currentUser] objectForKey:@"fbId"]]) {
        
        self.sharedControllers.inviteViewController.eventId = self.goEvent.objectId;
        
        [sender setEnabled:NO];
        [Comms addUserToEvent:self.goEvent.objectId withUser:nil forDelegate:self];
        
    }else {
        [sender setEnabled:NO];
        [Comms removeUserFromEvent:self.goEvent.objectId forDelegate:self];
    }
}

- (IBAction)handlePostButton:(id)sender {
    
    if ([self.addCommentTextField.text isEqualToString:@""]) return;
    
    NSLog(@"Going to post comment" );
    
    [self.postButton setEnabled:NO];
    [self.postButton setHidden:YES];
    
    [self.indicator startAnimating];
    
    [Comms uploadEventComment:self.addCommentTextField.text onEvent:self.goEvent.objectId forDelegate:self];
    
}

- (void)commsAddUserToEventComplete:(BOOL)success {
    [self.joinButton setEnabled:YES];
    if (success) {
        [self.joinButton setTitle:@"Joined" forState:UIControlStateNormal];
        [self.tableView reloadData];
        
        [self.sharedControllers.inviteSegue perform];
        
    }else {
        NSLog(@"%@ Failed to Join",self);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to Join" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)commsUploadEventCommentComplete:(BOOL)success {
    NSLog(@"Comms uploaded comment");
    
    [self.postButton setEnabled:YES];
    [self.postButton setHidden:NO];
    [self.indicator stopAnimating];
    
    if (!success) {
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Failed to post comment" delegate:self cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        
        [alert show];
    }else {
        
        self.addCommentTextField.text = @"";
        [Comms getCommentsForEvent:self.goEvent.objectId forDelegate:self];
    }
    
}

- (void)commsDidGetNewEventComments:(BOOL)success {
    
    NSMutableArray *uncachedUserIds = [NSMutableArray array];
    
    for (GOActivity *comment in [DataStore instance].eventComments) {
        if (![[DataStore instance] userForId:comment.fromUserId]) {
            [uncachedUserIds addObject:comment.fromUserId];
        }
    }
    
    [Comms getFBProfilesForIds:uncachedUserIds forDelegate:self];
    
    [self.tableView reloadData];
    
}

- (void)commsDidGetNewEvents:(BOOL)success {
    [self.tableView reloadData];
}

- (void)commsDidGetFBProfiles:(BOOL)success {
    if (success) {
        [self.tableView reloadData];
    }
}
    
#pragma mark - Invite view controller delegate

- (void)dismissNewEventViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - Invite view controller delegate

- (void)dismissViewController {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return ([[DataStore instance].eventComments count] + 2);
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        EventDetailTableEventCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EventCell" forIndexPath:indexPath];
        cell.eventTitleLabel.text = self.goEvent.name;
        cell.eventTimeLabel.text = [GODateFormatter formattedDateForDatePicker:self.goEvent.startDate];
        [cell.eventFriendsButton setTitle:[NSString stringWithFormat:@"%ld FRIENDS", (unsigned long)[self.goEvent friendsGoing].count] forState:UIControlStateNormal];
        [cell.eventGoingButton setTitle:[NSString stringWithFormat:@"%ld GOING", (unsigned long)[self.goEvent usersGoing].count] forState:UIControlStateNormal];
        
        if (self.goEvent.details == nil) {
            [cell.eventDetailsLabel setHidden:YES];
        }else {
            cell.eventDetailsLabel.text = self.goEvent.details;
        }
        
        if (self.goEvent.location) {
            cell.eventLocationLabel.text = self.goEvent.location;
        }
        
        if ([self.goEvent.userId isEqualToString:[[PFUser currentUser] objectForKey:@"fbId"]]) {
            [cell.joinButton setTitle:@"Edit" forState:UIControlStateNormal];
        }else if ([self.goEvent currentUserGoing]) {
            [cell.joinButton setTitle:@"Joined" forState:UIControlStateNormal];
        }else {
            [cell.joinButton setTitle:@"+Join" forState:UIControlStateNormal];
        }
        
        if (!self.goEvent.endDate && ([self.goEvent.startDate timeIntervalSinceNow] < -14400)) {
            [cell.joinButton setHidden:YES];
            
        }else if ([self.goEvent.endDate timeIntervalSinceNow] < 0) {
            [cell.joinButton setHidden:YES];
        }
        
        //Get join button
        self.joinButton = cell.joinButton;
        
        if ([[DataStore instance].eventComments count] == 1) {
            cell.commentLabel.text = @"1 COMMENT";
        }else {
            cell.commentLabel.text = [NSString stringWithFormat:@"%ld COMMENTS", (unsigned long)[[DataStore instance].eventComments count]];
        }
        
        
        
        return cell;
    }else if (indexPath.row == 1) {
        EventDetailTableAddCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"addCommentCell" forIndexPath:indexPath];
        
        self.addCommentTextField = cell.addCommentTextField;
        self.postButton = cell.postButton;
        
        [cell addSubview:self.indicator];
        self.indicator.center = self.postButton.center;
        
        return cell;
    }else {
        EventDetailTableCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentCell"];
        
        GOActivity *comment = [[DataStore instance].eventComments objectAtIndex:(indexPath.row -2)];
        GOUser *user = [[DataStore instance] userForId:comment.fromUserId];
        
        if (user) {
            cell.userActionLabel.text = [NSString stringWithFormat:@"%@ - %@", user.name, comment.content];
            cell.postTimeLabel.text = [GODateFormatter formattedDate:comment.createdAt];
            [cell.profilePicture setImage:user.profilePicture];
        }else {
            UIActivityIndicatorView *indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            
            indicator.center = cell.profilePicture.center;
            [indicator startAnimating];
            
            cell.userActionLabel.text = @"";
            cell.postTimeLabel.text = @"";
            
        }
        return cell;
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        if (!self.goEvent.details) {
            return 120.0;
        }else {
            return 160.0;
        }
        
    }else if (indexPath.row == 1) {
        return 45;
        
    }else {
        return 60.0;
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

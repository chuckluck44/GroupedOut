//
//  NewEventTableViewController.m
//  EventsApp
//
//  Created by Charley Luckhardt on 3/2/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "NewEventTableViewController.h"
#import "Comms.h"
#import "Date&TimeTableViewController.h"
#import "WhoCanJoinTableViewController.h"
#import "GODateFormatter.h"
#import "GOCustomSegues.h"

@interface NewEventTableViewController () <CommsDelegate, InviteTableViewControllerDelegate> {
    
    __weak IBOutlet UIBarButtonItem *doneButton;
    __weak IBOutlet UIBarButtonItem *cancelButton;
    __weak IBOutlet UITextField *eventNameTextField;
    __weak IBOutlet UITextView *eventDescriptonTextView;
    __weak IBOutlet UITableViewCell *date_TimeCell;
    __weak IBOutlet UITableViewCell *locationCell;
    __weak IBOutlet UITextField *locationTextField;
    __weak IBOutlet UITableViewCell *whoCanJoinCell;
    
    GOEvent *addEvent;
    GOCustomSegues *sharedControllers;
    
    UIActivityIndicatorView *indicator;
    
}

@end

@implementation NewEventTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (self.userEvent) {
        addEvent = self.userEvent;
        [eventNameTextField setText:addEvent.name];
        [eventDescriptonTextView setText:addEvent.description];
        date_TimeCell.detailTextLabel.text = [GODateFormatter formattedDateForDatePicker:addEvent.startDate];
        [locationTextField setText:addEvent.location];
        whoCanJoinCell.detailTextLabel.text = addEvent.privacyType;
        
    }else {
        addEvent = [GOEvent object];
        addEvent.startDate = [NSDate date];
        addEvent.privacyType = @"EventPrivacyTypeOpenInvite";
        
        date_TimeCell.detailTextLabel.text = [GODateFormatter formattedDateForDatePicker:[NSDate date]];
    }
    
    sharedControllers = [[GOCustomSegues alloc] initWithViewController:self];
    sharedControllers.inviteViewController.delegate = self;
    
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)unwindToNewEvent:(UIStoryboardSegue *)segue {
    if ([[segue sourceViewController] isKindOfClass:[Date_TimeTableViewController class]]) {
        Date_TimeTableViewController *source = [segue sourceViewController];
        addEvent.startDate = source.startDate;
        addEvent.endDate = source.endDate;
        date_TimeCell.detailTextLabel.text = [GODateFormatter formattedDateForDatePicker:source.startDate];
    }
    if ([[segue sourceViewController] isKindOfClass:[WhoCanJoinTableViewController class]]) {
        WhoCanJoinTableViewController *source = [segue sourceViewController];
        if (source.eventPrivacyType != 0) {
            addEvent.privacyType = source.eventPrivacyType;
            whoCanJoinCell.detailTextLabel.text = source.eventPrivacyType;
        }
    }
}

- (IBAction)handleDoneButton:(id)sender {
    if (eventNameTextField.text.length == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Please enter a name for your event"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
        
    }else {
        addEvent.name = eventNameTextField.text;
        if (eventDescriptonTextView.text.length != 0) {
            addEvent.details = eventDescriptonTextView.text;
        }
        
        if (locationTextField.text.length != 0) {
            addEvent.location = locationTextField.text;
        }
        
        [sender setEnabled:NO];
        
        if (self.userEvent) {
            
            [Comms updateEvent:self.userEvent.objectId withEvent:addEvent forDelegate:self];
            
        }else [Comms uploadEvent:addEvent forDelegate:self];
    }
}

- (IBAction)handleCancelButton:(id)sender {
    
    self.userEvent = nil;
    [self.delegate dismissNewEventViewController];
    
}



- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender == cancelButton) {
        NSLog(@"Dont Want this");
        self.userEvent = nil;
    }
}

- (void)commsUploadEventComplete:(BOOL)success withId:(NSString *)eventId{
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Could not upload event"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }else {
        sharedControllers.inviteViewController.eventId = eventId;
        [sharedControllers.inviteSegue perform];
    }
}

- (void)commsUpdateEventComplete:(BOOL)success {
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Could not update event"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }else {
        
        [doneButton setEnabled:YES];
        self.userEvent = nil;
        [self.delegate dismissNewEventViewController];
        
    }
}

- (void)commsDeleteEventComplete:(BOOL)success {
    if (!success) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                        message:@"Could not delete event"
                                                       delegate:self
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    }else {
        
        [indicator stopAnimating];
        self.userEvent = nil;
        [self.delegate dismissNewEventViewController];
        
    }
}

#pragma mark - Invite Delegat

- (void)dismissViewController {
    
    sharedControllers.inviteViewController.eventId = nil;
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        [self.delegate dismissNewEventViewController];
        [doneButton setEnabled:YES];
    }];
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        [self performSegueWithIdentifier:@"AddDateTimeSegue" sender:self];
    }if (indexPath.section == 2) {
        [self performSegueWithIdentifier:@"AddLocationSegue" sender:self];
    }if (indexPath.section == 3) {
        [self performSegueWithIdentifier:@"WhoCanJoinSegue" sender:self];
    }if (indexPath.section == 4) {
        
        [Comms deleteEvent:self.userEvent.objectId forDelegate:self];
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        
        indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        
        [cell.accessoryView addSubview:indicator];
        [indicator startAnimating];
        
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0 &&indexPath.row == 1) {
        return 120;
    }else if (indexPath.section == 4) {
        if (!self.userEvent) {
            return 0;
        }else return 45;
    }else return 45;
}
/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"NewEventCell" forIndexPath:indexPath];
    
    // Configure the cell...
    if (indexPath.section == 0) {
        eventNameField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    }if (indexPath.section == 1) {
        eventDescriptionField = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, cell.frame.size.width, cell.frame.size.height)];
    }if (indexPath.section == 2) {
        cell.textLabel.text = @"Time & Date";
    }if (indexPath.section == 3) {
        cell.textLabel.text = @"Location";
    }
    
    return cell;
}
*/

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

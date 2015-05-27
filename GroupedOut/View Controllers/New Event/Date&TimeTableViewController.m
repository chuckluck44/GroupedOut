//
//  Date&TimeTableViewController.m
//  EventsApp
//
//  Created by Charley Luckhardt on 3/4/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "Date&TimeTableViewController.h"
#import "GODateFormatter.h"

@interface Date_TimeTableViewController () {
    
    __weak IBOutlet UIBarButtonItem *doneButton;
    __weak IBOutlet UIDatePicker *datePicker;
    __weak IBOutlet UITableViewCell *startTimeCell;
    __weak IBOutlet UITableViewCell *endTimeCell;
    
    NSString *startDateString;
    NSString *endDateString;
}

@end

@implementation Date_TimeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [datePicker addTarget:self action:@selector(dateChanged:)
     forControlEvents:UIControlEventValueChanged];
    
    self.startDate = datePicker.date;
    startDateString = [self pickerDateString];
    
    startTimeCell.detailTextLabel.text = startDateString;
    [startTimeCell setSelected:YES];
    
    self.endDate = datePicker.date;
    endDateString = [self pickerDateString];
    
    endTimeCell.detailTextLabel.text = @"None";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated {
    
    [self.tableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dateChanged:(id)sender {
    if ([startTimeCell isSelected]) {
        self.startDate = datePicker.date;
        startDateString = [self pickerDateString];
        startTimeCell.detailTextLabel.text = startDateString;
        if (self.endDate <= self.startDate) {
            self.endDate = datePicker.date;
            endDateString = [self pickerDateString];
            endTimeCell.detailTextLabel.text = @"None";
        }
    }else {
        self.endDate = datePicker.date;
        endDateString = [self pickerDateString];
        if ([endDateString isEqualToString: startDateString]) {
            endTimeCell.detailTextLabel.text = @"None";
        }else {
            endTimeCell.detailTextLabel.text = endDateString;
        }
        
    }
}

- (NSString *)pickerDateString {
    NSDate *myDate = datePicker.date;
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"cccc, MMM d, hh:mm aa"];
    return [dateFormat stringFromDate:myDate];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if (sender != doneButton) {
        self.startDate = nil;
        self.endDate = nil;
        return;
    }
    if ([endDateString isEqualToString:startDateString]) {
        self.endDate = nil;
    }
}

#pragma mark - Table view data source

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0 || !self.endDate) {
        [datePicker setMinimumDate:[NSDate date]];
        if ([self.startDate timeIntervalSinceNow] < 0) {
            self.startDate = [NSDate date];
        }
        [datePicker setDate:self.startDate];
    }else {
        [datePicker setMinimumDate:self.startDate];
        [datePicker setDate:self.endDate];
    }
}

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
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

//
//  GODateFormatter.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/20/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "GODateFormatter.h"

@implementation GODateFormatter

+ (NSString *)formattedDate:(NSDate *)date
{
    NSTimeInterval timeSinceDate = [[NSDate date] timeIntervalSinceDate:date];
    
    // print up to 24 hours as a relative offset
    if(timeSinceDate < 24.0 * 60.0 * 60.0)
    {
        NSUInteger hoursSinceDate = (NSUInteger)(timeSinceDate / (60.0 * 60.0));
        NSUInteger minutesSinceDate = (NSUInteger)(timeSinceDate/60.0);
        
        switch(hoursSinceDate) {
            case 0:
                switch(minutesSinceDate) {
                    case 0: return @"Just Now";
                    case 1: return @"1 min ago";
                    default: return [NSString stringWithFormat:@"%d mins ago", hoursSinceDate];
            }
            case 1: return @"1 hr ago";
            default: return [NSString stringWithFormat:@"%d hrs ago", hoursSinceDate];
        }
    }
    else
    {
        /* normal NSDateFormatter stuff here */
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"MMM, dd 'at' HH:mm aa"];
        return [dateFormatter stringFromDate:date];
    }
}

+ (NSString *)formattedDateForDatePicker:(NSDate *)date {
    {
        // Initialize the formatter.
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"HH:mm aa"];
        
        // Initialize the calendar and flags.
        unsigned unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit | NSWeekdayCalendarUnit;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        
        // Create reference date for supplied date.
        NSDateComponents *comps = [calendar components:unitFlags fromDate:date];
        [comps setHour:0];
        [comps setMinute:0];
        [comps setSecond:0];
        NSDate *suppliedDate = [calendar dateFromComponents:comps];
        
        // Iterate through the eight days (tomorrow, today, and the last six).
        int i;
        for (i = -1; i < 7; i++)
        {
            // Initialize reference date.
            comps = [calendar components:unitFlags fromDate:[NSDate date]];
            [comps setHour:0];
            [comps setMinute:0];
            [comps setSecond:0];
            [comps setDay:[comps day] + i];
            NSDate *referenceDate = [calendar dateFromComponents:comps];
            // Get week day (starts at 1).
            int weekday = [[calendar components:unitFlags fromDate:referenceDate] weekday] - 1;
            
            if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == -1)
            {
                // Tomorrow
                NSString *dateString = [formatter stringFromDate:date];
                return [NSString stringWithFormat:@"Yesterday at %@", dateString];
            }
            else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 0)
            {
                // Today's time (a la iPhone Mail)
                NSString *dateString = [formatter stringFromDate:date];
                return [NSString stringWithFormat:@"Today at %@", dateString];
            }
            else if ([suppliedDate compare:referenceDate] == NSOrderedSame && i == 1)
            {
                // Today
                NSString *dateString = [formatter stringFromDate:date];
                return [NSString stringWithFormat:@"Tomorrow at %@", dateString];
            }
            else if ([suppliedDate compare:referenceDate] == NSOrderedSame)
            {
                // Day of the week
                NSString *day = [[formatter weekdaySymbols] objectAtIndex:weekday];
                return day;
            }
        }
        
        [formatter setDateFormat:@"MMM, dd 'at' HH:mm aa"];
        // It's not in those eight days.
        NSString *defaultDate = [formatter stringFromDate:date];
        return defaultDate;
    }
}

+ (NSInteger)daysFromNowToDate:(NSDate *)date {
    NSDate *fromDate;
    NSDate *toDate;
    
    NSCalendar *calender = [NSCalendar currentCalendar];
    
    [calender rangeOfUnit:NSCalendarUnitDay startDate:&fromDate interval:NULL forDate:[NSDate date]];
    [calender rangeOfUnit:NSCalendarUnitDay startDate:&toDate interval:NULL forDate:date];
    
    NSDateComponents *difference = [calender components:NSCalendarUnitDay fromDate:fromDate toDate:toDate options:0];
    
    return [difference day];
}

@end

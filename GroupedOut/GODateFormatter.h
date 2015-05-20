//
//  GODateFormatter.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/20/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GODateFormatter : NSObject

+ (NSString *)formattedDate:(NSDate *)date;
+ (NSString *)formattedDateForDatePicker:(NSDate *)date;
+ (NSInteger)daysFromNowToDate:(NSDate *)date;

@end

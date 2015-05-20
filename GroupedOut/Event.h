//
//  Event.h
//  EventsApp
//
//  Created by Charley Luckhardt on 3/2/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject

@property NSString *eventName;
@property NSString *eventDescription;
@property NSString *eventLocation;
@property NSDate *eventStartDate;
@property NSDate *eventEndDate;
@property NSString *eventPrivacyType;

- (id)initWithEventName:(NSString *)name
            description:(NSString *)description
               location:(NSString *)location
              startDate:(NSDate *)startDate
                endDate:(NSDate *)endDate
            privacyType:(NSString *)privacyType;

@end

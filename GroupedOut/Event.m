//
//  Event.m
//  EventsApp
//
//  Created by Charley Luckhardt on 3/2/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "Event.h"

@implementation Event

- (id)initWithEventName:(NSString *)name
            description:(NSString *)description
               location:(NSString *)location
              startDate:(NSDate *)startDate
                endDate:(NSDate *)endDate
            privacyType:(NSString *)privacyType {
    self = [super init];
    if (self) {
        _eventName = name;
        _eventDescription = description;
        _eventLocation = location;
        _eventStartDate = startDate;
        _eventEndDate = endDate;
        _eventPrivacyType = privacyType;
    }
    return self;
}

@end

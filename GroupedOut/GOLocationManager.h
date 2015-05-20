//
//  GOLocationManager.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/21/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol GOLocationManagerDelegate <NSObject>

- (void)goLocationManagerDidUpdateLocation:(BOOL)success;

@end

@interface GOLocationManager : NSObject

@property CLLocation *userLocation;

@property id<GOLocationManagerDelegate> delegate;

+ (GOLocationManager *)instance;
- (void)updateUserLocation;
- (void)startUpdatingUserLocation;
- (void)stopUpdatingUserLocation;

@end

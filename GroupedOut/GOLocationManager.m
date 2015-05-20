//
//  GOLocationManager.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/21/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "GOLocationManager.h"
#import <Parse/Parse.h>

@interface GOLocationManager () <CLLocationManagerDelegate>

@property CLLocationManager *locationManager;
@property BOOL stopUpdating;

@end

@implementation GOLocationManager

static GOLocationManager *instance = nil;
+ (GOLocationManager *)instance
{
    @synchronized (self) {
        if (instance == nil) {
            instance = [[GOLocationManager alloc] init];
        }
    }
    return instance;
}

- (id) init
{
    self = [super init];
    if (self) {
        PFGeoPoint *gp = [[PFUser currentUser] objectForKey:@"location"];
        
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _userLocation = [[CLLocation alloc] initWithLatitude:gp.latitude longitude:gp.longitude];
    }
    return self;
}

- (void)updateUserLocation{
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [self.locationManager startUpdatingLocation];
    self.stopUpdating = YES;
}

- (void)startUpdatingUserLocation{
    [self.locationManager startUpdatingLocation];
}

- (void)stopUpdatingUserLocation {
    [self.locationManager stopUpdatingLocation];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    [self.delegate goLocationManagerDidUpdateLocation:NO];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    if (self.stopUpdating == YES) {
        [manager stopUpdatingLocation];
    }
    
    self.userLocation = newLocation;
    
    PFGeoPoint *userGeoPoint = [PFGeoPoint geoPointWithLocation:newLocation];
    [[PFUser currentUser] setObject:userGeoPoint forKey:@"location"];
    
    [self.delegate goLocationManagerDidUpdateLocation:YES];
}

@end

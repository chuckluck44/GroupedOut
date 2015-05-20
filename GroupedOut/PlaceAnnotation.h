//
//  PlaceAnnotation.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 3/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface PlaceAnnotation : NSObject <MKAnnotation>

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, retain) NSString *subTitle;
@property (nonatomic, retain) NSURL *url;

@end



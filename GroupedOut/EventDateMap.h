//
//  EventDateMap.h
//  GroupedOut
//
//  Created by Charley Luckhardt on 5/5/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EventDateMap : NSObject

@property (nonatomic, strong) NSMutableArray *today;
@property (nonatomic, strong) NSMutableArray *week;
@property (nonatomic, strong) NSMutableArray *month;
@property (nonatomic, strong) NSMutableArray *future;
@property (nonatomic, strong) NSMutableArray *passed;

- (void)removeAllObjects;

//Class table view dsplay category
- (id)eventForRow:(NSUInteger)row inSection:(NSUInteger)section;

@end

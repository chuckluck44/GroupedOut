//
//  EventDateMap.m
//  GroupedOut
//
//  Created by Charley Luckhardt on 5/5/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "EventDateMap.h"

@implementation EventDateMap

- (id)init {
    self = [super init];
    if (self) {
        _today = [NSMutableArray array];
        _week = [NSMutableArray array];
        _month =[NSMutableArray array];
        _future = [NSMutableArray array];
        _passed = [NSMutableArray array];
    }
    return self;
}

- (void)removeAllObjects {
    [self.today removeAllObjects];
    [self.week removeAllObjects];
    [self.month removeAllObjects];
    [self.future removeAllObjects];
    [self.passed removeAllObjects];
}

- (id)eventForRow:(NSUInteger)row inSection:(NSUInteger)section {
    
    NSMutableArray *arrayForSection;
    
    switch (section) {
        case 0:
            arrayForSection = self.today;
            break;
            
        case 1:
            arrayForSection = self.week;
            break;
        
        case 2:
            arrayForSection = self.month;
            break;
            
        case 3:
            arrayForSection = self.future;
            break;
            
        default:
            break;
    }
    
    return arrayForSection[row];
}

@end

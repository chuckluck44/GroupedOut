//
//  NSOperationQueue+SharedQueue.m
//  EventsApp
//
//  Created by Charley Luckhardt on 3/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import "NSOperationQueue+SharedQueue.h"

@implementation NSOperationQueue (SharedQueue)

+ (NSOperationQueue *) pffileOperationQueue {
    static NSOperationQueue *pffileQueue = nil;
    if (pffileQueue == nil) {
        pffileQueue = [[NSOperationQueue alloc] init];
        [pffileQueue setName:@"com.rwtutorial.pffilequeue"];
    }
    return pffileQueue;
}

+ (NSOperationQueue *) profilePictureOperationQueue {
    static NSOperationQueue *profilePictureQueue = nil;
    if (profilePictureQueue == nil) {
        profilePictureQueue = [[NSOperationQueue alloc] init];
        [profilePictureQueue setName:@"com.groupedout.profilepicturequeue"];
    }
    return profilePictureQueue;
}

@end

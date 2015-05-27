//
//  NSOperationQueue+SharedQueue.h
//  EventsApp
//
//  Created by Charley Luckhardt on 3/18/15.
//  Copyright (c) 2015 Charley Luckhardt. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSOperationQueue (SharedQueue)

+ (NSOperationQueue *) pffileOperationQueue;
+ (NSOperationQueue *) profilePictureOperationQueue;

@end

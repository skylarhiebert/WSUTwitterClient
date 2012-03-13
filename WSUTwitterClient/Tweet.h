//
//  Tweet.h
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/13/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSNumber * tweetid;
@property (nonatomic, retain) NSString * handle;
@property (nonatomic, retain) NSNumber * isdeleted;
@property (nonatomic, retain) NSString * tstamp;
@property (nonatomic, retain) NSString * tweet;
@property (nonatomic, retain) NSString * wsuid;

@end

//
//  User.h
//  WSUTwitterClient
//
//  Created by Skylar Hiebert on 3/19/12.
//  Copyright (c) 2012 skylarhiebert.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface User : NSManagedObject

@property (nonatomic, retain) NSString * handle;
@property (nonatomic, retain) NSString * wsuid;

@end

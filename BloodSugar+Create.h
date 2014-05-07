//
//  BloodSugar+Create.h
//  HBP Monitor
//
//  Created by Jordan Ng on 4/21/14.
//  Copyright (c) 2014 Agency Agency. All rights reserved.
//

#import "BloodSugar.h"

@interface BloodSugar (Create)

+ (BloodSugar *)createReading:(NSNumber *)reading readingTime:(NSDate *)readingTime notes:(NSString *)notes managedObjectContext:(NSManagedObjectContext *)managedObjectContext;

+ (NSArray *)allReadingsInManagedObjectContext:(NSManagedObjectContext *)context;

@end

//
//  BloodSugar+Create.m
//  HBP Monitor
//
//  Created by Jordan Ng on 4/21/14.
//  Copyright (c) 2014 Agency Agency. All rights reserved.
//

#import "BloodSugar+Create.h"

@implementation BloodSugar (Create)

+ (BloodSugar *)createReading:(NSNumber *)reading readingTime:(NSDate *)readingTime notes:(NSString *)notes managedObjectContext:(NSManagedObjectContext *)managedObjectContext
{
    BloodSugar *bloodSugar = nil;
    if (reading) {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BloodSugar"];
        request.predicate = [NSPredicate predicateWithFormat:@"readingTime = %@", readingTime];
        
        NSError *error;
        NSArray *matches = [managedObjectContext executeFetchRequest:request error:&error];
        
        if (!matches || ([matches count] > 1)) {
            // handle error
            NSAssert(NO, @"wrong number of matches returned.");
            
        } else if ([matches count] == 0) {
            NSLog(@"Creating new Reading: %@", readingTime);
            bloodSugar = [NSEntityDescription insertNewObjectForEntityForName:@"BloodSugar"
                                                  inManagedObjectContext:managedObjectContext];
            bloodSugar.bloodReading = reading;
            bloodSugar.notes = notes;
            bloodSugar.readingTime = readingTime;
        } else {
            bloodSugar = [matches lastObject];
        }
    }
    return bloodSugar;
}

+ (NSArray *)allReadingsInManagedObjectContext:(NSManagedObjectContext *)context
{
    NSArray *readings = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"BloodSugar"];
    request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"readingTime" ascending:NO]];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
//    
    if (!matches || ([matches count] < 1)) {
        // handle error
        
        NSLog(@"No blood sugar readings found.");
        
    } else {
        NSLog(@"Readings loaded: %lu", (unsigned long)[matches count]);
        readings = matches;
    }
    
    return readings;
}

@end

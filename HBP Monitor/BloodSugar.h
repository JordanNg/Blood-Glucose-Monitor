//
//  BloodSugar.h
//  HBP Monitor
//
//  Created by Jordan Ng on 4/21/14.
//  Copyright (c) 2014 Agency Agency. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface BloodSugar : NSManagedObject

@property (nonatomic, retain) NSNumber * bloodReading;
@property (nonatomic, retain) NSDate * readingTime;
@property (nonatomic, retain) NSString * notes;

@end

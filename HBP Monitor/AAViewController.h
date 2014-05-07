//
//  AAViewController.h
//  HBP Monitor
//
//  Created by Jordan Ng on 4/3/14.
//  Copyright (c) 2014 Agency Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSManagedObjectContext *context;


@end

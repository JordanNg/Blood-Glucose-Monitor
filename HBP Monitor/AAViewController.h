//
//  AAViewController.h
//  HBP Monitor
//
//  Created by Jordan Ng on 4/3/14.
//  Copyright (c) 2014 Agency Agency. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BEMSimpleLineGraphView.h"

@interface AAViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, BEMSimpleLineGraphDelegate>
@property (weak, nonatomic) IBOutlet BEMSimpleLineGraphView *myGraph;

@property (nonatomic, strong) NSManagedObjectContext *context;
@property (strong, nonatomic) UIColor *bottomColor;

@end

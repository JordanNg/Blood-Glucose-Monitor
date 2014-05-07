//
//  AAAppDelegate.h
//  HBP Monitor
//
//  Created by Jordan Ng on 4/3/14.
//  Copyright (c) 2014 Agency Agency. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AAAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UIManagedDocument *document;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

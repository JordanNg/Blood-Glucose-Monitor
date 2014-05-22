//
//  AAViewController.m
//  HBP Monitor
//
//  Created by Jordan Ng on 4/3/14.
//  Copyright (c) 2014 Agency Agency. All rights reserved.
//

#import "AAViewController.h"
#import "BloodSugar+Create.h"
#import "AAAppDelegate.h"

static const NSInteger kNumLinePoints = 7;

@interface AAViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *readings;
@property (weak, nonatomic) IBOutlet UITextField *readingTextField;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UIButton *addMeasurementButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *inputVerticalConstraint;
@property (weak, nonatomic) IBOutlet UILabel *bloodReadingLabel;
@property (weak, nonatomic) IBOutlet UILabel *notesLabel;
@property (strong, nonatomic) id activeInput;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *markerXConstraint;
@property (weak, nonatomic) IBOutlet UIView *scaleFrameView;
@property (strong, nonatomic) BloodSugar *currentlyDisplayedReading;
@property (strong, nonatomic) NSArray *lineGraphReadings;

@end

@implementation AAViewController

- (IBAction)addMeasurementPressed:(UIButton *)sender {
    
    //Clears the text fields and makes Add Measurement button disapear
    self.addMeasurementButton.alpha = 0;
    self.readingTextField.text = nil;
    [self.datePicker setDate:[NSDate date] animated:YES];
    self.notesTextView.text = nil;
    
    //Clear the selection
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    
    //Save and Cancel buttons appear
    self.saveButton.alpha = 1;
    self.cancelButton.alpha = 1;
    
    self.bloodReadingLabel.alpha = 1;
    self.notesLabel.alpha = 1;
    
    self.currentlyDisplayedReading = nil;
    
   //Set focus to the Blood Sugar Reading Label
    [self.readingTextField becomeFirstResponder];

}

- (IBAction)cancelMeasurementPressed:(UIButton *)sender {
    
    //swithces back to the Add Measurement Button when cancel button is pressed
    self.addMeasurementButton.alpha = 1;
    self.saveButton.alpha = 0;
    self.cancelButton.alpha = 0;
    self.bloodReadingLabel.alpha = 0;
    self.notesLabel.alpha = 0;
    
    //Resets data
    [self reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    BloodSugar *reading = self.readings[indexPath.row];
    [self displayReading:reading];
}

- (IBAction)saveButtonPressed:(UIButton *)sender {
    
    [self saveReading];
}

- (void)saveReading {
    
    if (!self.currentlyDisplayedReading) {
        self.currentlyDisplayedReading = [BloodSugar createReading:@([self.readingTextField.text intValue])
                                                       readingTime:self.datePicker.date
                                                             notes:self.notesTextView.text
                                              managedObjectContext:self.context];
    }
    self.currentlyDisplayedReading.bloodReading = @([self.readingTextField.text intValue]);
    self.currentlyDisplayedReading.readingTime =self.datePicker.date;
    self.currentlyDisplayedReading.notes = self.notesTextView.text;

    [self reloadData];
    
    //Buttons change back
    self.saveButton.alpha = 0;
    self.cancelButton.alpha = 0;
    self.addMeasurementButton.alpha = 1;
    self.bloodReadingLabel.alpha = 0;
    self.notesLabel.alpha = 0;
    
    //Resets data
    [self reloadData];
    
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
    
    BloodSugar *reading = self.readings[indexPath.row];
    [self displayReading:reading];

}

-(void)reloadData
{
    self.readings = [BloodSugar allReadingsInManagedObjectContext:self.context];
    [self.tableView reloadData];
    [self.myGraph reloadGraph];
}

- (void)setContext:(NSManagedObjectContext *)context
{
    _context = context;
    NSLog(@"context set!");
    [self reloadData];
    if (self.readings) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
        
        BloodSugar *reading = self.readings[indexPath.row];
        [self displayReading:reading];
    }
}

-(NSString *)formattedReadingDate:(NSDate *)date
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateStyle:NSDateFormatterMediumStyle];
    NSString *dateString = [format stringFromDate:date];

    return dateString;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self registerForKeyboardNotifications];
    
	// Do any additional setup after loading the view, typically from a nib.
    //    AAAppDelegate *delegate = [[UIApplication sharedApplication] delegate];
    //    self.context = delegate.managedObjectContext;
    
    [self.readingTextField addTarget:self action:@selector(readingTextFieldChanged) forControlEvents:UIControlEventEditingChanged];
    
    self.myGraph.enableBezierCurve = NO;
    self.myGraph.widthLine = 4;
    
    self.myGraph.colorTop = [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.myGraph.colorBottom = [UIColor colorWithRed:255.0/255.0 green:223.0/255.0 blue:0.0/255.0 alpha:1.0];
    self.myGraph.colorXaxisLabel = [UIColor colorWithRed:0.0/255.0 green:0.0/255.0 blue:0.0/255.0 alpha:1.0];
}

- (NSInteger)numberOfPointsInLineGraph:(BEMSimpleLineGraphView *)graph {
    NSLog(@" number of lines %lu", (unsigned long)[self.lineGraphReadings count]);
    if (![self.lineGraphReadings count]) return 0;
    return MIN(kNumLinePoints, [self.lineGraphReadings count]); // Number of points in the graph.
}

- (CGFloat)lineGraph:(BEMSimpleLineGraphView *)graph valueForPointAtIndex:(NSInteger)index {
    if (![self.lineGraphReadings count]) return 0;
    BloodSugar *reading = [self.lineGraphReadings objectAtIndex:index];
    return [reading.bloodReading floatValue]; // The value of the point on the Y-Axis for the index.
}

- (NSInteger)numberOfGapsBetweenLabelsOnLineGraph:(BEMSimpleLineGraphView *)graph {
    return 0; // The number of hidden labels between each displayed label.
}

- (UIColor *)lineGraph:(BEMSimpleLineGraphView *)graph lineColorForIndex:(NSInteger)index {
    return [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0];
}

- (NSString *)lineGraph:(BEMSimpleLineGraphView *)graph labelOnXAxisForIndex:(NSInteger)index {
    if (![self.lineGraphReadings count]) return @"";
    BloodSugar *reading = [self.lineGraphReadings objectAtIndex:index];
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:@"MMM/dd"];
    NSString *dateString = [format stringFromDate:reading.readingTime];
    return [NSString stringWithFormat:@"%@", dateString];
}

- (void) setReadings:(NSArray *)readings{
    _readings = readings;
    NSInteger numReadings = MIN(kNumLinePoints, [readings count]);
    NSArray *smallArray = [readings subarrayWithRange:NSMakeRange(0, numReadings)];
    
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:[smallArray count]];
    NSEnumerator *enumerator = [smallArray reverseObjectEnumerator];
    for (id element in enumerator) {
        [array addObject:element];
    }
    self.lineGraphReadings = array;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Reading Cell" forIndexPath:indexPath];
    BloodSugar *reading = (BloodSugar *)self.readings[indexPath.row];
    NSLog(@"%@", reading);
    
    
    cell.textLabel.text = [[reading bloodReading] description];
    cell.textLabel.text = [NSString stringWithFormat:@"%@   %@", [[reading bloodReading] description],
                           [self formattedReadingDate:reading.readingTime]];
    cell.detailTextLabel.text = [reading.notes description];
    //    cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@", reading.notes, [[reading bloodReading] description]];
    //    cell.detailTextLabel.text = [reading.readingTime description];
    return cell;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.readings count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BloodSugar *reading = self.readings[indexPath.row];
    [self displayReading:reading];
}

- (void) displayReading:(BloodSugar *)reading
{
    self.readingTextField.text = [reading.bloodReading description];
    
    self.notesTextView.text = [reading.notes description];
    
    [self.datePicker setDate:reading.readingTime animated:YES];
    
    [self animateMarker];
    
    self.currentlyDisplayedReading = reading;
}

// Call this method somewhere in your view controller setup code.
- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification object:nil];
    
}

// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    if (self.activeInput == self.notesTextView) {
        self.inputVerticalConstraint.constant = 350.0;
        
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    if (self.activeInput == self.notesTextView) {
        self.inputVerticalConstraint.constant = 20.0;
        
        
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [self.view layoutIfNeeded];
                         }
                         completion:^(BOOL finished) {
                         }];
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.activeInput = textView;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.activeInput = nil;
}

-(CGFloat) markerXPosition
{
    
    CGFloat reading = [self.readingTextField.text floatValue];
    
    CGFloat bgMin = 0.0;
    CGFloat bgMax = 208.0;
    CGFloat r = MAX(bgMin, MIN(bgMax, reading));
    
    CGFloat bgRange = bgMax - bgMin;
    CGFloat x = r * self.scaleFrameView.bounds.size.width / bgRange;
    return x;
}

- (void) animateMarker
{
    self.markerXConstraint.constant = [self markerXPosition];
    [UIView animateWithDuration:2.0 delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         [self.scaleFrameView.superview layoutIfNeeded];
                     }
                     completion:nil];
    
}
- (void) readingTextFieldChanged
{
    [self animateMarker];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"])
    {
        [self saveReading];
        
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

@end
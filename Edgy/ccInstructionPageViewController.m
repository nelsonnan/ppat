//
//  ccInstructionPageViewController.m
//  ImageProcessing
//
//  Created by Marcus Lowe on 11/30/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import "ccInstructionPageViewController.h"
#import "EGCaptureController.h"
#import "ccCellView.h"

@interface ccInstructionPageViewController ()

@end


@implementation ccInstructionPageViewController

@synthesize scrollView, targetDrink, currentDrink, dataArray, lastUpdateTime;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.lastUpdateTime = [NSDate date];
    }
    return self;
}


- (void) receiveNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"NewCurrentDrink"]) {
        currentDrink = [[notification userInfo] objectForKey:@"current_drink"];
        self.lastUpdateTime = [NSDate date];
        [self populateInstructionsFromArray];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	// Do any additional setup after loading the view.
    
    if (currentDrink == nil || (self.lastUpdateTime != nil && [[NSDate date] timeIntervalSinceDate:self.lastUpdateTime] <= 300)) {
        currentDrink = [[Drink alloc]initWithDrink:COFFEE_AND_TEA AndSize:EIGHT AndStrong:NO];
    }
    //[self populateInstructions];
    if (targetDrink != nil) {
        self.title = [targetDrink colloquialRepresentation];
        [self populateInstructionsFromArray];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"NewCurrentDrink" object:nil];
    self.lastUpdateTime = [NSDate date];
}

- (void) clearInstructions {
    for(UIView *subview in [scrollView subviews]) {
        [subview removeFromSuperview];
    }
}

- (void) populateInstructions {
    [self clearInstructions];
    NSString *instructionsString = [targetDrink instructions:currentDrink];
    self.dataArray = [instructionsString componentsSeparatedByString:@" "];
    NSEnumerator *dataEnumerate = [dataArray objectEnumerator];
    NSString *data;
    int x=0;
    BOOL addedInstructions = NO;
    while ((data = [dataEnumerate nextObject])) {
        if (data.length > 0) {
            UILabel *scoreLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(x,0,40,40) ];
            scoreLabel.textAlignment =  NSTextAlignmentCenter;
            scoreLabel.backgroundColor = [UIColor blackColor];
            scoreLabel.textColor = [UIColor whiteColor];
            [scrollView addSubview:scoreLabel];
            scoreLabel.text = [NSString stringWithFormat: @"%@", data];
            x+= 40;
            addedInstructions = YES;
        }
    }
    if (!addedInstructions) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No further instructions" message:@"Success!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}

- (void) populateInstructionsFromArray {
    [self clearInstructions];
    self.dataArray = [targetDrink semanticInstructions:currentDrink];
    NSLog(@"instructions: %@", self.dataArray);
    NSEnumerator *dataEnumerate = [dataArray objectEnumerator];
    NSString *data;
    int x=0;
    BOOL addedInstructions = NO;
    while ((data = [dataEnumerate nextObject])) {
        if (data.length > 0) {
            UILabel *scoreLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(x,0,40,40) ];
            scoreLabel.textAlignment =  NSTextAlignmentCenter;
            scoreLabel.backgroundColor = [UIColor blackColor];
            scoreLabel.textColor = [UIColor whiteColor];
            [scrollView addSubview:scoreLabel];
            scoreLabel.text = [NSString stringWithFormat: @"%@", data];
            x+= 40;
            addedInstructions = YES;
        }
    }
    if (!addedInstructions) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No further instructions" message:@"Success!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// make button select
- (IBAction)confirm:(id)sender {
    EGCaptureController *captureController = [[EGCaptureController alloc] initWithNibName:nil bundle:nil];
    UIView *view = [captureController view];
    [[[UIApplication sharedApplication] keyWindow] addSubview:view];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
}
@end
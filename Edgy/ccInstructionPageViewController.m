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

// The expected starting drink
static Drink *currentDrink;

@implementation ccInstructionPageViewController

@synthesize scrollView, targetDrink, dataArray;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void) receiveNotification:(NSNotification *) notification
{
    // [notification name] should always be @"TestNotification"
    // unless you use this method for observation of other notifications
    // as well.
    NSLog(@"%@",[notification name]);
    if ([[notification name] isEqualToString:@"NewCurrentDrink"]) {
        NSLog (@"Successfully received the test notification!");
        NSLog(@"Drink: %@", [[notification userInfo] objectForKey:@"current_drink"]);
        currentDrink = [[notification userInfo] objectForKey:@"current_drink"];
        [self populateInstructions];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    	// Do any additional setup after loading the view.
    if (currentDrink == nil) {
        NSLog(@"RESET CURRENT DRINK");
        currentDrink = [[Drink alloc]initWithDrink:COFFEE_AND_TEA AndSize:EIGHT AndStrong:NO];
    }
    [self populateInstructions];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"NewCurrentDrink" object:nil];
    NSLog(@"register notification listener");

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
    NSLog(@"instructions: %@", self.dataArray);
    NSLog(@"%@", scrollView);
    NSEnumerator *dataEnumerate = [dataArray objectEnumerator];
    NSString *data;
    int x=0;
    BOOL addedInstructions = NO;
    while ((data = [dataEnumerate nextObject])) {
        if (data.length > 0) {
            NSLog(@"%@", data);
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
        UILabel *scoreLabel = [ [UILabel alloc ] initWithFrame:CGRectMake(x,0,150,40) ];
        scoreLabel.textAlignment =  NSTextAlignmentCenter;
        scoreLabel.backgroundColor = [UIColor blackColor];
        scoreLabel.textColor = [UIColor whiteColor];
        [scrollView addSubview:scoreLabel];
        scoreLabel.text = @"No instructions";
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
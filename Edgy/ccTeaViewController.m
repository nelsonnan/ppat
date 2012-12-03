//
//  ccTeaViewController.m
//  ImageProcessing
//
//  Created by User Interface Design Group on 12/3/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import "ccTeaViewController.h"

@interface ccTeaViewController ()

@end

@implementation ccTeaViewController
@synthesize icedSelector;
@synthesize sizePicker;
@synthesize size;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    size = [[NSMutableArray alloc] init];
    [size addObject:@"4 oz"];
    [size addObject:@"6 oz"];
    [size addObject:@"8 oz"];
    [size addObject:@"10 oz"];
    [size addObject:@"12 oz"];
    [size addObject:@"14 oz"];
    [size addObject:@"16 oz"];
    [size addObject:@"18 oz"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [icedSelector release];
    [sizePicker release];
    [super dealloc];
}

// make button select
- (IBAction)makeButton:(id)sender {
}



// size picker methods

- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)sizePicker numberOfRowsInComponent:(NSInteger)component {
    return [size count];
}

- (NSString *)pickerView:(UIPickerView *)sizePicker titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [size objectAtIndex:row];
}
@end

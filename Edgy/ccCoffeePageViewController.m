//
//  ccCoffeePageViewController.m
//  CoffeeControl
//
//  Created by UID on 11/26/12.
//  Copyright (c) 2012 UID. All rights reserved.
//

#import "ccCoffeePageViewController.h"
#import "EGCaptureController.h"
#import "Drink.h"

@interface ccCoffeePageViewController ()

@end

@implementation ccCoffeePageViewController

@synthesize size;
@synthesize sizePicker;
@synthesize strongSelector;
@synthesize icedSelector;
@synthesize coffeeLabel;

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
    
    // TODO: add more eventually..
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// make button select
- (IBAction)changeStrength:(id)sender {
    
    EGCaptureController *captureController = [[EGCaptureController alloc] initWithNibName:nil bundle:nil];
    UIView *view = [captureController view];
    [[[UIApplication sharedApplication] keyWindow] addSubview:view];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];

/**
    NSMutableString *inst = [NSMutableString stringWithString:@""];
    if ([self.icedSelector isOn]){
        [inst appendString:@"C1 B2"];
    } else {
        [inst appendString:@"A1 B2"];
    }
    if ([self.strongSelector isOn]){
        [inst appendString:@" C2"];
    }
    switch ([sizePicker selectedRowInComponent:0]){
        case 0:
            [inst appendString:@" A5 A5 A5"];
            break;
        case 1:
            [inst appendString:@" A5 A5"];
            break;
        case 2:
            [inst appendString:@" A5"];
            break ;
        case 3:
            break;
        case 4:
            [inst appendString:@" C5"];
            break;
    }
 
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithString:title] message:[NSString stringWithString:inst] delegate:self cancelButtonTitle:@"Done!" otherButtonTitles: nil];
 
 */
    
    NSMutableString *title = [NSMutableString stringWithString:@"Coffee Instructions"];
    
    Type t = COFFEE_AND_TEA;
    if ([icedSelector isOn]) {
        t = ICE;
    }
    
    DrinkSize d = FOUR;
    switch ([sizePicker selectedRowInComponent:0]){
    }
    
    BOOL *strong = NO;
    if ([strongSelector isOn]){
        *strong = YES;
    }
    
    Drink *drink = [[Drink alloc] initWithDrink:t AndSize:d AndStrong:*strong];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithString:title] message:[drink instruction] delegate:self cancelButtonTitle:@"Done!" otherButtonTitles: nil];
    [alert show];
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

/*- (void)pickerView:(UIPickerView *)sizePicker didSelectRow:(NSinteger)row inComponent:(NSInteger)component{
    NSLog(@"Selected choice: %@ at index %i", [size objectAtIndex:row], row);
}*/
@end

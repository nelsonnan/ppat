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
    
        // Construct the expected starting state drink
    Type starting_type = COFFEE_AND_TEA;
    DrinkSize starting_drink_size = EIGHT;
    BOOL starting_strength = NO;
    Drink *starting_drink = [[Drink alloc] initWithDrink:starting_type AndSize:starting_drink_size AndStrong:starting_strength];
    
    NSMutableString *title = [NSMutableString stringWithString:@"Coffee Instructions"];
    
    Type t = COFFEE_AND_TEA;
    if ([icedSelector isOn]) {
        t = ICE;
    }
    
    DrinkSize d = FOUR;
    // TODO: Should probably build the size picker and do this check using one object to ensure these stay in sync
    switch ([sizePicker selectedRowInComponent:0]){
        case 0:
            d = FOUR;
            break;
        case 1:
            d = SIX;
            break;
        case 2:
            d = EIGHT;
            break;
        case 3:
            d = TEN;
            break;
        case 4:
            d = TWELVE;
            break;
        case 5:
            d = FOURTEEN;
            break;
    }
    
    BOOL strong = NO;
    if ([strongSelector isOn]){
        strong = YES;
    }
    
    Drink *drink = [[Drink alloc] initWithDrink:t AndSize:d AndStrong:strong];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithString:title] message:[drink instructions:starting_drink] delegate:self cancelButtonTitle:@"Done!" otherButtonTitles: nil];
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
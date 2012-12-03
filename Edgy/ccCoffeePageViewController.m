//
//  ccCoffeePageViewController.m
//  CoffeeControl
//
//  Created by UID on 11/26/12.
//  Copyright (c) 2012 UID. All rights reserved.
//

#import "ccCoffeePageViewController.h"
#import "ccInstructionPageViewController.h"
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

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// make button select
- (IBAction)changeStrength:(id)sender {

}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showInstructions"]) {
        ccInstructionPageViewController *destViewController = segue.destinationViewController;
        
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
            case 6:
                d = SIXTEEN;
                break;
            case 7:
                d = EIGHTEEN;
                break;
        }
        
        BOOL strong = NO;
        if ([strongSelector isOn]){
            strong = YES;
        }
        
        Drink *drink = [[Drink alloc] initWithDrink:t AndSize:d AndStrong:strong AndDrinkType:COFFEE];
        destViewController.targetDrink = drink;
    }
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
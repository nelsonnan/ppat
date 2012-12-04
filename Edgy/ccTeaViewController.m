//
//  ccTeaViewController.m
//  ImageProcessing
//
//  Created by User Interface Design Group on 12/3/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import "ccTeaViewController.h"
#import "ccInstructionPageViewController.h"
#import "Drink.h"

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
        
        Drink *drink = [[Drink alloc] initWithDrinkType:t AndSize:d AndStrong:strong AndDrinkType:COFFEE];
        destViewController.targetDrink = drink;
    }
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

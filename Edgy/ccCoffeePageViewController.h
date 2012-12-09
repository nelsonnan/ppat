//
//  ccCoffeePageViewController.h
//  CoffeeControl
//
//  Created by UID on 11/26/12.
//  Copyright (c) 2012 UID. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ccCoffeePageViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>{

    __weak IBOutlet UISwitch *strongSelector;
    __weak IBOutlet UILabel *coffeeLabel;
    __weak IBOutlet UIPickerView *sizePicker;
    __weak IBOutlet UISwitch *icedSelector;
    NSMutableArray *size;
    NSMutableArray *size_iced;
}
- (IBAction)changeStrength:(id)sender;
- (IBAction)toggleIced:(id)sender;
@property (assign, nonatomic) IBOutlet UISwitch *icedSelector;
@property (assign, nonatomic) IBOutlet UILabel *coffeeLabel;
@property (assign, nonatomic) IBOutlet UIPickerView *sizePicker;
@property (assign, nonatomic) IBOutlet UISwitch *strongSelector;
@property (assign, nonatomic) NSMutableArray *size;
@property (assign, nonatomic) NSMutableArray *size_iced;
@end

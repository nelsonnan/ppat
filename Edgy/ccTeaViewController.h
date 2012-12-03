//
//  ccTeaViewController.h
//  ImageProcessing
//
//  Created by User Interface Design Group on 12/3/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ccTeaViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (retain, nonatomic) IBOutlet UISwitch *icedSelector;
@property (retain, nonatomic) IBOutlet UIPickerView *sizePicker;
- (IBAction)makeButton:(id)sender;
@property (assign, nonatomic) NSMutableArray *size;
@end

//
//  ccInstructionPageViewController.h
//  ImageProcessing
//
//  Created by Marcus Lowe on 11/30/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Drink.h"

@interface ccInstructionPageViewController : UIViewController {
    __weak IBOutlet UITableView *tableView;
}
- (IBAction)confirm:(id)sender;
- (void) receiveNotification:(NSNotification *) notification;
- (void) populateInstructions;
- (void) populateInstructionsFromArray;
- (void) clearInstructions;
@property (assign, nonatomic) IBOutlet UIScrollView *scrollView;
@property (assign, nonatomic) NSArray *dataArray;
@property (assign, nonatomic) Drink *currentDrink;
@property (assign, nonatomic) Drink *targetDrink;
@property (assign, nonatomic) NSDate *lastUpdateTime; // Resets the app to assume the default drink.

@end

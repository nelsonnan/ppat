//
//  Drink.m
//  ImageProcessing
//
//  Created by User Interface Design Group on 11/28/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import "Drink.h"

@implementation Drink
@synthesize screenType;
@synthesize drinkSize;
@synthesize strong;

/**
 Constructor
 @return new Drink
**/
- (id)initWithDrink:(Type)screen AndSize:(DrinkSize)size AndStrong:(BOOL)strength
{
    self = [super init];
    if (self){
        screenType = screen;
        drinkSize = size;
        strong = strength;
    };
    return self;
}

/**
 @return NSString instruction for input
 **/

- (NSString*)instruction
{
    NSMutableString *inst = [NSMutableString stringWithString:@""];
    
    switch(screenType) {
        case COFFEE_AND_TEA:
            [inst appendString:@"A1 "];
            break;
        case CAFE:
            [inst appendString:@"B1 "];
            break;
        case ICE:
            [inst appendString:@"C1 "];
            break;
    }
    
    if(strong){
        [inst appendString:@"C2 "];
    }
    
    NSMutableString *which = [NSMutableString stringWithString:@""];
    
    if (drinkSize <0){
        // go left
        [which appendString:@"A5 "];
    } else {
        // go right
        [which appendString:@"C5 "];
    }
    
    for (int i = 0; i < drinkSize; i++) {
        [inst appendString:which];
    }
    
    return inst;
}

@end

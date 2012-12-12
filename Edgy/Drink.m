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
@synthesize drinkType;

/**
 Constructor
 @return new Drink
 **/
- (id)initWithDrinkType:(Type)screen AndSize:(DrinkSize)size AndStrong:(BOOL)strength AndDrinkType:(DrinkType)drink
{
    self = [super init];
    if (self){
        screenType = screen;
        drinkSize = size;
        strong = strength;
        drinkType = drink;
    };
    return self;
}

- (id)initWithDrink:(Type)screen AndSize:(DrinkSize)size AndStrong:(BOOL)strength
{
    self = [super init];
    if (self){
        screenType = screen;
        drinkSize = size;
        strong = strength;
        drinkType = COFFEE;
    };
    return self;
}

/**
 * @return NSString instruction for input given a difference drink
 **/
- (NSArray*) instructions:(Drink *)current
{
    NSMutableArray *inst = [NSMutableArray array];
    if (screenType != current.screenType) {
        current.drinkSize = EIGHT;
        current.strong = NO;
        current.drinkType = COFFEE;
        switch (screenType) {
            case COFFEE_AND_TEA:
                [inst addObject:@"A1"];
                break;
            case CAFE:
                [inst addObject:@"Change tab Cafe"];
                [inst addObject:@"B1"];
                break;
            case ICE:
                [inst addObject:@"Change tab Ice"];
                [inst addObject:@"C1"];
                break;
            case LIFT_TO_BREW:
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case PLEASE_ADD_WATER:
                [inst addObject:@"Add water to the container. Then, press the confirm button again."];
                return inst;
            case SET_CLOCK_TO:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case SETTINGS:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TEMPERATURE:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TIME:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TURN_OFF_AFTER:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TURN_OFF_AT:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TURN_ON_AT:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case PREHEATING:
                [inst addObject:@"Wait for a few seconds while the machine preheats."];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            default:
                break;
        }

    }
    
    if(strong != current.strong){
        [inst addObject:@"C2 "];
    }
    
    if(drinkSize != current.drinkSize) {
        NSMutableString *which = [NSMutableString stringWithString:@""];
        
        if (current.drinkSize > drinkSize){
            // go left
            [which appendString:@"A5"];
        } else {
            // go right
            [which appendString:@"C5"];
        }
        
        for (int i = 0; i < fabs(current.drinkSize - drinkSize); i++) {
            [inst addObject:which];
        }
    }
    // Trim the last white space and return
    return inst;
}
/**
 * @ return NSString the colloquial representation of the size. Does not end in a space.
 */
- (NSString*) colloquialSize
{
    NSMutableString *inst = [NSMutableString stringWithString:@""];
    switch(drinkSize) {
        case FOUR:
            [inst appendString:@"4oz"];
            break;
        case SIX:
            [inst appendString:@"6oz"];
            break;
        case EIGHT:
            [inst appendString:@"8oz"];
            break;
        case TEN:
            [inst appendString:@"10oz"];
            break;
        case TWELVE:
            [inst appendString:@"12oz"];
            break;
        case FOURTEEN:
            [inst appendString:@"14oz"];
            break;
        case SIXTEEN:
            [inst appendString:@"16oz"];
            break;
        case EIGHTEEN:
            [inst appendString:@"18oz"];
            break;
    }
    return inst;
}

/**
 * @ return NSString the colloquial representation of the type. Does not end in a space.
 */
- (NSString*) colloquialType
{
     NSMutableString *inst = [NSMutableString stringWithString:@""];
    if (strong) {
        [inst appendString:@"Strong "];
    }
    if (screenType == ICE) {
        [inst appendString:@"Iced "];
    }
    switch (drinkType) {
        case COFFEE:
            [inst appendString:@"Coffee"];
            break;
        case TEA:
            [inst appendString:@"Tea"];
            break;
        case DRINK_CAFE:
            [inst appendString:@"Cafe"];
            break;
        case HOT_COCOA:
            [inst appendString:@"Cocoa"];
            break;
        case OTHER:
            break;
    }

    return inst;
}


/**
 * @ return NSString the colloquial representation for the drink object to be displayed to the user
 */
- (NSString*) colloquialRepresentation
{
    NSMutableString *inst = [NSMutableString stringWithString:@""];
    [inst appendString:[self colloquialSize]];
    [inst appendString:@" "];
    [inst appendString:[self colloquialType]];
    return inst;
}

/**
 * @return NSArray instruction set for input given difference drink, uses semantic representation
 */
- (NSArray*) semanticInstructions:(Drink*) current
{
    NSMutableArray *inst = [NSMutableArray array];
    if (screenType != current.screenType) {
        // switching pages switches the screen so we must update the current drink as such
        current.drinkSize = EIGHT;
        current.strong = NO;
        current.drinkType = COFFEE;
        // Ensure we don't have another screen currently, if so give some aux instructions to get to the default screen.
        switch (current.screenType) {
            case LIFT_TO_BREW:
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case PLEASE_ADD_WATER:
                [inst addObject:@"Add water to the container. Then, press the confirm button again."];
                return inst;
            case SET_CLOCK_TO:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case SETTINGS:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TEMPERATURE:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TIME: 
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TURN_OFF_AFTER:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TURN_OFF_AT:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case TURN_ON_AT:
                [inst addObject:@"Go back to the main screen."];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"A5"];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            case PREHEATING:
                [inst addObject:@"Wait for a few seconds while the machine preheats."];
                [inst addObject:@"Lift the K-cup holder, insert a K-cup, close the lid. Then, press the confirm button again."];
                return inst;
            default:
                break;

        }
        switch (screenType) {
            case COFFEE_AND_TEA:
                [inst addObject:@"Change tab Coffee"];
                [inst addObject:@"A1"];
                break;
            case CAFE:
                [inst addObject:@"Change tab Cafe"];
                [inst addObject:@"B1"];
                break;
            case ICE:
                [inst addObject:@"Change tab Ice"];
                [inst addObject:@"C1"];
                break;
            default:
                break;
        }
    }
    
    if (drinkType != current.drinkType) {
        switch(drinkType) {
            case COFFEE:
                [inst addObject:@"Select coffee"];
                [inst addObject:@"A2"];
                break;               
            case TEA:
                [inst addObject:@"Select tea"];
                [inst addObject:@"A3"];
                break;     
            case DRINK_CAFE:
                [inst addObject:@"Select cafe"];
                [inst addObject:@"A4"];
                break;
            case HOT_COCOA:
                [inst addObject:@"Select cocoa"];
                [inst addObject:@"A4"];
                break;
            case OTHER:
                break;
        }
    }
    
    if(strong != current.strong){
        [inst addObject:@"Select strong"];
        [inst addObject:@"C2"];
    }
    
    if (drinkSize != current.drinkSize){
        
        NSString *which;
        if (current.drinkSize > drinkSize){
            // go left
            [inst addObject:@"Make smaller"];
            which = @"A5";
        } else {
            // go right
            [inst addObject:@"Make larger"];
            which = @"C5";
        }
        
        for (int i = 0; i < fabs(current.drinkSize - drinkSize); i++) {
            [inst addObject:which];
        }
    }
    return inst;
}

@end
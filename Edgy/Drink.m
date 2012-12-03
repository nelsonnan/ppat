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
@synthesize semanticName;
@synthesize drinkType;

/**
 Constructor
 @return new Drink
 **/
- (id)initWithDrink:(Type)screen AndSize:(DrinkSize)size AndStrong:(BOOL)strength AndDrinkType:(DrinkType)drink
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

/**
 * @return NSString instruction for input given a difference drink
 **/
- (NSString*) instructions:(Drink *)current
{
    NSMutableString *inst = [NSMutableString stringWithString:@""];
    if (screenType != current.screenType) {
        current.drinkSize = EIGHT;
        current.strong = NO;
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
    }
    
    if(strong != current.strong){
        [inst appendString:@"C2 "];
    }
    
    if(drinkSize != current.drinkSize) {
        NSMutableString *which = [NSMutableString stringWithString:@""];
        
        if (current.drinkSize > drinkSize){
            // go left
            [which appendString:@"A5 "];
        } else {
            // go right
            [which appendString:@"C5 "];
        }
        
        for (int i = 0; i < fabs(current.drinkSize - drinkSize); i++) {
            [inst appendString:which];
        }
    }
    // Trim the last white space and return
    return [inst stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
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
- (NSString*) colloquialInstructions
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
    NSMutableArray *inst = [NSMutableArray arrayWithCapacity:5];
    if (screenType != current.screenType) {
        current.drinkSize = EIGHT;
        current.strong = NO;
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
    
    if(strong != current.strong){
        [inst addObject:@"Select strong"];
        [inst addObject:@"C5"];
    }
    
    if (drinkSize != current.drinkSize){
        NSMutableString *which = [NSMutableString stringWithString:@""];
        
        if (current.drinkSize > drinkSize){
            // go left
            [inst addObject:@"Make smaller"];
            [which appendString:@"A5"];
        } else {
            // go right
            [inst addObject:@"Make larger"];
            [which appendString:@"C5"];
        }
        
        for (int i = 0; i < fabs(current.drinkSize - drinkSize); i++) {
            [inst addObject:which];
        }
    }
    return inst;
}

/**
 * @return semantic name of current drink
 **/
-(NSString*) semanticRepresentation{
    if (semanticName != nil){
        return semanticName;
    }
    NSMutableString *name = [NSMutableString stringWithString:@""];
    switch (screenType) {
        case COFFEE_AND_TEA:
            break;
        default:
            break;
    }
    semanticName = name;
    return name;
}

@end
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
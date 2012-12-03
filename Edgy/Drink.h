//
//  Drink.h
//  ImageProcessing
//
//  Created by User Interface Design Group on 11/28/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Type.h"
#import "DrinkSize.h"

@interface Drink : NSObject

@property Type screenType;
@property DrinkSize drinkSize;
@property BOOL strong;
@property NSString* semanticName;


- (id)initWithDrink:(Type)screen AndSize:(DrinkSize)size AndStrong:(BOOL)strength;
- (NSString*)instructions :(Drink*)current;
- (NSArray*)semanticInstructions:(Drink*) current;
- (NSString*)semanticRepresentation;
@end
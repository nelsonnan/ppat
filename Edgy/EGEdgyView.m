//
//  EGEdgyView.m
//  ImageProcessing
//
//  Created by Chris Marcellino on 8/26/10.
//  Copyright 2010 EGEdgyView. All rights reserved.
//

#import "EGEdgyView.h"

static const CGFloat buttonAlpha = 0.8;

@interface EGEdgyView ()

- (void)setControlAlpha:(CGFloat)alpha;

@end


@implementation EGEdgyView

@synthesize imageView;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor blackColor]];
        [imageView setContentScaleFactor:1.0];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [[imageView layer] setMagnificationFilter:@"nearest"];
        [self addSubview:imageView];
        
        [self setControlAlpha:1.0];
        
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [super dealloc];
}

- (void)layoutSubviews
{
    CGRect bounds = [self bounds];
    
    [imageView setFrame:bounds];
}

- (void)setControlAlpha:(CGFloat)alpha
{
}

- (void)setButtonImageTransform:(CGAffineTransform)transform animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
    
    if (animated) {
        [UIView commitAnimations];
    }
}

@end

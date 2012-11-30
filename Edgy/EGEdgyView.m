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

@synthesize imageView, captureButton;

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor blackColor]];
        [imageView setContentScaleFactor:1.0];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [[imageView layer] setMagnificationFilter:@"nearest"];
        [self addSubview:imageView];
        
        captureButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [captureButton setImage:[UIImage imageNamed:@"camera_dslr_small.png"] forState:UIControlStateNormal];
        [captureButton sizeToFit];
        [self addSubview:captureButton];
        
        [self setControlAlpha:1.0];
        
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [captureButton release];
    [super dealloc];
}

- (void)layoutSubviews
{
    CGRect bounds = [self bounds];
    
    [imageView setFrame:bounds];
    
    
    CGRect buttonFrame;
    buttonFrame.size = CGSizeMake(40.0, 40.0);
    
    buttonFrame.origin = CGPointMake(8.0, 8.0);
    
    
    buttonFrame.origin = CGPointMake(8.0, bounds.size.height - buttonFrame.size.height - 8.0);
    [captureButton setFrame:buttonFrame];
    
    buttonFrame.origin = CGPointMake(bounds.size.width - buttonFrame.size.width - 8.0, 8.0);
    
}

- (void)setControlAlpha:(CGFloat)alpha
{
    [captureButton setAlpha:alpha];
}

- (void)setButtonImageTransform:(CGAffineTransform)transform animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
    [captureButton setTransform:transform];
    
    if (animated) {
        [UIView commitAnimations];
    }
}

@end
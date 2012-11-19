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

- (void)clearFadeTimer;
- (void)fadeTimerFired;
- (void)restartFadeTimer;

@end


@implementation EGEdgyView

@synthesize imageView, torchButton, captureButton, cameraToggle, colorToggle, cannyThresholdSlider, bannerView;

- (id)initWithFrame:(CGRect)frame
{    
    if ((self = [super initWithFrame:frame])) {
        imageView = [[UIImageView alloc] init];
        [imageView setBackgroundColor:[UIColor blackColor]];
        [imageView setContentScaleFactor:1.0];
        [imageView setContentMode:UIViewContentModeScaleAspectFill];
        [[imageView layer] setMagnificationFilter:@"nearest"];
        [self addSubview:imageView];
        
        torchButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [torchButton setImage:[UIImage imageNamed:@"lightbulb_small.png"] forState:UIControlStateNormal];
        [torchButton setImage:[UIImage imageNamed:@"lightbulb_small_selected.png"] forState:UIControlStateSelected];
        [torchButton sizeToFit];
        [self addSubview:torchButton];

        captureButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [captureButton setImage:[UIImage imageNamed:@"camera_dslr_small.png"] forState:UIControlStateNormal];
        [captureButton sizeToFit];
        [self addSubview:captureButton];
        
        cameraToggle = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [cameraToggle setImage:[UIImage imageNamed:@"reload_small.png"] forState:UIControlStateNormal];
        [cameraToggle sizeToFit];
        [self addSubview:cameraToggle];

        colorToggle = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
        [colorToggle setImage:[UIImage imageNamed:@"colors_small.png"] forState:UIControlStateNormal];
        [colorToggle sizeToFit];
        [self addSubview:colorToggle];
        
        cannyThresholdSlider = [[UISlider alloc] init];
        [cannyThresholdSlider setMinimumValue:5.0];
        [cannyThresholdSlider setMaximumValue:300.0];
        [self addSubview:cannyThresholdSlider];
        
        [self setControlAlpha:0.0];
        
#if FREE_VERSION
        bannerView = [[ADBannerView alloc] init];
        [bannerView setRequiredContentSizeIdentifiers:[NSSet setWithObject:ADBannerContentSizeIdentifierPortrait]];
        [bannerView setHidden:YES];
        [self addSubview:bannerView];
#endif
    }
    return self;
}

- (void)dealloc
{
    [imageView release];
    [torchButton release];
    [captureButton release];
    [cameraToggle release];
    [colorToggle release];
    [cannyThresholdSlider release];
    [super dealloc];
}

- (void)layoutSubviews
{
    CGRect bounds = [self bounds];
    
    [imageView setFrame:bounds];
    
    CGFloat yOffset = (bannerView && ![bannerView isHidden]) ? [bannerView frame].size.height : 0.0;
    
    CGRect buttonFrame;
    buttonFrame.size = CGSizeMake(40.0, 40.0);
    
    buttonFrame.origin = CGPointMake(8.0, 8.0);
    [torchButton setFrame:buttonFrame];
    
    buttonFrame.origin = CGPointMake(8.0, bounds.size.height - buttonFrame.size.height - 8.0 - yOffset);
    [captureButton setFrame:buttonFrame];
    
    buttonFrame.origin = CGPointMake(bounds.size.width - buttonFrame.size.width - 8.0, 8.0);
    [colorToggle setFrame:buttonFrame];
    
    buttonFrame.origin = CGPointMake(CGRectGetMinX([colorToggle frame]) - buttonFrame.size.width - 8.0, 8.0);
    [cameraToggle setFrame:buttonFrame];
    
    // Position the slider at the bottom center
    CGRect sliderFrame = CGRectMake(bounds.size.width / 4, bounds.size.height - 35.0 - yOffset, bounds.size.width / 2, 30.0);
    [cannyThresholdSlider setFrame:sliderFrame];

#if FREE_VERSION
    CGRect bannerFrame;
    bannerFrame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:[bannerView currentContentSizeIdentifier]];
    bannerFrame.origin = CGPointMake(0.0, bounds.size.height - bannerFrame.size.height);
    [bannerView setFrame:bannerFrame];
#endif
}

- (void)setControlAlpha:(CGFloat)alpha
{
    [torchButton setAlpha:alpha];
    [captureButton setAlpha:alpha];
    [cameraToggle setAlpha:alpha];
    [colorToggle setAlpha:alpha];
    [cannyThresholdSlider setAlpha:alpha];
}

- (void)setButtonImageTransform:(CGAffineTransform)transform animated:(BOOL)animated
{
    if (animated) {
        [UIView beginAnimations:nil context:NULL];
    }
    [torchButton setTransform:transform];
    [captureButton setTransform:transform];
    [cameraToggle setTransform:transform];
    [colorToggle setTransform:transform];
    if (animated) {
        [UIView commitAnimations];
    }
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self clearFadeTimer];
    
    CGFloat oldAlpha = [[self torchButton] alpha];
    if (oldAlpha == 0.0) {
        [self setControlAlpha:buttonAlpha];
    } else {
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:0.3];
        [self setControlAlpha:0.0];
        [UIView commitAnimations];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self restartFadeTimer];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self restartFadeTimer];
}

- (void)clearFadeTimer
{
    [fadeTimer invalidate];
    [fadeTimer autorelease];
    fadeTimer = nil;
}

- (void)restartFadeTimer
{
    [self clearFadeTimer];
    fadeTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(fadeTimerFired) userInfo:nil repeats:NO] retain];    
}

- (void)fadeTimerFired
{
    [fadeTimer autorelease];
    fadeTimer = nil;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self setControlAlpha:0.0];
    [UIView commitAnimations];
}

@end

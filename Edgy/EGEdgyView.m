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

@synthesize imageView, captureButton, bannerView;

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
    [captureButton release];
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
    
    
    buttonFrame.origin = CGPointMake(8.0, bounds.size.height - buttonFrame.size.height - 8.0 - yOffset);
    [captureButton setFrame:buttonFrame];
    
    buttonFrame.origin = CGPointMake(bounds.size.width - buttonFrame.size.width - 8.0, 8.0);
    
    
    
#if FREE_VERSION
    CGRect bannerFrame;
    bannerFrame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:[bannerView currentContentSizeIdentifier]];
    bannerFrame.origin = CGPointMake(0.0, bounds.size.height - bannerFrame.size.height);
    [bannerView setFrame:bannerFrame];
#endif
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

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self clearFadeTimer];
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    [self setControlAlpha:1.0];
    [UIView commitAnimations];
    
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
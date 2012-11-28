//
//  EGEdgyView.h
//  ImageProcessing
//
//  Created by Chris Marcellino on 8/26/10.
//  Copyright 2010 EGEdgyView. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <iAd/iAd.h>


@interface EGEdgyView : UIView {
    UIImageView *imageView;
    UIButton *captureButton;
    ADBannerView *bannerView;
    
    NSTimer *fadeTimer;
}

@property(nonatomic, readonly) UIImageView *imageView;
@property(nonatomic, readonly) UIButton *captureButton;
@property(nonatomic, readonly) ADBannerView *bannerView;

- (void)setButtonImageTransform:(CGAffineTransform)transform animated:(BOOL)animated;

@end

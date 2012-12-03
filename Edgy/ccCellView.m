//
//  ccCellView.m
//  ImageProcessing
//
//  Created by Marcus Lowe on 11/30/12.
//  Copyright (c) 2012 Lindsay. All rights reserved.
//

#import "ccCellView.h"

@implementation ccCellView

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.restorationIdentifier = @"cvCell";
        self.backgroundColor = [UIColor clearColor];
        self.autoresizingMask = UIViewAutoresizingNone;
        
        CGFloat borderWidth = 6.0f;
        UIView *bgView = [[UIView alloc] initWithFrame:frame];
        self.selectedBackgroundView = bgView;
        
        CGRect myContentRect = CGRectInset(self.contentView.bounds, borderWidth, borderWidth);
        
        UIView *myContentView = [[UIView alloc] initWithFrame:myContentRect];
        myContentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:myContentView];
        
    }
    return self;
}

@end

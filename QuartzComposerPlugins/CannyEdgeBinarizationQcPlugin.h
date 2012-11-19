//
//  CannyEdgeBinarizationQcPlugin.h
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import <Quartz/Quartz.h>


@interface CannyEdgeBinarizationQcPlugin : QCPlugIn

@property(assign) id<QCPlugInInputImageSource> inputOriginalImage;
@property(assign) id<QCPlugInInputImageSource> inputCannyEdgeImage;
@property NSUInteger inputLargerDimensionMinimum;
@property NSUInteger inputMaxChildrenCount;
@property BOOL inputDrawRects;

@property(assign) id<QCPlugInOutputImageProvider> outputImage;
@property(assign) id<QCPlugInOutputImageProvider> outputAllContours;

@end

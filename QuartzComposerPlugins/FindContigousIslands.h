//
//  FindContigousIslands.h
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import <Quartz/Quartz.h>


@interface FindContigousIslands : QCPlugIn

@property(assign) id<QCPlugInInputImageSource> inputImage;
@property NSUInteger inputImageIndex;
@property NSUInteger inputBorderTolerance;
@property(assign) id<QCPlugInOutputImageProvider> outputImage;
@property(assign) id<QCPlugInOutputImageProvider> outputDebugImage;

@end

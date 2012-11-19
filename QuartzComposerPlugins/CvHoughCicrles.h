//
//  CvHoughCicrles.h
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import <Quartz/Quartz.h>


@interface CvHoughCircles : QCPlugIn

@property(assign) id<QCPlugInInputImageSource> inputImage;
@property double inputDp;
@property double inputCannyParam;
@property double inputAccumParam;
@property double inputMinRadius;
@property double inputMaxRadius;
@property(assign) id<QCPlugInOutputImageProvider> outputImage;

@end

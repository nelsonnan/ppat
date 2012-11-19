//
//  CvYUVSplitterQcPlugin.h
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import <Quartz/Quartz.h>


@interface CvYUVSplitterQcPlugin : QCPlugIn

@property(assign) id<QCPlugInInputImageSource> inputImage;
@property(assign) id<QCPlugInOutputImageProvider> outputImageY;
@property(assign) id<QCPlugInOutputImageProvider> outputImageU;
@property(assign) id<QCPlugInOutputImageProvider> outputImageV;

@end

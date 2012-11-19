//
//  CvHoughCicrles.mm
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import "CvHoughCicrles.h"
#import "opencv2/opencv.hpp"
#import "OpenCVOutputImage.h"
#import <QuartzCore/QuartzCore.h>

@implementation CvHoughCircles

@dynamic inputImage, inputDp, inputCannyParam, inputAccumParam, inputMinRadius, inputMaxRadius, outputImage;

+ (NSDictionary *)attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"cvHoughCircles", QCPlugInAttributeNameKey,
            @"Finds and colors circles in the image using cvHoughCircles().", QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    NSDictionary *dictionary = nil;
    
    if ([key isEqual:@"inputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Input", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"inputDp"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Accumulator Inverse Resolution", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:1], QCPortAttributeMinimumValueKey,
                      [NSNumber numberWithUnsignedInteger:5], QCPortAttributeMaximumValueKey,
                      [NSNumber numberWithUnsignedInteger:1], QCPortAttributeDefaultValueKey,
                      nil];
    } else if ([key isEqual:@"inputCannyParam"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Canny Param", QCPortAttributeNameKey,
                        [NSNumber numberWithUnsignedInteger:30], QCPortAttributeMinimumValueKey,
                      [NSNumber numberWithUnsignedInteger:200], QCPortAttributeMaximumValueKey,
                      [NSNumber numberWithUnsignedInteger:100], QCPortAttributeDefaultValueKey,
                      nil];
    } else if ([key isEqual:@"inputAccumParam"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Accumulator Threshold", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:1], QCPortAttributeMinimumValueKey,
                      [NSNumber numberWithUnsignedInteger:500], QCPortAttributeMaximumValueKey,
                      [NSNumber numberWithUnsignedInteger:200], QCPortAttributeDefaultValueKey,
                      nil];
    } else if ([key isEqual:@"inputMinRadius"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Minimum Radius", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:0], QCPortAttributeMinimumValueKey,
                      [NSNumber numberWithUnsignedInteger:400], QCPortAttributeMaximumValueKey,
                      [NSNumber numberWithUnsignedInteger:50], QCPortAttributeDefaultValueKey,
                      nil];
    } else if ([key isEqual:@"inputMaxRadius"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Maximum Radius", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:0], QCPortAttributeMinimumValueKey,
                      [NSNumber numberWithUnsignedInteger:1000], QCPortAttributeMaximumValueKey,
                      [NSNumber numberWithUnsignedInteger:500], QCPortAttributeDefaultValueKey,
                      nil];
    } else if ([key isEqual:@"outputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Output", QCPortAttributeNameKey, nil];
    }
    
    return dictionary;
}

+ (NSArray *)sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputImage", @"inputDp", @"inputCannyParam", @"inputAccumParam",
            @"inputMinRadius", @"inputMaxRadius", @"outputImage", nil];
}

+ (QCPlugInExecutionMode)executionMode
{
	return kQCPlugInExecutionModeProcessor;
}

+ (QCPlugInTimeMode)timeMode
{
	return kQCPlugInTimeModeNone;
}

- (BOOL)execute:(id<QCPlugInContext>)context atTime:(NSTimeInterval)time withArguments:(NSDictionary *)arguments
{
    id<QCPlugInInputImageSource> inputImage = [self inputImage];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    BOOL success = [inputImage lockBufferRepresentationWithPixelFormat:QCPlugInPixelFormatBGRA8
                                                            colorSpace:colorSpace
                                                             forBounds:[inputImage imageBounds]];
    if (success) {
        // Create the OpenCV BGRA image
        IplImage *iplImage = cvCreateImageHeader(cvSize([inputImage bufferPixelsWide], [inputImage bufferPixelsHigh]),
                                                 IPL_DEPTH_8U,
                                                 4);
        iplImage->widthStep = [inputImage bufferBytesPerRow];
        iplImage->imageSize = [inputImage bufferBytesPerRow] * [inputImage bufferPixelsHigh];
        iplImage->imageData = iplImage->imageDataOrigin = (char *)[inputImage bufferBaseAddress];
        
        // Convert to grayscale
        IplImage *grayInputImage = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 1);
        cvCvtColor(iplImage, grayInputImage, CV_BGRA2GRAY);
        
        IplImage *result = cvCloneImage(iplImage);

        CvMemStorage* storage = cvCreateMemStorage();
        CvSeq* seq = cvHoughCircles(grayInputImage,
                                    storage,
                                    CV_HOUGH_GRADIENT,
                                    2,
                                    2 * [self inputMinRadius],
                                    [self inputCannyParam],
                                    [self inputAccumParam],
                                    [self inputMinRadius],
                                    [self inputMaxRadius]);
        
        vector<cv::Vec3f> circles;
        cv::Seq<cv::Vec3f>(seq).copyTo(circles);
        cvReleaseMemStorage(&storage);
        
        for (size_t i = 0; i < circles.size(); i++) {
            cv::Point center(cvRound(circles[i][0]), cvRound(circles[i][1]));
            int radius = cvRound(circles[i][2]);
            // Draw the circle center
            cvCircle(result, center, 3, CV_RGB(0, 255, 0), -1, 8, 0);
            // Draw the circle outline
            cvCircle(result, center, radius, CV_RGB(0, 0, 255), 3, 8, 0);
        }
        
        [self setOutputImage:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:result]];
        
        cvReleaseImageHeader(&iplImage);
        cvReleaseImage(&grayInputImage);
        [inputImage unlockBufferRepresentation];
    }
    CGColorSpaceRelease(colorSpace);
    
	return success;
}

@end
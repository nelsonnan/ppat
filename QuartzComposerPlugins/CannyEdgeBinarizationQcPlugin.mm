//
//  CannyEdgeBinarizationQcPlugin.m
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import "CannyEdgeBinarizationQcPlugin.h"
#import "opencv2/opencv.hpp"
#import "OpenCVOutputImage.h"
#import "Binarization.hpp"

@implementation CannyEdgeBinarizationQcPlugin

@dynamic inputOriginalImage, inputCannyEdgeImage, inputLargerDimensionMinimum, inputMaxChildrenCount, inputDrawRects, outputImage, outputAllContours;

+ (NSDictionary *)attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"Canny Edge Binarization", QCPlugInAttributeNameKey,
            @"Binarizes a bicolor Canny Edge image using the algorithm from "
            "\"Font and Background Color Independent Text Binarization\","
            "T Kasar, J Kumar and A G Ramakrishnan, 2007.", QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    NSDictionary  *dictionary = nil;
    
    if ([key isEqual:@"inputOriginalImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Input Original Image", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"inputCannyEdgeImage"]) {
            dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Input Canny Edge Image", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"inputLargerDimensionMinimum"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Dimensional min (pixels)", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:30], QCPortAttributeMaximumValueKey,
                      [NSNumber numberWithUnsignedInteger:8], QCPortAttributeDefaultValueKey,
                      nil];
    } else if ([key isEqual:@"inputMaxChildrenCount"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Max children", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:10], QCPortAttributeMaximumValueKey,
                      [NSNumber numberWithUnsignedInteger:4], QCPortAttributeDefaultValueKey,
                      nil];
    } else if ([key isEqual:@"inputDrawRects"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Draw bounding boxes (debug)", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"outputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Output Image", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"outputAllContours"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"All contours (debug)", QCPortAttributeNameKey, nil];
    }
    
    return dictionary;
}

+ (NSArray *)sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputOriginalImage", @"inputCannyEdgeImage", @"inputLargerDimensionMinimum",
            @"inputMaxChildrenCount", @"inputDrawRects", @"outputImage", @"outputAllContours", nil];
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
    id<QCPlugInInputImageSource> inputOriginalImage = [self inputOriginalImage];
    id<QCPlugInInputImageSource> inputCannyEdgeImage = [self inputCannyEdgeImage];
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateWithName(kCGColorSpaceGenericRGB);
    BOOL success = [inputOriginalImage lockBufferRepresentationWithPixelFormat:QCPlugInPixelFormatBGRA8
                                                                    colorSpace:colorSpace
                                                                     forBounds:[inputOriginalImage imageBounds]];
    if (success) {
        // Create the OpenCV images
        IplImage *iplOriginalImage = cvCreateImageHeader(cvSize([inputOriginalImage bufferPixelsWide], [inputOriginalImage bufferPixelsHigh]),
                                                         IPL_DEPTH_8U,
                                                         4);
        iplOriginalImage->widthStep = [inputOriginalImage bufferBytesPerRow];
        iplOriginalImage->imageSize = [inputOriginalImage bufferBytesPerRow] * [inputOriginalImage bufferPixelsHigh];
        iplOriginalImage->imageData = iplOriginalImage->imageDataOrigin = (char *)[inputOriginalImage bufferBaseAddress];
        
        BOOL success = [inputCannyEdgeImage lockBufferRepresentationWithPixelFormat:QCPlugInPixelFormatBGRA8
                                                                         colorSpace:colorSpace
                                                                          forBounds:[inputCannyEdgeImage imageBounds]];
        if (success) {
            IplImage *iplCannyEdgeImage = cvCreateImageHeader(cvSize([inputCannyEdgeImage bufferPixelsWide], [inputCannyEdgeImage bufferPixelsHigh]),
                                                              IPL_DEPTH_8U,
                                                              4);
            iplCannyEdgeImage->widthStep = [inputCannyEdgeImage bufferBytesPerRow];
            iplCannyEdgeImage->imageSize = [inputCannyEdgeImage bufferBytesPerRow] * [inputCannyEdgeImage bufferPixelsHigh];
            iplCannyEdgeImage->imageData = iplCannyEdgeImage->imageDataOrigin = (char *)[inputCannyEdgeImage bufferBaseAddress];
            
            IplImage *grayCannyEdgeImage = cvCreateImage(cvGetSize(iplCannyEdgeImage), IPL_DEPTH_8U, 1);
            cvCvtColor(iplCannyEdgeImage, grayCannyEdgeImage, CV_BGRA2GRAY);
            
            // Perform the operation
            IplImage *outputAllContours = cvCreateImage(cvGetSize(iplOriginalImage), IPL_DEPTH_8U, 3);
            
            CvContour* firstContour = NULL;
            CvMemStorage* storage = createStorageWithContours(grayCannyEdgeImage, &firstContour, outputAllContours, [self inputDrawRects]);
            IplImage *result = binarizeContours(iplOriginalImage,
                                                firstContour,
                                                [self inputLargerDimensionMinimum],
                                                [self inputMaxChildrenCount],
                                                [self inputDrawRects]);
            cvReleaseMemStorage(&storage);
            
            [self setOutputAllContours:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:outputAllContours]];
            [self setOutputImage:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:result]];
            
            cvReleaseImage(&grayCannyEdgeImage);
            cvReleaseImageHeader(&iplCannyEdgeImage);
            [inputCannyEdgeImage unlockBufferRepresentation];
        }
        
        cvReleaseImageHeader(&iplOriginalImage);
        [inputOriginalImage unlockBufferRepresentation];
    }
    CGColorSpaceRelease(colorSpace);
    
	return success;
}

@end
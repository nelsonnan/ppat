//
//  CvYUVSplitterQcPlugin.mm
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import "CvYUVSplitterQcPlugin.h"
#import "opencv2/opencv.hpp"
#import "OpenCVOutputImage.h"

@implementation CvYUVSplitterQcPlugin

@dynamic inputImage, outputImageY, outputImageU, outputImageV;

+ (NSDictionary *)attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"YUV Splitter", QCPlugInAttributeNameKey,
            @"Splits an image into Y, U and V channels using cvCvtColor(), cvSetImageCOI() and cvCopy()", QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    NSDictionary  *dictionary = nil;
    
    if ([key isEqual:@"inputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Input", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"outputImageY"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Output Y", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"outputImageU"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Output U", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"outputImageV"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Output V", QCPortAttributeNameKey, nil];
    }
    
    return dictionary;
}

+ (NSArray *)sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputImage", @"outputImageY", @"outputImageU", @"outputImageV", nil];
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
        // Create the OpenCV image
        IplImage *iplInputImage = cvCreateImageHeader(cvSize([inputImage bufferPixelsWide], [inputImage bufferPixelsHigh]),
                                                      IPL_DEPTH_8U,
                                                      4);
        iplInputImage->widthStep = [inputImage bufferBytesPerRow];
        iplInputImage->imageSize = [inputImage bufferBytesPerRow] * [inputImage bufferPixelsHigh];
        iplInputImage->imageData = iplInputImage->imageDataOrigin = (char *)[inputImage bufferBaseAddress];
        
        // Convert the image to YUV
        IplImage* hsvImage = cvCreateImage(cvGetSize(iplInputImage), IPL_DEPTH_8U, 3);
        cvCvtColor(iplInputImage, hsvImage, CV_BGR2YUV);
        
        // Perform the operation
        IplImage* channelImages[3];
        for (int i = 0; i < 3; i++) {
            channelImages[i] = cvCreateImage(cvGetSize(hsvImage), hsvImage->depth, 1);
            cvSetImageCOI(hsvImage, i + 1);
            cvCopy(hsvImage, channelImages[i]);
            cvResetImageROI(hsvImage);
        }
        
        [self setOutputImageY:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:channelImages[0]]];
        [self setOutputImageU:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:channelImages[1]]];
        [self setOutputImageV:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:channelImages[2]]];
        
        cvReleaseImage(&hsvImage);
        cvReleaseImageHeader(&iplInputImage);
        [inputImage unlockBufferRepresentation];
    }
    CGColorSpaceRelease(colorSpace);
		
	return success;
}

@end
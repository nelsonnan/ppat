//
//  KasarBinarizationQcPlugin.m
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import "KasarBinarizationQcPlugin.h"
#import "opencv2/opencv.hpp"
#import "OpenCVOutputImage.h"
#import "Binarization.hpp"

@implementation KasarBinarizationQcPlugin

@dynamic inputImage, outputImage;

+ (NSDictionary *)attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"Kasar, Jumar, Ramakrishnan Binarization", QCPlugInAttributeNameKey,
            @"Binarizes an RGB(A) image using the algorithm from "
            "\"Font and Background Color Independent Text Binarization\","
            "T Kasar, J Kumar and A G Ramakrishnan, 2007.", QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    NSDictionary  *dictionary = nil;
    
    if ([key isEqual:@"inputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Input", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"outputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Output", QCPortAttributeNameKey, nil];
    }
    
    return dictionary;
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
        
        // Perform the operation
        IplImage *result = createBinarizedImage(iplImage);
        [self setOutputImage:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:result]];
        
        cvReleaseImageHeader(&iplImage);
        [inputImage unlockBufferRepresentation];
    }
    CGColorSpaceRelease(colorSpace);
    
	return success;
}

@end
//
//  FindContigousIslands.m
//  ImageProcessing
//
//  Created by Chris Marcellino on 1/4/11.
//  Copyright 2011 Chris Marcellino. All rights reserved.
//

#import "FindContigousIslands.h"
#import "opencv2/opencv.hpp"
#import "OpenCVOutputImage.h"
#import "Binarization.hpp"

@implementation FindContigousIslands

@dynamic inputImage, inputImageIndex, inputBorderTolerance, outputImage, outputDebugImage;

+ (NSDictionary *)attributes
{
	return [NSDictionary dictionaryWithObjectsAndKeys:@"Find Contiguous Islands", QCPlugInAttributeNameKey,
            @"Finds contiguous subimage islands of binarized images using their contour bounding boxes.", QCPlugInAttributeDescriptionKey, nil];
}

+ (NSDictionary *)attributesForPropertyPortWithKey:(NSString *)key
{
    NSDictionary  *dictionary = nil;
    
    if ([key isEqual:@"inputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Binzarized Input", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"inputImageIndex"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Index", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:50], QCPortAttributeMaximumValueKey,
                      nil];
    } else if ([key isEqual:@"inputBorderTolerance"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Border Tolerance", QCPortAttributeNameKey,
                      [NSNumber numberWithUnsignedInteger:30], QCPortAttributeMaximumValueKey,
                      nil];
    } else if ([key isEqual:@"outputImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Output", QCPortAttributeNameKey, nil];
    } else if ([key isEqual:@"outputDebugImage"]) {
        dictionary = [NSDictionary dictionaryWithObjectsAndKeys:@"Debug Output", QCPortAttributeNameKey, nil];
    }
    
    return dictionary;
}

+ (NSArray *)sortedPropertyPortKeys
{
    return [NSArray arrayWithObjects:@"inputImage", @"inputImageIndex", @"inputBorderTolerance", @"outputImage", @"outputDebugImage", nil];
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
        
        // Invert the binarized image so that contours are positive valued
        IplImage *invertedImage = cvCreateImage(cvGetSize(grayInputImage), IPL_DEPTH_8U, 1);
        cvNot(grayInputImage, invertedImage);
        
        // Perform the operation
        CvContour* firstContour = NULL;
        CvMemStorage* storage = createStorageWithContours(invertedImage, &firstContour);    // modifies invertedImage
        std::vector<CvRect> rects = findContigousIslands(firstContour, [self inputBorderTolerance], [self inputBorderTolerance] * 2);
        
        if (rects.size() > 0) {
            NSUInteger resultIndex = MIN([self inputImageIndex], rects.size() - 1);
            cvSetImageROI(iplImage, rects[resultIndex]);
            IplImage* result = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 4);
            cvCopy(iplImage, result);
            cvResetImageROI(iplImage);    
            
            [self setOutputImage:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:result]];
        } else {
            success = NO;
        }
        
        IplImage *debugImage = cvCreateImage(cvGetSize(iplImage), IPL_DEPTH_8U, 3);
        cvCvtColor(iplImage, debugImage, CV_BGRA2BGR);
        // Draw on the debug image
        for (size_t i = 0; i < rects.size(); i++) {
            CvRect rect = rects[i];
            cvRectangle(debugImage,
                        cvPoint(rect.x, rect.y),
                        cvPoint(rect.x + rect.width, rect.y + rect.height),
                        CV_RGB(0, 0, 255));
        }
        [self setOutputDebugImage:[OpenCVOutputImage outputImageWithIplImageAssumingOwnership:debugImage]];
        
        cvReleaseMemStorage(&storage);
        cvReleaseImageHeader(&iplImage);
        cvReleaseImage(&grayInputImage);
        cvReleaseImage(&invertedImage);
        [inputImage unlockBufferRepresentation];
    }
    CGColorSpaceRelease(colorSpace);
    
	return success;
}

@end
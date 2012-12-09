//
//  EGCaptureController.m
//  ImageProcessing
//
//  Created by Chris Marcellino on 8/26/10.
//  Copyright 2010 Chris Marcellino. All rights reserved.
//

#import "EGCaptureController.h"
#import <AVFoundation/AVFoundation.h>
#import <QuartzCore/QuartzCore.h>
#import "SHK.h"
#import "opencv2/opencv.hpp"
#import "EGEdgyView.h"
#import "Drink.h"
#import "UIImage-OpenCVExtensions.h"
#import "Binarization.hpp"        // for static inlines
#import "ImageOrientationAccelerometer.h"


@interface EGCaptureController ()

- (void)startRunning;
- (void)stopRunning;
- (void)updateConfiguration;
- (void)orientationDidChange;

- (void)torchToggled:(id)sender;
- (void)captureImage:(id)sender;
- (NSString*) findBestFile:(NSDictionary*)templates :(IplImage*)capturedImage :(CvRect)region;

@end

@interface EGSHKActionSheet : SHKActionSheet {
    void (^dismissHandler)(void);
}

- (void)setEGDismissHandler:(void (^)(void))handler;

@end

@implementation EGCaptureController

@synthesize timer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        sampleProcessingQueue = dispatch_queue_create("sample processing", NULL);
        // Set up the session and output
#if TARGET_OS_EMBEDDED
        session = [[AVCaptureSession alloc] init];
        
        captureVideoDataOuput = [[AVCaptureVideoDataOutput alloc] init];
        [captureVideoDataOuput setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self queue:sampleProcessingQueue];

        // Fall back to BGRA32
        NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                             forKey:(id)kCVPixelBufferPixelFormatTypeKey];
        [captureVideoDataOuput setVideoSettings:settings];

        
        [session addOutput:captureVideoDataOuput];
#endif
        [self setWantsFullScreenLayout:YES];
        [self performSelector:@selector(captureImage:) withObject:self afterDelay:5.0 ];
        
    }
    return self;
}

- (void)loadView
{
    // Create the preview layer and view
    EGEdgyView *view = [[EGEdgyView alloc] initWithFrame:CGRectZero];
    [self setView:view];
    [view release];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Monitor for orientation updates
    [[ImageOrientationAccelerometer sharedInstance] beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(orientationDidChange) name:DeviceOrientationDidChangeNotification object:nil];
    
    // Listen for app relaunch
    [defaultCenter addObserver:self selector:@selector(stopRunning) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(startRunning) name:UIApplicationDidBecomeActiveNotification object:nil];
    
    // Listen for device updates
    [defaultCenter addObserver:self selector:@selector(updateConfiguration) name:AVCaptureDeviceWasConnectedNotification object:nil];
    [defaultCenter addObserver:self selector:@selector(updateConfiguration) name:AVCaptureDeviceWasDisconnectedNotification object:nil];
    
    [self startRunning];
    [self orientationDidChange];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self stopRunning];
    
    [[ImageOrientationAccelerometer sharedInstance] endGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter removeObserver:self name:DeviceOrientationDidChangeNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    [defaultCenter removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
    [defaultCenter removeObserver:self name:AVCaptureDeviceWasConnectedNotification object:nil];
    [defaultCenter removeObserver:self name:AVCaptureDeviceWasDisconnectedNotification object:nil];
}

- (void)startRunning
{
    [self updateConfiguration];
    [self performSelector:@selector(updateConfiguration) withObject:nil afterDelay:2.0];    // work around OS torch bugs
#if TARGET_OS_EMBEDDED
    [session startRunning];
#endif
}

- (void)stopRunning
{
#if TARGET_OS_EMBEDDED
    [session stopRunning];
#endif
}

- (void)updateConfiguration
{
    EGEdgyView *view = (EGEdgyView *)[self view];
    
#if TARGET_OS_EMBEDDED
    // Create the session
    [session beginConfiguration];
    
    // Choose the proper device and hide the device button if there is 0 or 1 devices
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    if (!currentDevice || ![[devices objectAtIndex:0] isEqual:currentDevice]) {
        [currentDevice release];
        currentDevice = [[devices objectAtIndex:0] retain];
        
        // Create the input and add it to the session
        if (input) {
            [session removeInput:input];
            [input release];
        }
        NSError *error = nil;
        input = [[AVCaptureDeviceInput alloc] initWithDevice:currentDevice error:&error];
        NSAssert1(input, @"no AVCaptureDeviceInput available: %@", error);
        [session addInput:input];
    }
    
    // Set the configuration
    if ([session canSetSessionPreset:AVCaptureSessionPresetMedium]) {
        [session setSessionPreset:AVCaptureSessionPresetMedium];
    }
    
    [currentDevice lockForConfiguration:nil];
    BOOL hasTorch = [currentDevice hasTorch];
    if (hasTorch) {
        [currentDevice setTorchMode:AVCaptureTorchModeOff];     // work around OS bugs
        [currentDevice setTorchMode:torchOn ? AVCaptureTorchModeOn : AVCaptureTorchModeOff];
    }
    [currentDevice unlockForConfiguration];
    
    // Ensure the image view is rotated properly
    BOOL front = [currentDevice position] == AVCaptureDevicePositionFront;
    CGAffineTransform transform = CGAffineTransformMakeRotation(front ? -M_PI_2 : M_PI_2);
    if (front) {
        transform = CGAffineTransformScale(transform, -1.0, 1.0);
    }
    [[view imageView] setTransform:transform];
    [view setNeedsLayout];
    
    [session commitConfiguration];
#endif
    
    
    // Update the image orientation to include the mirroring value as appropriate
    [self orientationDidChange];
}

- (void)orientationDidChange
{
    UIDeviceOrientation orientation = [[ImageOrientationAccelerometer sharedInstance] deviceOrientation];
    
    if (UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
        CGFloat buttonRotation;
        UIInterfaceOrientation interfaceOrientation;
        // Store the last unambigous orientation if not in capture mode
        switch (orientation) {
            default:
            case UIDeviceOrientationPortrait:
                buttonRotation = 0.0;
                imageOrientation = UIImageOrientationRight;
                interfaceOrientation = UIInterfaceOrientationPortrait;
                break;
            case UIDeviceOrientationPortraitUpsideDown:
                buttonRotation = M_PI;
                imageOrientation = UIImageOrientationLeft;
                interfaceOrientation = UIInterfaceOrientationPortraitUpsideDown;
                break;
            case UIDeviceOrientationLandscapeLeft:
                buttonRotation = M_PI_2;
                imageOrientation = UIImageOrientationUp;
                interfaceOrientation = UIInterfaceOrientationLandscapeLeft;
                break;
            case UIDeviceOrientationLandscapeRight:
                buttonRotation = -M_PI_2;
                imageOrientation = UIImageOrientationDown;
                interfaceOrientation = UIInterfaceOrientationLandscapeRight;
                break;
        }
        
        // Adjust button orientations
        [(EGEdgyView *)[self view] setButtonImageTransform:CGAffineTransformMakeRotation(buttonRotation) animated:YES];
        
        // Adjust the (hidden) status bar orientation so that sheets and modal view controllers appear in the proper orientation
        // and so touch hystereses are more accurate
        [[UIApplication sharedApplication] setStatusBarOrientation:interfaceOrientation];
    }
}

- (void)torchToggled:(id)sender
{
    torchOn = !torchOn;
    [self updateConfiguration];
}

- (void)captureImage:(id)sender
{
    EGEdgyView *view = (EGEdgyView *)[self view];
    
    // Prevent redundant button pressing
    pauseForCapture = YES;
    [view setUserInteractionEnabled:NO];
    
    // Get the current image and add rotation metadata, rotating the raw pixels if necessary
    UIImage *image = [[view imageView] image];
    if (!image) {
        return;
    }
    
    image = [UIImage imageWithCGImage:[image CGImage] scale:1.0 orientation:imageOrientation];
    IplImage *pixels = [image createIplImageWithNumberOfChannels:3];
#if TARGET_OS_EMBEDDED
    if ([currentDevice position] == AVCaptureDevicePositionFront) {
        cvFlip(pixels, NULL, (imageOrientation == UIImageOrientationUp || imageOrientation == UIImageOrientationDown) ? 0 : 1);        // flip vertically
    }
#endif
    
    NSMutableDictionary *size_templates = [NSMutableDictionary dictionary];
    [size_templates setObject: [NSNumber numberWithInt: FOUR] forKey:@"4oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: SIX] forKey:@"6oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: EIGHT] forKey:@"8oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: TEN] forKey:@"10oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: TWELVE] forKey:@"12oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: FOURTEEN] forKey:@"14oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: SIXTEEN] forKey:@"16oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: EIGHTEEN] forKey:@"18oz.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: SIX] forKey:@"6ozIced.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: EIGHT] forKey:@"8ozIced.jpg.png" ];
    [size_templates setObject: [NSNumber numberWithInt: TEN] forKey:@"10ozIced.jpg.png" ];
    
    DrinkSize best_size = (DrinkSize)[[size_templates objectForKey:[self findBestFile:size_templates :pixels :cvRect(0,275,pixels->width, pixels->height - 275)]] intValue];
    
    NSMutableDictionary *type_templates = [NSMutableDictionary dictionary];
    [type_templates setObject: [NSNumber numberWithInt:COFFEE_AND_TEA] forKey:@"coffeeAndTea.jpg.png"];
    [type_templates setObject: [NSNumber numberWithInt:CAFE] forKey:@"cafe.jpg.png"];
    [type_templates setObject: [NSNumber numberWithInt:ICE] forKey:@"brewOverIce.jpg.png"];
    
    Type best_type = (Type)[[type_templates objectForKey:[self findBestFile:type_templates :pixels :cvRect(0,0,pixels->width, 120)]] intValue];
    
    NSMutableDictionary *drink_type_templates = [NSMutableDictionary dictionary];
    [drink_type_templates setObject: [NSNumber numberWithInt:COFFEE] forKey:@"coffee.jpg.png"];
    [drink_type_templates setObject: [NSNumber numberWithInt:COFFEE] forKey:@"coffeeStrong.jpg.png"];
    [drink_type_templates setObject: [NSNumber numberWithInt:TEA] forKey:@"tea.jpg.png"];
    [drink_type_templates setObject: [NSNumber numberWithInt:HOT_COCOA] forKey:@"cocoa.jpg.png"];
    [drink_type_templates setObject: [NSNumber numberWithInt:COFFEE] forKey:@"icedCoffee.jpg.png"];
    [drink_type_templates setObject: [NSNumber numberWithInt:COFFEE] forKey:@"icedCoffeeStrong.jpg.png"];
    [drink_type_templates setObject: [NSNumber numberWithInt:TEA] forKey:@"icedTea.jpg.png"];
    [drink_type_templates setObject: [NSNumber numberWithInt:DRINK_CAFE] forKey:@"icedCafe.jpg.png"];
    
    NSString *best_drink_type_filename = [self findBestFile:drink_type_templates :pixels :cvRect(0,100,pixels->width,175)];
    
    // TODO(mglowe): perform additional checks to confirm that specific pictures were only matched with appropriate screens (make sure all drinks are real).

    DrinkType best_drink_type = (DrinkType)[[drink_type_templates objectForKey:best_drink_type_filename] intValue];
    BOOL isStrong = [best_drink_type_filename isEqualToString:@"coffeeStrong.jpg.png"] || [best_drink_type_filename isEqualToString:@"icedCoffeeStrong.jpg.png"];
    
    Drink *current_drink = [[Drink alloc] initWithDrinkType:(Type)best_type AndSize:(DrinkSize)best_size AndStrong:isStrong AndDrinkType:best_drink_type];
    // Send the current drink to the other view
    NSDictionary *dict = [NSDictionary dictionaryWithObject: current_drink forKey:@"current_drink"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewCurrentDrink" object:self userInfo:dict];
    
    cvReleaseImage(&pixels);
    // Uncomment the line below to save the photo to phone's album. Using these images, transfer them over to the templates_png folder to use as template matchers.
    // NOTE: At time of this writing images were being saved as jpg's. Used command line tool "convert" from Imagick to make PNGs.
    //UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    [view removeFromSuperview];
}

- (NSString*) findBestFile:(NSDictionary*)templates :(IplImage*)capturedImage :(CvRect)region
{

	IplImage *template_image;
    IplImage *imgResult;

    
	double best_val = DBL_MAX;
    int best;
    
    NSArray *keys = [templates allKeys];
    NSString *bestFileName = @"";
    
    cvSetImageROI(capturedImage, region);
    
	for (NSUInteger i = 0; i < [templates count]; i++) {
		template_image = [[UIImage imageNamed:[keys objectAtIndex:i]] createIplImageWithNumberOfChannels:3];
		CvSize templateSize = cvGetSize(template_image);
		
		CvSize resultSize = cvSize(abs(region.width - templateSize.width) + 1, abs(region.height - templateSize.height) + 1);
		imgResult = cvCreateImage(resultSize, IPL_DEPTH_32F, 1);

		cvMatchTemplate(capturedImage, template_image, imgResult, CV_TM_SQDIFF);
		double min_val;
		double max_val;
		cvMinMaxLoc(imgResult, &min_val, &max_val);
		if (min_val <= best_val) {
            bestFileName = [keys objectAtIndex:i];
			best = [[templates valueForKey:bestFileName] intValue];
			best_val = min_val;
		}
	}
    NSLog(@"BEST FILE: %@",bestFileName);
    
    cvReleaseImage(&template_image);
    cvReleaseImage(&imgResult);
    
    return bestFileName;
}



#if TARGET_OS_EMBEDDED
// Called on the capture dispatch queue
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (pauseForCapture) {
        return;
    }
    
    
    // Send the image data to the main thread for display. Block so we aren't drawing while processing.
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (!pauseForCapture) {
			// Get a CMSampleBuffer's Core Video image buffer for the media data
			CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
			// Lock the base address of the pixel buffer
			CVPixelBufferLockBaseAddress(imageBuffer, 0);
			
			// Get the number of bytes per row for the pixel buffer
			void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
			
			// Get the number of bytes per row for the pixel buffer
			size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
			// Get the pixel buffer width and height
			size_t width = CVPixelBufferGetWidth(imageBuffer);
			size_t height = CVPixelBufferGetHeight(imageBuffer);
			
			// Create a device-dependent RGB color space
			CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
			
			// Create a bitmap graphics context with the sample buffer data
			CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8,
														 bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
			// Create a Quartz image from the pixel data in the bitmap graphics context
			CGImageRef quartzImage = CGBitmapContextCreateImage(context);
			
			// Unlock the pixel buffer
			CVPixelBufferUnlockBaseAddress(imageBuffer,0);
			
			// Free up the context and color space
			CGContextRelease(context);
			CGColorSpaceRelease(colorSpace);
            UIImageView *imageView = [(EGEdgyView *)[self view] imageView];
			// Create an image object from the Quartz image
			UIImage *uiImage = [UIImage imageWithCGImage:quartzImage];
			// Release the Quartz image
			CGImageRelease(quartzImage);
            
            [imageView setImage:uiImage];
        }
    });
    
}
#endif

@end


@implementation EGSHKActionSheet

- (void)dismissWithClickedButtonIndex:(NSInteger)buttonIndex animated:(BOOL)animated
{
    [super dismissWithClickedButtonIndex:buttonIndex animated:animated];
    if (dismissHandler) {
        dismissHandler();
        [dismissHandler release];
        dismissHandler = nil;
    }
}

- (void)setEGDismissHandler:(void (^)(void))handler
{
    [dismissHandler release];
    dismissHandler = [handler copy];
}

@end

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
#import "UIImage-OpenCVExtensions.h"
#import "Binarization.hpp"        // for static inlines
#import "ImageOrientationAccelerometer.h"


@interface EGCaptureController ()

- (void)setDefaultSettings;

- (void)startRunning;
- (void)stopRunning;
- (void)stopRunningAndResetSettings;
- (void)updateConfiguration;
- (void)orientationDidChange;

- (void)thresholdChanged:(id)sender;
- (void)cameraToggled:(id)sender;
- (void)colorToggled:(id)sender;
- (void)torchToggled:(id)sender;
- (void)captureImage:(id)sender;

@end

@interface EGSHKActionSheet : SHKActionSheet {
    void (^dismissHandler)(void);
}

- (void)setEGDismissHandler:(void (^)(void))handler;

@end


@implementation EGCaptureController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        sampleProcessingQueue = dispatch_queue_create("sample processing", NULL);
        // Set up the session and output
#if TARGET_OS_EMBEDDED
        session = [[AVCaptureSession alloc] init];
        
        captureVideoDataOuput = [[AVCaptureVideoDataOutput alloc] init];
        [captureVideoDataOuput setSampleBufferDelegate:(id<AVCaptureVideoDataOutputSampleBufferDelegate>)self queue:sampleProcessingQueue];
        [captureVideoDataOuput setMinFrameDuration:CMTimeMake(1, 10)];  // 10 fps max
        
        // Try to use YpCbCr as a first option for performance
        fallBackToBGRA32Sampling = NO;
        double osVersion = [[[UIDevice currentDevice] systemVersion] doubleValue];
        if (osVersion == 0.0 || osVersion >= 10.2) {
            // Try to use bi-planar YpCbCr first so that we can quickly extract Y'
            NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange]
                                                                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
			
            @try {
                [captureVideoDataOuput setVideoSettings:settings];
            } @catch (...) {
                fallBackToBGRA32Sampling = YES;
            }
        } else {
            fallBackToBGRA32Sampling = YES;
        }
        
        if (fallBackToBGRA32Sampling) {
            NSLog(@"Falling back to BGRA32 sampling");
            // Fall back to BGRA32
            NSDictionary *settings = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA]
                                                                 forKey:(id)kCVPixelBufferPixelFormatTypeKey];
            [captureVideoDataOuput setVideoSettings:settings];
        }
        
        [session addOutput:captureVideoDataOuput];
#endif
        [self setWantsFullScreenLayout:YES];
        [self setDefaultSettings];
    }
    return self;
}

- (void)dealloc
{
    
    [super dealloc];
}

- (void)setDefaultSettings
{
    // Default to the front camera and a moderate threshold
    colorEdges = YES;
    deviceIndex = 2;
    cannyThreshold = 120;
}

- (void)loadView
{
    // Create the preview layer and view
    EGEdgyView *view = [[EGEdgyView alloc] initWithFrame:CGRectZero];
    [self setView:view];
    [view release];
    
    [[view captureButton] addTarget:self action:@selector(captureImage:) forControlEvents:UIControlEventTouchUpInside];
    
#if FREE_VERSION
    [[view bannerView] setDelegate:self];
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    // Monitor for orientation updates
    [[ImageOrientationAccelerometer sharedInstance] beginGeneratingDeviceOrientationNotifications];
    NSNotificationCenter *defaultCenter = [NSNotificationCenter defaultCenter];
    [defaultCenter addObserver:self selector:@selector(orientationDidChange) name:DeviceOrientationDidChangeNotification object:nil];
    
    // Listen for app relaunch
    [defaultCenter addObserver:self selector:@selector(stopRunningAndResetSettings) name:UIApplicationDidEnterBackgroundNotification object:nil];
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

- (void)stopRunningAndResetSettings
{
    [self setDefaultSettings];
    [self stopRunning];
}

- (void)updateConfiguration
{
    EGEdgyView *view = (EGEdgyView *)[self view];
    
#if TARGET_OS_EMBEDDED
    // Create the session
    [session beginConfiguration];
    
    // Choose the proper device and hide the device button if there is 0 or 1 devices
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    deviceIndex %= [devices count];
    if (!currentDevice || ![[devices objectAtIndex:deviceIndex] isEqual:currentDevice]) {
        [currentDevice release];
        currentDevice = [[devices objectAtIndex:deviceIndex] retain];
        
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
    IplImage *pixels = [image createIplImageWithNumberOfChannels:1];
#if TARGET_OS_EMBEDDED
    if ([currentDevice position] == AVCaptureDevicePositionFront) {
        cvFlip(pixels, NULL, (imageOrientation == UIImageOrientationUp || imageOrientation == UIImageOrientationDown) ? 0 : 1);        // flip vertically
    }
#endif
	CvSize pixelsSize = cvGetSize(pixels);
	
	// Create an image object from the Quartz image
	
	NSArray *templates = [NSArray arrayWithObjects: @"00.png", @"01.png", @"02.png", @"03.png", @"04.png", @"05.png", @"06.png", @"07.png", @"08.png", @"09.png", @"10.png", @"11.png", @"11.png", @"12.png", @"13.png", @"14.png", @"15.png", @"16.png", @"17.png", @"18.png", @"19.png", nil];
	
	double best_val = DBL_MAX;
	NSLog(@"width of picture taken: %d", pixelsSize.width);
	NSLog(@"height of picture taken: %d", pixelsSize.height);
	UIImage *best_image = [UIImage alloc];
	for (NSUInteger i = 0; i < [templates count]; i++) {
		NSString *filename = [templates objectAtIndex:i];
		UIImage *ui_template_image = [UIImage imageNamed:filename];
		IplImage *template_image = [ui_template_image createIplImageWithNumberOfChannels:1];
		CvSize templateSize = cvGetSize(template_image);
		
		CvSize resultSize = cvSize(abs(pixelsSize.width - templateSize.width) + 1, abs(pixelsSize.height - templateSize.height) + 1);
		IplImage *imgResult = cvCreateImage(resultSize, IPL_DEPTH_32F, 1);
		//NSLog(template_image.type());
		cvMatchTemplate(pixels, template_image, imgResult, CV_TM_CCORR_NORMED);
		double min_val;
		double max_val;
		cvMinMaxLoc(imgResult, &min_val, &max_val);
		if (min_val <= best_val) {
			NSLog(@"better: %@", filename);
			best_val = min_val;
			best_image = ui_template_image;
		}
	}
	
    image = best_image; //[[UIImage alloc] initWithIplImage:pixels];
    cvReleaseImage(&pixels);
	
    [image release];
    
    NSMutableString *inst = [NSMutableString stringWithString:@""];
    NSMutableString *title = [NSMutableString stringWithString:@"Coffee Instructions"];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithString:title] message:[NSString stringWithString:inst] delegate:self cancelButtonTitle:@"Done!" otherButtonTitles: nil];
    [alert show];

    [view removeFromSuperview];
}

- (void)thresholdChanged:(id)sender
{
    cannyThreshold = [(UISlider *)sender value];
}

- (void)cameraToggled:(id)sender
{
    deviceIndex++;
    [self updateConfiguration];
}

- (void)colorToggled:(id)sender
{
    colorEdges = !colorEdges;
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
			//CGContextRelease(context);
			//CGColorSpaceRelease(colorSpace);
            UIImageView *imageView = [(EGEdgyView *)[self view] imageView];
			// Create an image object from the Quartz image
			UIImage *uiImage = [UIImage imageWithCGImage:quartzImage];
			// Release the Quartz image
			//CGImageRelease(quartzImage);
            
            [imageView setImage:uiImage];
            //[uiImage release];
        }
    });
    
    
    
#if PRINT_PERFORMANCE
    static CFAbsoluteTime lastUpdateTime = 0.0;
    CFAbsoluteTime currentTime = CACurrentMediaTime();
    if (lastUpdateTime) {
        NSLog(@"Processing time: %.3f (fps %.1f) size(%u,%u)",
              currentTime - lastUpdateTime,
              1.0 / (currentTime - lastUpdateTime),
              size.width,
              size.height);
    }
    lastUpdateTime = currentTime;
#endif
}
#endif

#if FREE_VERSION
- (void)bannerViewDidLoadAd:(ADBannerView *)banner
{
    [banner setHidden:NO];
    [banner setAlpha:0.0];
    [[self view] setNeedsLayout];
    
    [UIView beginAnimations:nil context:NULL];
    [banner setAlpha:1.0];
    [UIView commitAnimations];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error
{
    [banner setHidden:YES];
    [[self view] setNeedsLayout];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave
{
    pauseForCapture = YES;
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner
{
    pauseForCapture = NO;
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

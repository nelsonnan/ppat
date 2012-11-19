//
//  EGEdgyAppDelegate.h
//  ImageProcessing
//
//  Created by Chris Marcellino on 12/30/2010.
//  Copyright Chris Marcellino 2010. All rights reserved.
//

#import "EGEdgyAppDelegate.h"
#import "EGCaptureController.h"
#import "SHK.h"

@implementation EGEdgyAppDelegate

@synthesize window, captureController;

- (void)applicationDidFinishLaunching:(UIApplication *)application 
{
    // Hide the status bar
    [application setStatusBarHidden:YES];
    
    // Create the window and main view controller
    window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [window setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    captureController = [[EGCaptureController alloc] initWithNibName:nil bundle:nil];
    UIView *view = [captureController view];
    [view setFrame:[window bounds]];
    [view setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    [window addSubview:view];
    [window makeKeyAndVisible];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [SHK flushOfflineQueue];
}

- (void)dealloc 
{
    [captureController release];
    [window release];
    [super dealloc];
}

@end

//
//  AppController.m
//  Edgy
//
//  Created by Chris Marcellino on 1/30/11.
//  Copyright Chris Marcellino 2011 . All rights reserved.
//

#import "AppController.h"

@implementation AppController

- (void)awakeFromNib
{
    // Load the plugin
    NSString *pluginPath = [[NSBundle mainBundle] pathForResource:@"Edgy" ofType:@"plugin"];
    [QCPlugIn loadPlugInAtPath:pluginPath];
    
    // Load the composition
    NSString *compositionPath = [[NSBundle mainBundle] pathForResource:@"Edgy" ofType:@"qtz"];
	if (![qcView loadCompositionFromFile:compositionPath]) {
        [self showPluginErrorAlert];
	}
}

- (void)showPluginErrorAlert
{
    [[NSAlert alertWithMessageText:@"Error"
                     defaultButton:nil
                   alternateButton:nil
                       otherButton:nil
         informativeTextWithFormat:@"It appears that the Edgy Quartz Composer plugin cannot be loaded. "
      "Please update to Mac OS X 10.6 (SnowLeopard) or later, or contact the author."] runModal];
    [NSApp terminate:self];    
}

- (void)windowWillClose:(NSNotification *)notification 
{
	[NSApp terminate:self];
}

@end

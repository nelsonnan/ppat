//
//  AppController.h
//  Edgy
//
//  Created by Chris Marcellino on 1/30/11.
//  Copyright Chris Marcellino 2011 . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <Quartz/Quartz.h>

@interface AppController : NSObject 
{
    IBOutlet QCView* qcView;
}

- (void)showPluginErrorAlert;

@end

//
//  ViewController.h
//  NSMeetupExample
//
//  Created by Steve Gifford on 8/6/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

// The various test modes for the demo
typedef enum {SingleCube,MoreCubes,ManyCubesManyBuffers,ManyCubesFewBuffers,WholeLottaCubes,MeteredCubes,MeteredCubesMultiThread,MaxTestModes} TestModes;

@interface ViewController : GLKViewController

@property TestModes testMode;

@end

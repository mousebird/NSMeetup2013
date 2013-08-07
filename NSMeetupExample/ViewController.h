//
//  ViewController.h
//  NSMeetupExample
//
//  Created by sjg@mousebirdconsulting.com on 8/6/13.
//

#import <UIKit/UIKit.h>
#import <GLKit/GLKit.h>

// The various test modes for the demo
typedef enum {SingleCube,MoreCubes,ManyCubesManyBuffers,ManyCubesFewBuffers,WholeLottaCubes,MeteredCubes,MeteredCubesMultiThread,MaxTestModes} TestModes;

@interface ViewController : GLKViewController

@property TestModes testMode;

@end

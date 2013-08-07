//
//  FlexiVertexBuffer.h
//  NSMeetupExample
//
//  Created by sjg@mousebirdconsulting.com on 8/6/13.
//

#import <UIKit/UIKit.h>
#import "SimpleGLObject.h"

@interface FlexiVertexBuffer : NSObject

// Create a flexi buffer with the vertices for a cube centered at the origin
//  of the given size
+ (FlexiVertexBuffer *)BufferWithCubeAt:(float *)org sized:(float *)size;

// Add a cube to the existing vertices
- (void)addCubeAt:(float *)org sized:(float *)size;

// Vertices are always 24 bytes (3 floats for location + 3 floats for normal)
@property GLuint vertexSize;

// Number of vertices
@property GLuint numVertices;

// Interleaved vertex data
@property NSMutableData *vertices;

// Create a GL Object and its associated buffer from a flexi buffer
- (SimpleGLObject *)makeSimpleGLObject;

@end

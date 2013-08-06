//
//  SimpleGLObject.h
//  NSMeetupExample
//
//  Created by Steve Gifford on 8/6/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import <UIKit/UIKit.h>

/* A wrapper around the data we need to draw a single
    OpenGL ES related object.
 */
@interface SimpleGLObject : NSObject

// The buffer in OpenGL driver space containing the vertices
@property GLuint vertexBuffer;

// Vertex arrays contain the state to draw our object
@property GLuint vertexArray;

// The number of vertices we'll be drawing (3 * numTriangles)
@property GLuint numVertices;

@end

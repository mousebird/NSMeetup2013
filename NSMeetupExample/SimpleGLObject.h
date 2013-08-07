//
//  SimpleGLObject.h
//  NSMeetupExample
//
//  Created by sjg@mousebirdconsulting.com on 8/6/13.
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

// Size of the vertices
@property GLuint vertexSize;

// Set if there are texture coordinates
@property bool hasTextureCoords;

// Set up the vertex array object.  Only on the main thread.
- (void)makeVertexArray;

// Clean up objects in OpenGL ES context
- (void)tearDownGL;

@end

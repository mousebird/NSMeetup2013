//
//  SimpleGLObject.m
//  NSMeetupExample
//
//  Created by sjg@mousebirdconsulting.com on 8/6/13.
//

#import "SimpleGLObject.h"
#import <GLKit/GLKit.h>

@implementation SimpleGLObject

// glVertexAttribPointer works with char * and offsets.
// We're using it the latter way, which is easier with this
#define BUFFER_OFFSET(i) ((char *)NULL + (i))

// Set up the vertex array (note this can only be done on the main thread)
- (void)makeVertexArray
{
    // Create a vertex array object and set up its internal state
    glGenVertexArraysOES(1, &_vertexArray);
    glBindVertexArrayOES(_vertexArray);

    glBindBuffer(GL_ARRAY_BUFFER, _vertexBuffer);
    
    // Normally you'd have to do this each time
    // Vertex arrays encapsulate this for you
    glEnableVertexAttribArray(GLKVertexAttribPosition);
    glVertexAttribPointer(GLKVertexAttribPosition, 3,
                          GL_FLOAT, GL_FALSE,
                          _vertexSize, BUFFER_OFFSET(0));
    glEnableVertexAttribArray(GLKVertexAttribNormal);
    glVertexAttribPointer(GLKVertexAttribNormal, 3,
                          GL_FLOAT, GL_FALSE,
                          _vertexSize, BUFFER_OFFSET(12));
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
}

- (void)tearDownGL
{
    if (_vertexArray != 0)
        glDeleteVertexArraysOES(1, &_vertexArray);
    if (_vertexBuffer != 0)
        glDeleteBuffers(1, &_vertexBuffer);
}

@end

//
//  FlexiVertexBuffer.m
//  NSMeetupExample
//
//  Created by sjg@mousebirdconsulting.com on 8/6/13.
//

#import "FlexiVertexBuffer.h"

GLfloat gCubeVertexData[216] =
{
    // Data layout for each line below is:
    // positionX, positionY, positionZ,     normalX, normalY, normalZ,
    0.5f, -0.5f, -0.5f,        1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, -0.5f,          1.0f, 0.0f, 0.0f,
    0.5f, 0.5f, 0.5f,         1.0f, 0.0f, 0.0f,
    
    0.5f, 0.5f, -0.5f,         0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    0.5f, 0.5f, 0.5f,          0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 1.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 1.0f, 0.0f,
    
    -0.5f, 0.5f, -0.5f,        -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, 0.5f, 0.5f,         -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, -0.5f,       -1.0f, 0.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        -1.0f, 0.0f, 0.0f,
    
    -0.5f, -0.5f, -0.5f,       0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, -0.5f,        0.0f, -1.0f, 0.0f,
    0.5f, -0.5f, 0.5f,         0.0f, -1.0f, 0.0f,
    
    0.5f, 0.5f, 0.5f,          0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    0.5f, -0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, 0.5f, 0.5f,         0.0f, 0.0f, 1.0f,
    -0.5f, -0.5f, 0.5f,        0.0f, 0.0f, 1.0f,
    
    0.5f, -0.5f, -0.5f,        0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    0.5f, 0.5f, -0.5f,         0.0f, 0.0f, -1.0f,
    -0.5f, -0.5f, -0.5f,       0.0f, 0.0f, -1.0f,
    -0.5f, 0.5f, -0.5f,        0.0f, 0.0f, -1.0f
};

@implementation FlexiVertexBuffer

+ (FlexiVertexBuffer *)BufferWithCubeAt:(float *)center sized:(float *)size
{
    FlexiVertexBuffer *buf = [[FlexiVertexBuffer alloc] init];
    
    [buf addCubeAt:center sized:size];

    return buf;
}

- (id)init
{
    self = [super init];
    _vertices = [NSMutableData data];
    
    return self;
}

// Add a cube at the given location with the given scale
- (void)addCubeAt:(float *)center sized:(float *)size
{
    // Work through the 36 vertices
    for (unsigned int ii = 0;ii<36;ii++)
    {
        float *vertInfo = &gCubeVertexData[ii*6];
        float pos[3],norm[3];
        for (unsigned int jj=0;jj<3;jj++)
        {
            pos[jj] = center[jj] + vertInfo[jj]*size[jj];
            norm[jj] = vertInfo[3+jj];
        }
        
        [_vertices appendBytes:pos length:sizeof(float)*3];
        [_vertices appendBytes:norm length:sizeof(float)*3];
    }
    _vertexSize = 24;
    _numVertices += 36;
}

// Set up the vertex buffer we need to draw these triangles
- (SimpleGLObject *)makeSimpleGLObject
{
    GLuint vertexBuffer;
    
    // We create the vertex buffer and fill it with data right here
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, [_vertices length], [_vertices bytes], GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // We'll keep track of the buffers and number of triangles here
    SimpleGLObject *glObject = [[SimpleGLObject alloc] init];
    glObject.vertexBuffer = vertexBuffer;
    glObject.vertexArray = 0;
    glObject.vertexSize = _vertexSize;
    glObject.numVertices = _numVertices;
    
    return glObject;
}

@end

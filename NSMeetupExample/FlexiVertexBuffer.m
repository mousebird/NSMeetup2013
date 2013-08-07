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
    
    // Coordinates + Normals
    _vertexSize = 3*sizeof(float)+3*sizeof(float);
    _numVertices += 36;
}

// Number of samples in each direction
static const int LongitudeSample=20,LatitudeSample=10;

- (void)addSphereAt:(float *)org sized:(float *)size
{
    // We'll generate the coordinates and normals ahead of time
    float coords[3*LongitudeSample*LatitudeSample];
    float norms[3*LongitudeSample*LatitudeSample];
    float texCoords[2*LongitudeSample*LatitudeSample];
    
    // Work our way around the equator, building vertices
    int ix=0;
    for (float lon=-180.0;ix<LongitudeSample;lon+=360.0/(LongitudeSample-1),ix++)
    {
        int iy=0;
        // Run from the south pole to the north
        for (float lat=-90.0;iy<LatitudeSample;lat+=180.0/(LatitudeSample-1),iy++)
        {
            // Generate a coordinate on the unit sphere
            float coord[3];
            float z = sinf(lat/180.0*M_PI);
            float rad = sqrtf(1.0-z*z);
            coord[0] = rad*cosf(lon/180.0*M_PI);
            coord[1] = rad*sinf(lon/180.0*M_PI);
            coord[2] = z;
            
            // The normal is the coordinate (on the unit sphere)
            float *thisNorm = &norms[3*(iy*LongitudeSample+ix)];
            thisNorm[0] = coord[0];  thisNorm[1] = coord[1];  thisNorm[2] = coord[2];

            // Scale the coordinate and save it off
            float *thisCoord = &coords[3*(iy*LongitudeSample+ix)];
            thisCoord[0] = coord[0]*size[0]+org[0];  thisCoord[1] = coord[1]*size[1]+org[1];  thisCoord[2] = coord[2]*size[2]+org[2];
            
            // And texture coordinates
            float *texCoord = &texCoords[2*(iy*LongitudeSample+ix)];
            texCoord[0] = ix/(float)(LongitudeSample-1);
            texCoord[1] = iy/(float)(LatitudeSample-1);
        }
    }
    
    // Now for the triangles, we need two per sample
    for (int ix=0;ix<LongitudeSample-1;ix++)
        for (int iy=0;iy<LatitudeSample-1;iy++)
        {
            // Lower left triangle
            [_vertices appendBytes:&coords[3*(iy*LongitudeSample+ix)] length:sizeof(float)*3];
            [_vertices appendBytes:&norms[3*(iy*LongitudeSample+ix)] length:sizeof(float)*3];
            [_vertices appendBytes:&texCoords[2*(iy*LongitudeSample+ix)] length:sizeof(float)*2];
            [_vertices appendBytes:&coords[3*(iy*LongitudeSample+ix+1)] length:sizeof(float)*3];
            [_vertices appendBytes:&norms[3*(iy*LongitudeSample+ix+1)] length:sizeof(float)*3];
            [_vertices appendBytes:&texCoords[2*(iy*LongitudeSample+ix+1)] length:sizeof(float)*2];
            [_vertices appendBytes:&coords[3*((iy+1)*LongitudeSample+ix)] length:sizeof(float)*3];
            [_vertices appendBytes:&norms[3*((iy+1)*LongitudeSample+ix)] length:sizeof(float)*3];
            [_vertices appendBytes:&texCoords[2*((iy+1)*LongitudeSample+ix)] length:sizeof(float)*2];

            // Upper right triangle
            [_vertices appendBytes:&coords[3*(iy*LongitudeSample+ix+1)] length:sizeof(float)*3];
            [_vertices appendBytes:&norms[3*(iy*LongitudeSample+ix+1)] length:sizeof(float)*3];
            [_vertices appendBytes:&texCoords[2*(iy*LongitudeSample+ix+1)] length:sizeof(float)*2];
            [_vertices appendBytes:&coords[3*((iy+1)*LongitudeSample+ix+1)] length:sizeof(float)*3];
            [_vertices appendBytes:&norms[3*((iy+1)*LongitudeSample+ix+1)] length:sizeof(float)*3];
            [_vertices appendBytes:&texCoords[2*((iy+1)*LongitudeSample+ix+1)] length:sizeof(float)*2];
            [_vertices appendBytes:&coords[3*((iy+1)*LongitudeSample+ix)] length:sizeof(float)*3];
            [_vertices appendBytes:&norms[3*((iy+1)*LongitudeSample+ix)] length:sizeof(float)*3];
            [_vertices appendBytes:&texCoords[2*((iy+1)*LongitudeSample+ix)] length:sizeof(float)*2];
        }

    // Coordintes + Normals + Texture coordinates
    _vertexSize = 3*sizeof(float)+ 3*sizeof(float)+ 2*sizeof(float);
    _hasTextureCoords = true;
    _numVertices += (LongitudeSample-1)*(LatitudeSample-1)*2*3;
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
    glObject.hasTextureCoords = _hasTextureCoords;
    
    return glObject;
}

@end

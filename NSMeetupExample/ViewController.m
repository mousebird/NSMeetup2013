//
//  ViewController.m
//  NSMeetupExample
//
//  Created by Steve Gifford on 8/6/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

#import "ViewController.h"
#import "SimpleGLObject.h"
#import "FlexiVertexBuffer.h"

#define BUFFER_OFFSET(i) ((char *)NULL + (i))

@interface ViewController () {
    GLKMatrix4 _modelViewProjectionMatrix;
    GLKMatrix3 _normalMatrix;
    float _rotation;
    
    NSMutableArray *_glObjects;
}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }
    
    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    
    _glObjects = [NSMutableArray array];
    
    [self setupGL];
}

- (void)dealloc
{    
    [self tearDownGL];
    
    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    if ([self isViewLoaded] && ([[self view] window] == nil)) {
        self.view = nil;
        
        [self tearDownGL];
        
        if ([EAGLContext currentContext] == self.context) {
            [EAGLContext setCurrentContext:nil];
        }
        self.context = nil;
    }

    // Dispose of any resources that can be recreated.
}

// Build the OpenGL constructs necessary to draw what's in the flexi buffer
- (SimpleGLObject *)makeObjectFromFlexiBuffer:(FlexiVertexBuffer *)flexiBuffer
{
    GLuint vertexBuffer,vertexArray;

    // We create the vertex buffer and fill it with data right here
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, [flexiBuffer.vertices length], [flexiBuffer.vertices bytes], GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // Create a vertex array object and set up its internal state
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    // Everything in this block is work you'd normally have to do in the rendering loop.
    // A vertex array object encapsulates this for you
    {
        glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, flexiBuffer.vertexSize, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, flexiBuffer.vertexSize, BUFFER_OFFSET(12));
    }
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // We'll keep track of the buffers and number of triangles here
    SimpleGLObject *glObject = [[SimpleGLObject alloc] init];
    glObject.vertexBuffer = vertexBuffer;
    glObject.vertexArray = vertexArray;
    glObject.numVertices = flexiBuffer.numVertices;
    
    return glObject;
}

// Create a single cube, much like the Apple test case
- (void)setupSingleCube
{
    // A single cube, centered at the origin
    float origin[3] = {0,0,0};
    float size[3] = {1,1,1};
    FlexiVertexBuffer *flexiBuffer = [FlexiVertexBuffer BufferWithCubeAt:origin sized:size];
 
    SimpleGLObject *glObject = [self makeObjectFromFlexiBuffer:flexiBuffer];
    [_glObjects addObject:glObject];
}

// Set up a bunch of cubes, one set of buffers per cube
- (void)setupManyCubesManyBuffers:(int)numCubes
{
    for (unsigned int ii=0;ii<numCubes;ii++)
    {
        // Pick a random origin and size
        float origin[3],size[3];
        origin[0] = drand48();  origin[1] = drand48();  origin[2] = drand48();
        size[0] = size[1] = size[2] = drand48()/10.0;
        FlexiVertexBuffer *flexiBuffer = [FlexiVertexBuffer BufferWithCubeAt:origin sized:size];
        
        SimpleGLObject *glObject = [self makeObjectFromFlexiBuffer:flexiBuffer];
        [_glObjects addObject:glObject];
    }
}

// Set up a bunch of cubes, but create fewer buffers
- (void)setupManyCubesFewBuffers:(int)numCubes
{
    FlexiVertexBuffer *flexiBuffer = [[FlexiVertexBuffer alloc] init];
    
    for (unsigned int ii=0;ii<numCubes;ii++)
    {
        // Pick a random origin and size
        float origin[3],size[3];
        origin[0] = drand48();  origin[1] = drand48();  origin[2] = drand48();
        size[0] = size[1] = size[2] = drand48()/10.0;

        // Add the cube to what we already have
        [flexiBuffer addCubeAt:origin sized:size];
        
        // If the buffer gets too big, flush it out
        if (flexiBuffer.numVertices > 32768)
        {
            SimpleGLObject *glObject = [self makeObjectFromFlexiBuffer:flexiBuffer];
            [_glObjects addObject:glObject];            

            flexiBuffer = [[FlexiVertexBuffer alloc] init];
        }
    }
    
    // Flush anything left over
    if (flexiBuffer.numVertices > 0)
    {
        SimpleGLObject *glObject = [self makeObjectFromFlexiBuffer:flexiBuffer];
        [_glObjects addObject:glObject];
    }
}

- (void)setupGL
{
    [EAGLContext setCurrentContext:self.context];
    
    self.effect = [[GLKBaseEffect alloc] init];
    self.effect.light0.enabled = GL_TRUE;
    self.effect.light0.diffuseColor = GLKVector4Make(1.0f, 0.4f, 0.4f, 1.0f);
    
    glEnable(GL_DEPTH_TEST);
    
    switch (_testMode)
    {
        case SingleCube:
            [self setupSingleCube];
            break;
        case MoreCubes:
            [self setupManyCubesManyBuffers:200];
            break;
        case ManyCubesManyBuffers:
            [self setupManyCubesManyBuffers:10000];
            break;
        case ManyCubesFewBuffers:
            [self setupManyCubesFewBuffers:10000];
            break;
        case WholeLottaCubes:
            [self setupManyCubesFewBuffers:50000];
            break;
        default:
            break;
    }
}

- (void)tearDownGL
{
    [EAGLContext setCurrentContext:self.context];
    
    // Tear down the buffers
    for (SimpleGLObject *glObject in _glObjects)
    {
        GLuint vertexBuffer = glObject.vertexBuffer;
        GLuint vertexArray = glObject.vertexArray;
        glDeleteVertexArraysOES(1, &vertexArray);
        glDeleteBuffers(1, &vertexBuffer);
    }
    [_glObjects removeAllObjects];
    
    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix = GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -4.0f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;
    
    // Compute the model view matrix for the object rendered with ES2
    modelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, 1.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    _normalMatrix = GLKMatrix3InvertAndTranspose(GLKMatrix4GetMatrix3(modelViewMatrix), NULL);
    
    _modelViewProjectionMatrix = GLKMatrix4Multiply(projectionMatrix, modelViewMatrix);
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Work through the vertex arrays (and their triangles)
    for (SimpleGLObject *glObject in _glObjects)
    {
        glBindVertexArrayOES(glObject.vertexArray);
        
        // Render the object with GLKit
        [self.effect prepareToDraw];
        
        glDrawArrays(GL_TRIANGLES, 0, glObject.numVertices);
    }
}

@end

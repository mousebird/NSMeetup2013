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
    float _rotation;
    
    // These are the objects we're drawing
    NSMutableArray *_glObjects;
    
    // EAGLContext used by the other thread;
    EAGLContext *otherContext;
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
}

// Set up the vertex buffer we need to draw these triangles
- (SimpleGLObject *)makeObjectFromFlexiBuffer:(FlexiVertexBuffer *)flexiBuffer
{
    GLuint vertexBuffer;

    // We create the vertex buffer and fill it with data right here
    glGenBuffers(1, &vertexBuffer);
    glBindBuffer(GL_ARRAY_BUFFER, vertexBuffer);
    glBufferData(GL_ARRAY_BUFFER, [flexiBuffer.vertices length], [flexiBuffer.vertices bytes], GL_STATIC_DRAW);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    
    // We'll keep track of the buffers and number of triangles here
    SimpleGLObject *glObject = [[SimpleGLObject alloc] init];
    glObject.vertexBuffer = vertexBuffer;
    glObject.vertexArray = 0;
    glObject.vertexSize = flexiBuffer.vertexSize;
    glObject.numVertices = flexiBuffer.numVertices;
    
    return glObject;
}

// Set up the vertex array (note this can only be done on the main thread)
- (void)makeVertexArrayForObject:(SimpleGLObject *)glObj
{
    GLuint vertexArray;
    
    // Create a vertex array object and set up its internal state
    glGenVertexArraysOES(1, &vertexArray);
    glBindVertexArrayOES(vertexArray);
    
    // Everything in this block is work you'd normally have to do in the rendering loop.
    // A vertex array object encapsulates this for you
    {
        glBindBuffer(GL_ARRAY_BUFFER, glObj.vertexBuffer);
        
        glEnableVertexAttribArray(GLKVertexAttribPosition);
        glVertexAttribPointer(GLKVertexAttribPosition, 3, GL_FLOAT, GL_FALSE, glObj.vertexSize, BUFFER_OFFSET(0));
        glEnableVertexAttribArray(GLKVertexAttribNormal);
        glVertexAttribPointer(GLKVertexAttribNormal, 3, GL_FLOAT, GL_FALSE, glObj.vertexSize, BUFFER_OFFSET(12));
    }
    
    glBindVertexArrayOES(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);
    glObj.vertexArray = vertexArray;
}

// Create a single cube, much like the Apple test case
- (void)setupSingleCube
{
    // A single cube, centered at the origin
    float origin[3] = {0,0,0};
    float size[3] = {0.75,0.75,0.75};
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
        size[0] = size[1] = size[2] = drand48()/20.0;
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
        size[0] = size[1] = size[2] = drand48()/20.0;

        // Add the cube to what we already have
        [flexiBuffer addCubeAt:origin sized:size];
        
        // If the buffer gets too big, flush it out
        if (flexiBuffer.numVertices > 32768)
        {
            SimpleGLObject *glObject = [self makeObjectFromFlexiBuffer:flexiBuffer];
            @synchronized(_glObjects)
            {
                [_glObjects addObject:glObject];
            }

            flexiBuffer = [[FlexiVertexBuffer alloc] init];
        }
    }
    
    // Flush anything left over
    if (flexiBuffer.numVertices > 0)
    {
        SimpleGLObject *glObject = [self makeObjectFromFlexiBuffer:flexiBuffer];
        @synchronized(_glObjects)
        {
            [_glObjects addObject:glObject];
        }
    }
}

// Add cubes and schedule some for the next second
- (void)addCubesEverySoOften:(NSArray *)args
{
    int numCubes = [args[0] integerValue];
    int numTimes = [args[1] integerValue];
    [self setupManyCubesFewBuffers:numCubes];
    
    if (numTimes > 0)
        [self performSelector:@selector(addCubesEverySoOften:) withObject:@[@(numCubes),@(numTimes-1)] afterDelay:1.0];
}

// Kick off adding cubes every second
- (void)setupMeteredCubes:(int)numCubes times:(int)numTimes
{
    [self performSelector:@selector(addCubesEverySoOften:) withObject:@[@(numCubes),@(numTimes)] afterDelay:1.0];
}

// Kick off adding cubes every second, but on a different thread
- (void)setupMultithreadedMeteredCubes:(int)numCubes times:(int)numTimes
{
    // Make ourselves a new OpenGL ES context before we kick off the thread
    // Notice that it uses the sharegroup from the
    otherContext = [[EAGLContext alloc] initWithAPI:self.context.API sharegroup:self.context.sharegroup];
    
    // Kick off the work
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                   ^{
                       // We're in our local thread here, so use our custom context
                       [EAGLContext setCurrentContext:otherContext];

                       for (unsigned int ii=0;ii<numTimes;ii++)
                       {
                           // Add the cubes
                           [self setupManyCubesFewBuffers:numCubes];

                           // Sleep one second
                           usleep(1000000);
                       }
                       
                       glFlush();
                       
                       // We're done with that context
                       otherContext = nil;
                   });
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
            [self setupManyCubesFewBuffers:30000];
            break;
        case MeteredCubes:
            // Add 3000 cubes 8 times
            [self setupMeteredCubes:3000 times:8];
            break;
        case MeteredCubesMultiThread:
            // Add 3000 cubes 8 times on another thread
            [self setupMultithreadedMeteredCubes:3000 times:8];
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
    
    GLKMatrix4 baseModelViewMatrix = GLKMatrix4MakeTranslation(0.0f, 0.0f, -1.5f);
    baseModelViewMatrix = GLKMatrix4Rotate(baseModelViewMatrix, _rotation, 0.0f, 1.0f, 0.0f);
    
    // Compute the model view matrix for the object rendered with GLKit
    GLKMatrix4 modelViewMatrix = GLKMatrix4MakeTranslation(-0.5f, -0.5f, -0.5f);
    modelViewMatrix = GLKMatrix4Rotate(modelViewMatrix, _rotation, 1.0f, 1.0f, 1.0f);
    modelViewMatrix = GLKMatrix4Multiply(baseModelViewMatrix, modelViewMatrix);
    
    self.effect.transform.modelviewMatrix = modelViewMatrix;    
    
    _rotation += self.timeSinceLastUpdate * 0.5f;
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect
{
    glClearColor(0.65f, 0.65f, 0.65f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    // Work through the vertex arrays (and their triangles)
    @synchronized(_glObjects)
    {
        for (SimpleGLObject *glObject in _glObjects)
        {
            // See if the vertex array has been built
            // We only need to do this once, but it has to be here
            if (glObject.vertexArray == 0)
                [self makeVertexArrayForObject:glObject];
            
            glBindVertexArrayOES(glObject.vertexArray);
            
            // Render the object with GLKit
            [self.effect prepareToDraw];
            
            glDrawArrays(GL_TRIANGLES, 0, glObject.numVertices);
        }
    }
}

@end

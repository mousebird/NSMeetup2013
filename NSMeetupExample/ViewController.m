//
//  ViewController.m
//  NSMeetupExample
//
//  Created by sjg@mousebirdconsulting.com on 8/6/13.
//

#import "ViewController.h"
#import "SimpleGLObject.h"
#import "FlexiVertexBuffer.h"

@interface ViewController ()
{
    // Rotation applied to geometry.  Changes over time.
    float _rotation;
    
    // These are the objects we're drawing
    NSMutableArray *_glObjects;
    
    // EAGLContext used by the other thread;
    EAGLContext *otherContext;
}

// The OpenGL ES2 rendering context
@property (strong, nonatomic) EAGLContext *context;

// A GLKit effect we'll use for lighting and transforms
@property (strong, nonatomic) GLKBaseEffect *effect;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];

    if (!self.context)
        NSLog(@"Failed to create ES context");
    
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

// Create a single cube, much like the Apple test case
- (void)setupSingleCube
{
    // A single cube, centered at the origin
    float origin[3] = {0,0,0};
    float size[3] = {0.75,0.75,0.75};
    FlexiVertexBuffer *flexiBuffer = [FlexiVertexBuffer
                                      BufferWithCubeAt:origin
                                      sized:size];
 
    SimpleGLObject *glObject = [flexiBuffer makeSimpleGLObject];
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
        FlexiVertexBuffer *flexiBuffer = [FlexiVertexBuffer
                                          BufferWithCubeAt:origin
                                          sized:size];
        
        SimpleGLObject *glObject = [flexiBuffer makeSimpleGLObject];
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
            SimpleGLObject *glObject = [flexiBuffer makeSimpleGLObject];
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
        SimpleGLObject *glObject = [flexiBuffer makeSimpleGLObject];
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
        [self performSelector:@selector(addCubesEverySoOften:)
                   withObject:@[@(numCubes),@(numTimes-1)]
                   afterDelay:1.0];
}

// Kick off adding cubes every second
- (void)setupMeteredCubes:(int)numCubes times:(int)numTimes
{
    [self performSelector:@selector(addCubesEverySoOften:)
               withObject:@[@(numCubes),@(numTimes)]
               afterDelay:1.0];
}

// Kick off adding cubes every second, but on a different thread
- (void)setupMultithreadedMeteredCubes:(int)numCubes times:(int)numTimes
{
    // Make ourselves a new OpenGL ES context before we kick off the thread
    // Notice that it uses the sharegroup from the
    otherContext = [[EAGLContext alloc] initWithAPI:self.context.API
                                         sharegroup:self.context.sharegroup];
    
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
        [glObject tearDownGL];
    [_glObjects removeAllObjects];
    
    self.effect = nil;
}

#pragma mark - GLKView and GLKViewController delegate methods

- (void)update
{
    // Set up the projection matrix
    float aspect = fabsf(self.view.bounds.size.width / self.view.bounds.size.height);
    GLKMatrix4 projectionMatrix =
            GLKMatrix4MakePerspective(GLKMathDegreesToRadians(65.0f), aspect, 0.1f, 100.0f);
    self.effect.transform.projectionMatrix = projectionMatrix;
    
    // Now the model matrix (for rotating the model)
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
                [glObject makeVertexArray];
            
            glBindVertexArrayOES(glObject.vertexArray);
            
            // Render the object with GLKit
            [self.effect prepareToDraw];
            
            glDrawArrays(GL_TRIANGLES, 0, glObject.numVertices);
        }
    }
}

@end

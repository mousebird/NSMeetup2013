//
//  Shader.fsh
//  NSMeetupExample
//
//  Created by Steve Gifford on 8/6/13.
//  Copyright (c) 2013 mousebird consulting. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}

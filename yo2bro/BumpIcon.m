//
//  BumpIcon.m
//  scro2bro
//
//  Created by Aaron Jones on 4/26/15.
//  Copyright (c) 2015 bitcows. All rights reserved.
//

#import "BumpIcon.h"
#import "BroBump.h"

@interface BumpIcon()
@property CGFloat postion;
@property CADisplayLink *displayLink;

@property BOOL animationRunning;
@property NSTimeInterval drawDuration;
@property CFTimeInterval lastDrawTime;
@property CGFloat drawProgress;
@end

@implementation BumpIcon

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;

}
//- (id)initWithFrame:(CGRect)frame
//{
//    self = [super initWithFrame:frame];
//    if (self) {
//    }
//    return self;
//}

-(void)awakeFromNib {
    self.postion = 0;
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    self.drawDuration = 3.0;
    self.animationRunning = NO;
    self.lastDrawTime = 0;

}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    
    if (!self.animationRunning)
    {
        //self.lastDrawTime = self.displayLink.timestamp;
        [BroBump drawSperated_handsCanvasWithTop:self.postion];
        return;
    }
    
    if (self.postion >= 16) {
        self.animationRunning = NO;
       // self.postion = ;
        [self.displayLink invalidate];
        self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(setNeedsDisplay)];
        [BroBump drawSperated_handsCanvasWithTop:self.postion];
        [self setNeedsDisplay];
        
        return;
    }
    if (self.animationRunning) {
        self.postion = self.postion + 1;
        [BroBump drawSperated_handsCanvasWithTop:self.postion];
    }
    
   

}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.animationRunning = YES;
    [self.displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
}
@end

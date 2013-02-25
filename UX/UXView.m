//
//  UXView.m
//  UX
//
//  Created by James Womack on 2/24/13.
//  Copyright (c) 2013 James Womack. All rights reserved.
//



#import <QuartzCore/QuartzCore.h>

#import "UXView.h"



@interface UXView ()
{
    CGFloat lastScale;
    UIScrollView *imgScrollView;
}

@end



@implementation UXView


- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


- (void)scale:(UIPinchGestureRecognizer *)sender
{
    if([(UIPinchGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded)
    {
        lastScale = 1.0;
        CGSize zoomViewSize = CGSizeApplyAffineTransform(imgScrollView.frame.size, [(UIPinchGestureRecognizer *)sender view].transform);
        CGPoint centerPoint = CGPointApplyAffineTransform(imgScrollView.frame.origin, [(UIPinchGestureRecognizer *)sender view].transform);
        
        CGRect r = imgScrollView.bounds;
        CGSize scrollViewSize = imgScrollView.frame.size;
        imgScrollView.contentSize = zoomViewSize;
        imgScrollView.contentOffset = centerPoint;
    }
    
    CGFloat currentScale = [[[(UIPinchGestureRecognizer*)sender view].layer valueForKeyPath:@"transform.scale"] floatValue];
    
    CGFloat scale = 1.0 - (lastScale - [(UIPinchGestureRecognizer*)sender scale]);
    scale = MIN(scale, imgScrollView.maximumZoomScale / currentScale);
    scale = MAX(scale, imgScrollView.minimumZoomScale / currentScale);
    CGAffineTransform currentTransform = [(UIPinchGestureRecognizer*)sender view].transform;
    CGAffineTransform newTransform = CGAffineTransformScale(currentTransform, scale, scale);
    [[(UIPinchGestureRecognizer*)sender view] setTransform:newTransform];
    lastScale = [(UIPinchGestureRecognizer*)sender scale];    
}


@end


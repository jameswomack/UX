//
//  UXSlideView.m
//  UX
//
//  Created by James Womack on 2/22/13.
//  Copyright (c) 2013 James Womack. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <THObserversAndBinders/THObserversAndBinders.h>

#import "UXSlideView.h"


@implementation UXSlideView
{
    CGPoint UXSlideViewPoint;
    CGPoint UXSlideViewPointClosed;
    CGPoint UXSlideViewPointOpened;
    
    CGAffineTransform tranform;
    
    CGRect rect;
    
    NSTimer *superviewCompensationOperation;
}



@dynamic highlighted;



static UIColor *UXGradientColorTop;
static UIColor *UXGradientColorBtm;
static CGFloat UXSlideViewXCompensation;
static __strong CAGradientLayer *backgroundGradientLayer;

CGRect CGRectOriginal(CGRect rect);
CGRect CGRectInvisibilty(CGRect rect);
CGRect CGRectShorterThan(CGRect rect, CGFloat times, CGRect rectOther);
CGFloat cmpf(CGFloat floatToCompensate);
UIView* UIViewShadowized(UIView *view, UIColor *color, CGFloat opacity, CGFloat x, CGFloat y);



CGRect CGRectOriginal(CGRect rect)
{
    CGRect rectNew = rect;
    rectNew.origin = CGPointZero;
    return rectNew;
}


CGRect CGRectInvisibilty(CGRect rect)
{
    CGRect rectNew = rect;
    rectNew.size = CGSizeZero;
    return rectNew;
}


CGRect CGRectShorterThan(CGRect rect, CGFloat times, CGRect rectOther)
{
    CGRect rectNew = rect;
    rectNew.size.height = rectOther.size.height / times;
    return rectNew;
}


CGRect CGRectTallerThan(CGRect rect, CGFloat times, CGRect rectOther)
{
    CGRect rectNew = rect;
    rectNew.size.height = rectOther.size.height * times;
    return rectNew;
}


CGFloat cmpf(CGFloat floatToCompensate)
{
    return floatToCompensate + UXSlideViewXCompensation;
}


UIView* UIViewShadowized(UIView *view, UIColor *color, CGFloat opacity, CGFloat x, CGFloat y)
{
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOpacity = opacity;
    view.layer.shadowOffset = CGSizeMake(x, y);
    return view;
}


+ (void)initialize
{
    UXGradientColorTop = [UIColor colorWithRed:.8f green:.8f blue:1.f alpha:.8f];
    UXGradientColorBtm = [UIColor colorWithRed:.2f green:.2f blue:.8f alpha:1.f];
    UXSlideViewXCompensation = -10;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self)
    {
        self.userInteractionEnabled = YES;
        self.multipleTouchEnabled = YES;
        self.autoresizesSubviews = YES;
        
        self.layer.cornerRadius = 12.f;
        
        UIViewShadowized(self, UIColor.blueColor, .8f, 1.f, 1.f);
    }
    
    superviewCompensationOperation = [NSTimer scheduledTimerWithTimeInterval:.01f target:self.class selector:@selector(superviewCompensationOperation:) userInfo:@{@"object": self} repeats:YES];
    
    return self;
}

- (NSArray*)fitViewsOfClass:(Class)class format:(Float32Point)format
{
    // 1 0 - side by side
    // 0 1 - top on top
    // 1 1 - 2 x grid
    // 0 0 - aspect fill
    
    NSMutableArray *subviews = NSMutableArray.new;
    
    [self.subviews enumerateObjectsUsingBlock:^(UIView *view, NSUInteger index, BOOL *stop) {
        if ([view isKindOfClass:class])
        {
            [subviews addObject:view];
        }
    }];
    
    
    return nil;
}


+ (void)superviewCompensationOperation:(NSTimer *)timer
{
    UXSlideView *slideView = timer.userInfo[@"object"];
    assert([slideView isKindOfClass:self]);
    assert([timer isEqual:slideView->superviewCompensationOperation]);
    
    UIView *superview = slideView.superview;
    NSLog(@"%@",superview.class);
    
    if (superview)
    {
        slideView->tranform = slideView.transform;
        slideView->rect = slideView.frame;
        
        CGRect frame = CGRectShorterThan(slideView.frame, 4.f, superview.frame);
        frame.origin = CGPointMake(frame.origin.x, frame.size.height * (slideView.tag * 1.f));
        slideView.frame = frame;
        
        [self applyGradient:@[UXGradientColorTop, UXGradientColorBtm] toView:slideView];
        
        [timer invalidate];
        
        slideView->UXSlideViewPointOpened.x = UXSlideViewXCompensation;
        slideView->UXSlideViewPointOpened.y = slideView->UXSlideViewPointClosed.y = slideView.frame.origin.y;
        
        slideView->UXSlideViewPointClosed.x = cmpf(-(slideView.frame.size.width/2.f));
    }
}


- (IBAction)tapReceived:(UITapGestureRecognizer *)sender
{
    UIGestureRecognizerState state = sender.state;
    
    NSString *stateString;
    
    switch (state)
    {
    
        case UIGestureRecognizerStateBegan:
            stateString = @"UIGestureRecognizerStateBegan";
            break;
        case UIGestureRecognizerStateCancelled:
            stateString = @"UIGestureRecognizerStateCancelled";
            break;
        case UIGestureRecognizerStateChanged:
            stateString = @"UIGestureRecognizerStateChanged";
            break;
        case UIGestureRecognizerStateFailed:
            stateString = @"UIGestureRecognizerStateFailed";
            break;
        case UIGestureRecognizerStatePossible:
            stateString = @"UIGestureRecognizerStatePossible";
            break;
        case UIGestureRecognizerStateRecognized:
            stateString = @"UIGestureRecognizerStateRecognized";
            break;
            
        default:
            break;
    }
    
    NSLog(@"%@", stateString);
    
    
}


- (void)animateOrigin:(CGPoint)origin
{
    [self animateOrigin:origin duration:.5f];
}

- (void)animateOrigin:(CGPoint)origin duration:(NSTimeInterval)duration
{
    [self animateOrigin:origin duration:duration reset:YES];
}

- (void)animateOrigin:(CGPoint)origin duration:(NSTimeInterval)duration reset:(BOOL)reset
{
    [UIView animateWithDuration:reset? .1f : 0.f animations:^{
        
        if (reset)
            self.transform = tranform;
        
    } completion:^(BOOL finished) {
        
        CGRect currentFrame = self.frame;
        
        currentFrame.origin = origin;
        
        [UIView animateWithDuration:duration animations:^{
            self.frame = currentFrame;
            NSLog(@"%@",NSStringFromCGAffineTransform(self.transform));
        }];
        
    }];
}


static BOOL end;
static BOOL stop;
static BOOL opened;
static NSTimeInterval interval;
static NSTimer *timer;

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    end = false;
    stop = false;
    UXSlideViewPoint = self.frame.origin;
    opened = self.frame.origin.x == UXSlideViewXCompensation;
    interval = 0;
    timer = nil;
    
    [UIView animateWithDuration:.2f animations:^{
        self.transform = CGAffineTransformMakeScale(.9f, .9f);
    }];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{    
    UITouch *touch = touches.anyObject;
    
    CGPoint currentPoint = [touch locationInView:self];
    
    BOOL hasntFocus = (currentPoint.x > rect.size.width || currentPoint.y > rect.size.height || currentPoint.x < 0 || currentPoint.y < 0);
    
    if (hasntFocus)
    {
        timer = [NSTimer scheduledTimerWithTimeInterval:.05f target:self selector:@selector(increment:) userInfo:nil repeats:YES];
        if (interval > .5f)
        {
            end = YES;
            [self animateOrigin:UXSlideViewPoint];
        }
        else
        {
            stop = YES;
        }
    }
    else
    {
        interval = 0;
        timer = nil;
    }
}

- (void)increment:(NSTimer *)aTimer
{
    interval += .05f;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = touches.anyObject;
    
    CGPoint currentPoint = [touch locationInView:self];
    
    NSLog(@"%f %f", currentPoint.x, currentPoint.y);
    
    if (end)
        return;
    
    if (stop)
    {
        [self animateOrigin:UXSlideViewPoint];
    }
    else
    {
        NSLog(@"%f %f", self.frame.origin.x, UXSlideViewXCompensation);
        [self animateOrigin:opened ? UXSlideViewPointClosed : UXSlideViewPointOpened];
        
        for (UXSlideView *slideView in self.superview.subviews)
        {
            if ([slideView isKindOfClass:UXSlideView.class] && ![slideView isEqual:self])
            {
                !opened ? [slideView animateOrigin:slideView->UXSlideViewPointClosed] : 0;
            }
        }
    }
    
    interval = 0;
    timer = nil;
}


+ (CAGradientLayer*)gradientLayerWithColors:(NSArray*)colors
{
    assert(colors.count == 2);
    
    for (id color in colors)
    {
        assert([color isKindOfClass:UIColor.class]);
    }
    
    UIColor *topColor = colors[0];
    UIColor *btmColor = colors[1];
    
    NSArray *cgColors = [NSArray arrayWithObjects:
     (id)topColor.CGColor,
     (id)btmColor.CGColor,
     nil];
    
    CAGradientLayer *gradientLayer = CAGradientLayer.layer;

    gradientLayer.colors = cgColors;
    
    return gradientLayer;
}


+ (void)applyGradient:(NSArray *)cgColors toView:(UIView *)view
{
    BOOL create = YES;
    
    for(CALayer *layer in view.layer.sublayers)
    {
        if([layer isKindOfClass:CAGradientLayer.class] && [layer isEqual:backgroundGradientLayer])
        {
            create = NO;
        }
    }
    
    if (create)
    {
        backgroundGradientLayer = [self.class gradientLayerWithColors:@[UXGradientColorTop, UXGradientColorBtm]];
        [view.layer insertSublayer:backgroundGradientLayer atIndex:0];
    }

    backgroundGradientLayer.frame = CGRectOriginal(view.frame);
    backgroundGradientLayer.cornerRadius = view.layer.cornerRadius;
}


@end

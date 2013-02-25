//
//  UXSlideView.h
//  UX
//
//  Created by James Womack on 2/22/13.
//  Copyright (c) 2013 James Womack. All rights reserved.
//

#import <UIKit/UIKit.h>

// 214

@interface UXSlideView : UIView

@property (unsafe_unretained) IBOutlet UIImageView *iconView;
@property (unsafe_unretained) IBOutlet UILabel *textlabel;
@property (unsafe_unretained) IBOutlet UITapGestureRecognizer *tapRecognizer;
@property BOOL highlighted;

- (IBAction)tapReceived:(UITapGestureRecognizer *)sender;

@end

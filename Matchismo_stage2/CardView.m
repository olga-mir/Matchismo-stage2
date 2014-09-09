//
//  CardView.m
//  Matchismo_stage2
//
//  Created by Olga on 26/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "CardView.h"
#import "SetCard.h"
#import "Utils.h"

@implementation CardView

- (instancetype)initWithFrame:(CGRect)frame
{
  self = [super initWithFrame:frame];
  
  if (self) {
    [self setup];
  }
  return self;
}

- (void) setFaceUp:(BOOL)faceUp
{
  _faceUp = faceUp;
  [self setNeedsDisplay];
}

- (NSString *)contents
{
  if (!_contents) {
    _contents = [NSString stringWithFormat:@""];
  }
  return _contents;
}

- (void)setup
{
  self.backgroundColor = nil;
  self.opaque = NO;
  self.contentMode = UIViewContentModeRedraw;
  self.clearsContextBeforeDrawing = NO;
}

+ (CGFloat)getAspectRatio {
  return 0.7; // TODO - overriding static virtual method. nuts
}

/**
 *  Animate the change in the frame with required duration and delay
 *
 *  @param fromFrame initial frame for animation
 *  @param toFrame   the final frame
 *  @param duration  animation duration (in sec)
 *  @param delay     delay before starting animation (in sec)
 */
- (void)animateCardFrameChangeFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withDuration:(CGFloat)duration withDelay:(CGFloat)delay;
{
  self.frame = fromFrame;

  [UIView animateWithDuration:duration
                        delay:delay
                      options:UIViewAnimationOptionTransitionNone
                   animations:^{
                     self.frame = toFrame;
                   }
                   completion:NULL];
}


#pragma mark - Virtual Methods

- (CGFloat)getCardAspectRatio
{
  mustOverride();
}

- (instancetype)initWithFrame:(CGRect)frame Card:(Card *)card
{
  mustOverride();
}

- (CGFloat)cornerRadius
{
  mustOverride();
}

- (void)selectOrDeselectCardWithDuration:(CGFloat)duration withDelay:(CGFloat)delay;
{
  mustOverride();
}

- (BOOL)getSelectedState
{
  mustOverride();
}

@end


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
  self.backgroundColor = nil; // can be also [UIColor clearColor] - it is only a style thing
  self.opaque = NO;
  self.contentMode = UIViewContentModeRedraw;
}

+ (CGFloat)getAspectRatio {
  return 0.7; // TODO - overriding static virtual method. nuts
}


- (void)animateCardFrameChangeFromFrame:(CGRect)fromFrame toFrame:(CGRect)toFrame withDelay:(CGFloat)delay;
{
  self.frame = fromFrame;

  [UIView animateWithDuration:0.2f
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

- (void)selectOrDeselectCard
{
  mustOverride();
}

- (BOOL)getSelectedState
{
  mustOverride();
}

@end


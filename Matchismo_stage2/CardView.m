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


- (void)setup
{
  self.backgroundColor = nil; // can be also [UIColor clearColor] - it is only a style thing
  self.opaque = NO;
  self.contentMode = UIViewContentModeRedraw;
}

/*
- (void)drawRect:(CGRect)rect
{ 
  // create the genral form of the card: white rounded corners with black stroke
  UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
  [roundedRect addClip];
  [[UIColor whiteColor] setFill];
  [roundedRect fill];   //UIRectFill(self.bounds);
  [[UIColor blackColor] setStroke];
  [roundedRect stroke];
}
*/

+ (CGFloat)getAspectRatio {
  return 0.7; // TODO - overridind static virtual method. nuts
}

// Virtual methods
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


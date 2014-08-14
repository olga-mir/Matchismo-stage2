//
//  SetCardView.m
//  Matchismo_stage2
//
//  Created by Olga on 29/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "SetCardView.h"
#import "SetCard.h"
#import "Utils.h"

@interface SetCardView()

@property (nonatomic) NSUInteger rank;            // 1, 2 or 3
@property (strong, nonatomic) NSString *color;    // green, red or purple
@property (strong, nonatomic) NSString *filling;  // solid, striped or unfilled
@property (strong, nonatomic) NSString *shape;    // squiggles, diamonds or ovals


@end

@implementation SetCardView

- (void)setSelected:(BOOL)selected {
  _selected = selected;
  [self setNeedsDisplay];
}

// It is NOT a getter to the 'selected' property. 
- (BOOL)getSelectedState
{
  return self.selected;
}

// designated initializer
// it is provided that the card is the Set Card and is not checked here.
- (instancetype)initWithFrame:(CGRect)frame withCard:(SetCard *)setCard
{
  SYSASSERT([setCard isKindOfClass:[SetCard class]], @"Type mismatch: Set card view cannot be created without valid card of Set type");
  
  self = [super initWithFrame:frame];
  
  if (self) {
    NSLog(@"initWithFrame, (Set) card = %@", setCard.contents);
  }
  return self;
}

- (void)awakeFromNib
{
  [self setup];
}

#pragma mark - Behavior

- (void)selectOrDeselectCard
{
  // When dealt the set cards are always face up, so when card is selected
  // it must be highlighted to make the selected look
  self.selected = !self.selected;
}

#pragma mark - Drawing

#define CORNER_RADIUS 12.0
#define CARD_ASPECT_RATIO 0.75

- (CGFloat)getCardAspectRatio
{
  NSLog(@"SET CARD getCardAspectRatio");
  return CARD_ASPECT_RATIO;
}


- (CGFloat)cornerScaleFactor { return self.bounds.size.height / 180.0; }
- (CGFloat)cornerRadius { return CORNER_RADIUS * [self cornerScaleFactor]; }


- (void)drawRect:(CGRect)rect
{
  //[super drawRect:rect]; - TODO - move the roundedn rect to the base class
  UIBezierPath *roundedRect = [UIBezierPath bezierPathWithRoundedRect:self.bounds cornerRadius:[self cornerRadius]];
  [roundedRect addClip];
  [[UIColor whiteColor] setFill];
  [roundedRect fill];   //UIRectFill(self.bounds);
  
  if (self.selected) {
    [[UIColor greenColor] setStroke];
    roundedRect.lineWidth = 3.0;
    [roundedRect stroke];
  } else {
    [[UIColor blackColor] setStroke];
    roundedRect.lineWidth = 1.0;
    [roundedRect stroke];
  }
}


@end

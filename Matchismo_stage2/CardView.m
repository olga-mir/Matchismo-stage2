//
//  CardView.m
//  Matchismo_stage2
//
//  Created by Olga on 26/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "CardView.h"

@implementation CardView

- (void) setFaceUp:(BOOL)faceUp
{
  _faceUp = faceUp;
  [self setNeedsDisplay];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (CardView *)createCardViewWithCard:(Card *)card // TODO - maybe should be instancetype?
{
  // TODO -  exception.
  NSLog(@"CardView: createCardViewWithCard - abstract method. Need to be implemented in subclass");
  return nil;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end

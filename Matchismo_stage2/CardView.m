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

- (instancetype)initWithFrame:(CGRect)frame Card:(Card *)setCard
{
  mustOverride();
}



@end

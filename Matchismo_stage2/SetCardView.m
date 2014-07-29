//
//  SetCardView.m
//  Matchismo_stage2
//
//  Created by Olga on 29/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "SetCardView.h"
#import "Utils.h"

@implementation SetCardView

// designated initializer
// it is provided that the card is the Set Card and is not checked here.
- (instancetype)initWithFrame:(CGRect)frame withCard:(SetCard *)setCard
{
  SYSASSERT([setCard isKindOfClass:[SetCard class]], @"Type mismatch: Set card view cannot be created without valid card of Set type");
  
  self = [super initWithFrame:frame];
  
  if (self) {

  }
  return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{

}


@end

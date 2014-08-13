//
//  SetDeck.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "SetCardDeck.h"
#import "SetCard.h"

@implementation SetCardDeck

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    for (NSUInteger rank = 1; rank <= 3; rank++) {
      for (NSString *color in [SetCard validColors]) {
        for (NSString *filling in [SetCard validFillings]) {
          for (NSString *shape in [SetCard validShapes]) {
            SetCard *card = [[SetCard alloc] init];
            card.rank = rank;
            card.color = color;
            card.filling = filling;
            card.shape = shape;
            [self addCard:card];
          }
        }
      }
    }
  }
  
  return self;
}


@end

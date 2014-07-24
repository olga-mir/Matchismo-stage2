//
//  PlayingDeck.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "PlayingDeck.h"
#import "PlayingCard.h"

@implementation PlayingDeck

- (instancetype)init
{
  self = [super init];
  
  if (self) {
    for (NSString *suit in [PlayingCard validSuits]) {
      for (NSInteger rank = 1; rank < [PlayingCard maxRank]; rank++) {
        PlayingCard *card = [[PlayingCard alloc] init];
        card.rank = rank;
        card.suit = suit;
        [self addCard:card];
      }
    }
  }
  
  return self;
}


@end

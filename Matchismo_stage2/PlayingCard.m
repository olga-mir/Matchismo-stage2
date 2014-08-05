//
//  PlayingCard.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "PlayingCard.h"

@implementation PlayingCard

- (NSString *)contents {
  NSArray *rankStrings = [PlayingCard rankStrings];
  return [rankStrings[self.rank] stringByAppendingString:self.suit];
}

@synthesize suit = _suit;

- (void)setSuit:(NSString *)suit {
  if ([[PlayingCard validSuits] containsObject:suit]) {
    _suit = suit;
  }
}

- (NSString *)suit {
  return _suit ? _suit : @"?";
}


+ (NSArray *)validSuits {
  return @[@"♠", @"♣", @"♥", @"♦"];
}

+ (NSArray *)rankStrings {
  return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7",
           @"8", @"9", @"10", @"J", @"Q", @"K"];
}

+ (NSUInteger) maxRank {return [[self rankStrings] count] - 1;}

- (void)setRank:(NSUInteger)rank {
  
  if (rank < [PlayingCard maxRank]) {
    _rank = rank;
  }
}

#define RANK_MATCH_SCORE 4
#define SUIT_MATCH_SCORE 2

- (int)match:(NSArray *)otherCards {
  
  int score = 0;
  int rankMatches = 0;
  int suitMatches = 0;
  
  PlayingCard *currentCard = self;
  NSMutableArray *otherCardsMutableArr = [otherCards mutableCopy];
  
  
  // We have a card and an array of other cards to match this card to
  // Once we've matched the current card to all the cards in otherCards array
  // we need to continue look for matches between the cards in otherCards array
  while ([otherCardsMutableArr count] >= 1) {
    
    for (PlayingCard *otherCard in otherCardsMutableArr) { // TODO - introspection
      
      if (otherCard.rank == currentCard.rank) {
        rankMatches++;
      } else if ([otherCard.suit isEqualToString:currentCard.suit]) {
        suitMatches++;
      }
    }
    
    // now take one card from the 'other' array and try to mathc it to its recent peers.
    currentCard = [otherCardsMutableArr lastObject]; // there is no order preference
    [otherCardsMutableArr removeLastObject];
  }
  
  score += rankMatches * RANK_MATCH_SCORE;
  score += suitMatches * SUIT_MATCH_SCORE;
  
  return score;
}


- (NSString *)rankAsString
{ // TODO  - add validation code
  return @[@"?", @"A", @"2", @"3", @"4", @"5", @"6", @"7", @"8", @"9", @"10", @"J", @"Q", @"K"][self.rank];
}

- (NSString *)description
{
  return [NSString stringWithFormat:@"Card contents: %@%@", [self rankAsString], self.suit];
}




@end

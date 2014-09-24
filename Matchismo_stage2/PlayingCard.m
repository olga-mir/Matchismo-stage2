//
//  PlayingCard.m
//  Matchismo_stage2
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "PlayingCard.h"
#import "Utils.h"

@implementation PlayingCard

- (NSString *)contents
{
  NSArray *rankStrings = [PlayingCard rankStrings];
  return [rankStrings[self.rank] stringByAppendingString:self.suit];
}

@synthesize suit = _suit;

- (void)setSuit:(NSString *)suit
{
  if ([[PlayingCard validSuits] containsObject:suit]) {
    _suit = suit;
  }
}

- (NSString *)suit
{
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
  
  if (rank <= [PlayingCard maxRank]) {
    _rank = rank;
  }
}

- (NSString *)rankAsString
{
  return [PlayingCard rankStrings][self.rank];
}

- (NSString *)description
{
  return self.contents;
}


/**
 *  Deisignated initializer
 *
 *  @param playingCard playingCard to create the exact duplicate
 *
 *  @return self, duplicate of the received playingCard
 */
- (instancetype)initWithCard:(PlayingCard *)playingCard
{
  self = [super initWithCard:playingCard];
  
  if (self) {
    _rank = playingCard.rank;
    _suit = playingCard.suit;
  }
  
  return self;
}

/**
 *  NScopying protocol
 *
 *  @param zone zone of memory to allocate the copy object
 *
 *  @return exact copy of the receiver object
 */
- (id)copyWithZone:(NSZone *)zone
{
  return [[PlayingCard alloc] initWithCard:self];
}


#pragma mark - Matching Logic

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
    
    for (PlayingCard *otherCard in otherCardsMutableArr) {
      
      SYSASSERT([otherCard isKindOfClass:[PlayingCard class]], @"Unexpected type of card");
      
      if (otherCard.rank == currentCard.rank) {
        rankMatches++;
      } else if ([otherCard.suit isEqualToString:currentCard.suit]) {
        suitMatches++;
      }
    }
    
    // now take one card from the 'other' array and try to match it to its recent peers.
    currentCard = [otherCardsMutableArr lastObject]; // there is no order preference
    [otherCardsMutableArr removeLastObject];
  }
  
  score += rankMatches * RANK_MATCH_SCORE;
  score += suitMatches * SUIT_MATCH_SCORE;
  
  return score;
}



@end

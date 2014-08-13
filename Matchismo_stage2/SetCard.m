//
//  SetCard.m
//  Matchismo_stage2
//
//  SetCard class implements the logic of a card in Set game as described on the Wikipedia site:
//  http://en.wikipedia.org/wiki/Set_(game)
//
//  Created by Olga on 24/07/14.
//  Copyright (c) 2014 Olga. All rights reserved.
//

#import "SetCard.h"

@implementation SetCard

#pragma mark - Properties

// rank
+ (NSArray *)validRanks {
  return @[@1, @2, @3];
}

+ (NSUInteger) maxRank {
  return (NSUInteger)[[self validRanks] lastObject];
}

- (void)setRank:(NSUInteger)rank {
  
  if (rank < [SetCard maxRank]) {
    _rank = rank;
  }
}

// color
@synthesize color = _color;

- (void)setColor:(NSString *)color {
  if ([[SetCard validColors] containsObject:color]) {
    _color = color;
  }
}

- (NSString *)color {
  return _color ? _color : nil;
}

+ (NSArray *)validColors {
  return @[@"green", @"red", @"purple"];
}

// fillings
@synthesize filling = _filling;

- (void)setfilling:(NSString *)filling {
  if ([[SetCard validFillings] containsObject:filling]) {
    _filling = filling;
  }
}

- (NSString *)filling {
  return _filling ? _filling : nil;
}

+ (NSArray *)validFillings {
  return @[@"solid", @"stripped", @"unfilled"];
}

// shape
@synthesize shape = _shape;

-(void)setShape:(NSString *)shape {
  if ([[SetCard validShapes] containsObject:shape]) {
    _shape = shape;
  }
}

- (NSString *)shape {
  return _shape ? _shape : nil;
}

+ (NSArray *)validShapes {
  return @[@"squiggle", @"diamond", @"oval"];
}

// Create a string from the card content
// "2-green-striped-squiggles"
- (NSString *)contents {
  return [NSString stringWithFormat:@"%d-%@-%@-%@", self.rank, self.color, self.filling, self.shape];
}


#define RANK_MATCH_SCORE 4
#define SUIT_MATCH_SCORE 2

- (int)match:(NSArray *)otherCards
{

  int score = 0;
/*  int rankMatches = 0;
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
*/
  return score;

}




@end

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
#import "Utils.h"

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


/**
 *  Get string representation of the card. Example: "2-green-striped-squiggles"
 *
 *  @return string representing the card
 */
- (NSString *)contents
{
  return [NSString stringWithFormat:@"%d-%@-%@-%@", self.rank, self.color, self.filling, self.shape];
}



/**
 *  Deisignated initializer
 *
 *  @param playingCard playingCard to create the exact duplicate
 *
 *  @return self, duplicate of the received playingCard
 */
- (instancetype)initWithCard:(SetCard *)setCard
{
  self = [super initWithCard:setCard];
  
  if (self) {
    _rank    = self.rank;
    _color   = self.color;
    _filling = self.filling;
    _shape   = self.shape;

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
  return [[SetCard alloc] initWithCard:self];
}


#pragma mark - Matching Logic

#define POINTS_FOR_MATCH 6

typedef enum RULES {
  NUMBER_RULE   = 0x1,
  SHAPE_RULE    = 0x2,
  FILLING_RULE  = 0x4,
  COLOR_RULE    = 0x8,
  ALL_RULES     = NUMBER_RULE | SHAPE_RULE | FILLING_RULE | COLOR_RULE,
} rules_e;

/**
 *  Card matches itself to the two other cards according to Set card game rules
 *
 *  @param otherCards array of other two cards to try and match this card
 *
 *  @return the score for the match. If the three cards form a Set, then positive number must be returned, otherwise it should be 0 or negative.
 */
- (int)match:(NSArray *)otherCards
{
  // Set is always three card game
  SYSASSERT(([otherCards count] == 2), ([NSString stringWithFormat:@"The Set game is always a 3-card matching game. Number of cards provided is %d", [otherCards count]]));
  
  SetCard *card2 = [otherCards firstObject];
  SetCard *card3 = [otherCards lastObject];
  
  int score = 0;
  rules_e setRules = 0;
  
  // General rule, that has to be checked for every property of the Set card (number, shape, filling, color)
  // "They all have the same __property__ or they have three different __property__s"
  // in order to make a Set ALL of these rules must be satisfied
  
  // Rule 1: They all have the same NUMBER or they have three different NUMBERs
  if ( ((self.rank == card3.rank) && (card2.rank == card3.rank)) ||
       ((self.rank != card2.rank) && (self.rank != card3.rank) && (card2.rank != card3.rank)) ) {
    setRules |= NUMBER_RULE;
  }

  // Rule 2: They all have the same SHAPE or they have three different SHAPEs
  if ( ([self.shape isEqualToString:card3.shape] && [card2.shape isEqualToString:card3.shape]) ||
      ((![self.shape isEqualToString:card2.shape]) && (![self.shape isEqualToString:card3.shape]) && (![card2.shape isEqualToString:card3.shape])) ) {
    setRules |= SHAPE_RULE;
  }

  // Rule 3: They all have the same FILLING or they have three different FILLINGs
  if ( ([self.filling isEqualToString:card3.filling] && [card2.filling isEqualToString:card3.filling]) ||
      ((![self.filling isEqualToString:card2.filling]) && (![self.filling isEqualToString:card3.filling]) && (![card2.filling isEqualToString:card3.filling])) ) {
    setRules |= FILLING_RULE;
  }
  
  // Rule 4: They all have the same COLOR or they have three different COLORs
  if ( ([self.color isEqualToString:card3.color] && [card2.color isEqualToString:card3.color]) ||
      ((![self.color isEqualToString:card2.color]) && (![self.color isEqualToString:card3.color]) && (![card2.color isEqualToString:card3.color])) ) {
    setRules |= COLOR_RULE;
  }
  
  NSLog(@"Set rules fulfilment: 0x%x (0001 - number, 0010 - shape, 0100 - filling, 1000 - color)", setRules);
  
  // a group of 3 cards is only a Set when it satisfies all the above rules
  if ((setRules & ALL_RULES) == ALL_RULES) {
    score = POINTS_FOR_MATCH;
  }
  return score;
}


@end
